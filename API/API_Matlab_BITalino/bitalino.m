classdef bitalino
    
    properties
        socket;
        analogChannels;
        number_bytes;
        macAddress;
        versionID;
        connection;
        iStream;
        oStream;
        decode;
    end
    
    methods
        
        function self = bitalino()
            self.socket;
            self.analogChannels;
            self.number_bytes;
            self.macAddress;
            self.connection;
            javaaddpath(fullfile('/lib/bluecove-2.1.1-SNAPSHOT.jar'));
            javaaddpath(fullfile('/lib'));
            self.decode = decoding;
            clc;
            
        end
        
        %% Function OPEN
        function self = open(self,varargin)
%           Connect to bluetooth device with the mac address provided. 
%           Configure the sampling Rate. 
% 
%           Kwargs:
% 
%             macAddress (string): MAC address of the bluetooth device
%             SamplingRate(int): Sampling frequency (Hz); values available: 1000, 100, 10 and 1
%         
%           Ouptput:
%             self.connection: true (if connected) or false (if not
%             connected)

            switch nargin
                case 1
                    SamplingRate = 1000;
                case 2
                    self.macAddress = varargin{1};
                    SamplingRate = 1000;
                case 3
                    self.macAddress = varargin{1};
                    SamplingRate = varargin{2};
            end
            Setup = true;
            while (Setup)
                             
                    try
                        import java.io.IOException;
                        import java.io.DataInputStream;
                        import java.io.DataOutputStream;
                        import java.util.Vector;
                        import javax.bluetooth.RemoteDevice;
                        import javax.microedition.io.Connector;
                        import javax.microedition.io.StreamConnection;
                        clc;
                        self.socket = Connector.open(strcat('btspp://',self.macAddress,':1'), Connector.READ_WRITE);
                        self.iStream = self.socket.openDataInputStream();
                        self.oStream = self.socket.openDataOutputStream();
                        clc;
                        disp('Connected')
                        pause(1);
                        
                        if (SamplingRate == 1000)
                           variableToSend = 3;
                        elseif (SamplingRate == 100)
                            variableToSend = 2;
                        elseif (SamplingRate == 10)
                            variableToSend = 1;
                        elseif (SamplingRate == 1)
                            variableToSend = 0;
                        else
                            self.close();
                            self.connection = false;
                            return;
                        end
                        
                        variableToSend = bitor((bitshift(variableToSend,6)),3);
                        self.write(variableToSend);
                        Setup = false;
                        self.connection = true;
                        
                    catch exception
                        disp('Not connected');
                        self.connection = false;
                        return;
                    end
                    
            end
                
        end
        
        %% Function START
        function self = start(self,varargin)           
%           Starts Acquisition in the analog channels set.
%
%           Kwargs:
%             analogChannels (array of int): channels to be acquired (from 0 to 5)


            if (nargin == 2) 
                self.analogChannels = varargin{1};
            else
                disp('You need to input the analog channels array mask');
                return;
            end
            Nanalog = size(self.analogChannels,2); 
            if (Nanalog == 0 | Nanalog > 6 | size(find(self.analogChannels > 5 | self.analogChannels<0),2)~=0)
                disp('Analog channels set not valid');
                return;
            end
            if (size(self.socket,2)==0)
                disp('An input connection is needed.');
                return;
            end
            
            if (Nanalog <=4)
                self.number_bytes = ceil((12.+10.*Nanalog)/8.);
            else
                self.number_bytes = ceil((52.+6.*(Nanalog-4))/8.);
            end
                
            %setting channels mask
            bit = 1;
            for i=1:(size(self.analogChannels,2))
                bit = bitor(bit,bitshift(1,(2+self.analogChannels(i))));
            end
            %start acquisition
            self.write(bit);
            return;
        end
        
        %% Function STOP
        function self = stop(self)
%          Sends state value 0 to stop BITalino acquisition

           self.write(0);
           return;
        end
        
        %% Function CLOSE
        function self = close(self)
%          Closes bluetooth socket
           if (size(self.socket,2)~=0)
               self.socket.close();
               self.iStream.close();
               self.oStream.close();
               clear self.socket;
               clear self.iStream;
               clear self.oStream;
           end
           return;
        end
        
        %% Function WRITE
        function self = write(self,data)
%           Send a command to BITalino

            %write data
            self.oStream.write(data);
			self.oStream.flush();
            pause(1);
            return;
        end
        
        %% Function BATTERY
        function self = battery(self,value)
%          Set the battery threshold of BITalino
%          Works only in idle mode
% 
%          Kwargs:
%             value (int): threshold value from 0 to 63
%                 0  -> 3.4V
%                 63 -> 3.8V

           if (value >= 0 && value <= 63)
                Mode = bitshift(value,2);
                self.write(Mode);
           else
                disp('The threshold value must be between 0 and 63');
           end

           return;
        end
        
        %% Function TRIGGER
        function self = trigger(self,digitalArray)
%            Act on digital output channels of BITalino
%            Works only during acquisition mode
% 
%            Kwargs:
% 
%              digitalArray (array): array of size 4 which act on digital outputs according to the value: 0 or 1
%                   Each position of the array corresponds to a digital output, in ascending order.
% 
%              Example:
%                   digitalArray =[1,0,1,0] -> Digital 0 and 2 will be set to one and Digital 1 and 3 to zero

           if (size(digitalArray,2) ~= 4)
               return;
           end
           data = 3;
           for i=1:4
               data = bitor(data,bitshift(digitalArray(i),(1+i)));
           end
           self.write(data);
           return;
        end
        
        %% Function VERSION
        function self = version(self)
%           Get BITalino version
%           Works only in idle mode
            
            self.write(7);
            i=0;
            version = '';
            while 1
                a = self.iStream.read();
				if (a == 10)
					break;
                end
                version = cat(2,version,char(a));
				i=i+1;
            end
            self.versionID = version;
            disp(self.versionID);
        end
        
        %% Function READ
        function [dataAcquired] = read(self,nSamples)
%             Acquire defined number of samples from BITalino
% 
%             Kwargs: 
%                 nSamples (int): number of samples
% 
%             Output:
%                 dataAcquired (array): the data acquired is organized in a matrix; The columns correspond to the sequence number, 4 digital channels and analog channels, as configured previously on the start method; 
%                        Each line correspond to a sample.
% 
%                        The organization of the array is as follows:
%                        --  Always included --
%                        Column 0 - Sequence Number
%                        Column 1 - Digital 0
%                        Column 2 - Digital 1
%                        Column 3 - Digital 2
%                        Column 4 - Digital 3
%                        -- Variable with the analog channels set on start method --
%                        Column 5  - analogChannels[0]
%                        Column 6  - analogChannels[1]
%                        Column 7  - analogChannels[2]
%                        Column 8  - analogChannels[3]
%                        Column 9  - analogChannels[4]
%                        Column 10 - analogChannels[5]
%             
            nChannels = size(self.analogChannels,2);
            if (nChannels <=4)
                self.number_bytes = ceil((12.+10.*nChannels)/8.);
            else
                self.number_bytes = ceil((52.+6.*(nChannels-4))/8.);
            end
            
            %get Data according to the value nSamples set
            %dataAcquired = zeros(5+nChannels,nSamples);
            dataAcquired = zeros(nSamples,5+nChannels);
            Data = [];
            sampleIndex = 1;
            bTemp = javaArray('java.lang.Byte', 1);
            while (sampleIndex < nSamples+1)
                while (size(Data,2) < self.number_bytes)
                    bTemp = self.iStream.read();
                    Data = cat(2,Data,bTemp);
                end
                % decoded is a column vector
                decoded = javaMethod('main',self.decode,Data,self.number_bytes,nChannels);
                if (size(decoded,2) ~= 0)
                    dataAcquired(sampleIndex,:) = decoded;
                    Data = [];
                    sampleIndex = sampleIndex+1;
                else
                    bTemp = self.iStream.read();
                    Data = cat(2,Data,bTemp);
                    
                    Data = Data(2:end); 
                    disp('ERROR DECODING')

                end
                
            end
            return;
        end
        
    end
end    