classdef Bitalino < handle
    % Construct Bitalino object
    %
    % b = Bitalino constructs a Bitalino object connected to a BITalino
    % device over BTObject.
    %
    % b = Bitalino('myBitalinoDevice') constructs a Bitalino object
    % connected to a Bitalino whose remote name is specified by
    % |myBitalinoDevice|.
    %
    % b = Bitalino('btspp://98D331B2140E',1) constructs a Bitalino object
    % connected to a Bitalino device whose Bluetooth RemoteID or RemoteName
    % is specified by the first argument. The second argument is the
    % sample rate of the Bitalino in Hz.
    
    % Copyright 2015 The MathWorks, Inc.
    % 08/10/2015: v1.0. AT, VC
    
    properties
        SampleRate;          % Sample rate of acquisition of data from the Bitalino
    end
    
    properties (SetAccess = private)
        AvailableSamples = 0;% Number of Samples of data available in the bitalino object's buffer
        FirmwareVersion;     % Firmware version of the Bitalino
    end
    
    properties (Hidden = true)
        VerifyCRC = false;   % Hidden property to turn on the CRC checking of each frame of data
    end
    
    properties 
        BTObject;            % Bluetooth communication object
        RawFrames;           % Internal data buffer
        isStreaming = false; % Flag that signifies if the object is streaming data
        numBytesPerRead;     % Number of bytes to read per callback
        deviceTimeout = 0.2; % Timeout for bitalino server
        D0Value;             % Value of the D0 digital output pin
        D1Value;             % Value of the D1 digital output pin
        D2Value;             % Value of the D2 digital output pin
        D3Value;             % Value of the D3 digital output pin
    end
    
    methods (Static)
        %% Find all Bluetooth devices
        function availableDevices = findDevices()
            % Finds all available Bluetooth devices with RemoteName set to 
            % |bitalino|. The outputs from this may be used to construct a 
            % bitalino object. Example:
            %
            % MACIdList = Bitalino.findDevices
            availableBTDevices = instrhwinfo('Bluetooth');
            findbita = cellfun(@(x) isempty(strfind(x,'BITalino')),availableBTDevices.RemoteNames,...
                'UniformOutput',false);
            availableDevices = availableBTDevices.RemoteNames(cell2mat(findbita)==0);
        end
    end
    
    methods
        %% BITalino Constructor
        function obj=Bitalino(varargin)
            % Construct a bitalino object given optional input arguments.
            % If no input arguments are provided, it attempts to connect to
            % a Bluetooth object called Bitalino. Example:
            % 
            % b = Bitalino
            
            if nargin>2
                error('bitalino:invalidInputs','Invalid number of input arguments. See ''help bitalino'' for more information.');
            end
            
            try
                if (nargin == 0)
                    obj.BTObject=Bluetooth('bitalino',1);
                else
                    validateattributes(varargin{1},{'char'},{'vector'})
                    obj.BTObject=Bluetooth(varargin{1},1);
                end
                set(obj.BTObject, 'Tag','Bitalino');
                set(obj.BTObject, 'InputBufferSize',2^16); % This buffer should hold ~8 seconds of data at 1000Hz
                set(obj.BTObject, 'Terminator','');
                set(obj.BTObject, 'ByteOrder', 'bigEndian');
                set(obj.BTObject, 'ObjectVisibility','off');
                fopen(obj.BTObject);
            catch myException
                throw(myException);
            end
            
            % Set bitalino to idle and flush any data the Bitalino has put
            % onto the bluetooth stack
            obj.sendToIdle;
            flushinput(obj.BTObject);
            % Retrieve and store the Bitalino's firmware version
            % Send the Bitalino command to get firmware information
            obj.write(7); % 7 = bin2dec('00000111').
            obj.FirmwareVersion = char(fread(obj.BTObject,23))'; %#okfread
            flushinput(obj.BTObject);
            % Set sampling rate
            if (nargin==2)
                validateattributes(varargin{2},{'numeric'},{'scalar'});
                obj.SampleRate = varargin{2};
            else
                obj.SampleRate = 1000;
            end
            writeDigitalPins(obj,{'D0','D1','D2','D3'},{0,0,0,0}); % set digital outputs to zero on initialization            
        end

        %% Retrieve number of samples in the internal buffer
        function numSamples = get.AvailableSamples(obj)
            % Retrieve the number of samples available to read back from
            % the Bitalino. Example:
            %
            % b.AvailableSamples
            
            numSamples = size(obj.RawFrames,1);
        end
        
        %% Get BITalino SampleRate
        function value = get.SampleRate(obj)
            % Get the sampling rate, in Hz, of the Bitalino. 
            %
            % b.SampleRate
            
            value = obj.SampleRate;
        end
        
        %% BITalino Destructor
        function delete(obj)
            % Delete the Bitalino object. Example:
            %
            % delete(b)
            
            try
                if isequal(getStreamingState(obj),true)
                    % Send Bitalino to idle before cleaning up
                    sendToIdle(obj);
                    disableBackgroundProcessing(obj);
                    fclose(obj.BTObject);
                end
                delete(obj.BTObject);
            catch
                % Silently handle exceptions
            end
        end
        
        
        %% Read data acquired from the BITalino
        function data = read(obj)
            % Read the data back from the internal buffer of the bitalino 
            % object. The buffer is resized to remove the existing data 
            % from the buffer once this is read back by the user. Example:
            %
            % values = read(b)
            %
            % The following shows which columns correlate to each channel.
            % 1             2   3   4   5   6   7   8   9   10  11
            % packetNumber  I0  I1  I2  I3  A0  A1  A2  A3  A4  A5
            
            n = size(obj.RawFrames,1);
            data = obj.decodeFrames(obj.RawFrames(1:n,:));
            if size(obj.RawFrames,1)>n
                obj.RawFrames = obj.RawFrames(n+1:end,:);
            else
                obj.RawFrames = [];
            end
        end
        
        %% Read instantaneous data from the Bitalino
        function data = readCurrentValues(obj, varargin)
            % Reads the current values of the Bitalino sensors from the 
            % internal buffer of the bitalino object. The buffer is not 
            % resized to remove the existing data from the buffer when it 
            % is acquiring data in the background. Example:
            %
            % currentValue = readCurrentValues(b)
            %
            % The following shows which columns correlate to each channel.
            % 1             2   3   4   5   6   7   8   9   10  11
            % packetNumber  I0  I1  I2  I3  A0  A1  A2  A3  A4  A5
            %
            % readCurrentValues(b, n) reads 'n' values of the Bitalino
            % sensors.

            if nargin>2
                throw(MException('bitalino:readInstantaneous:invalidInputs','Invalid number of input arguments. READINSTANTANEOUS only takes at most 2 inputs'));
            elseif (nargin==2)
                validateattributes(varargin{1},{'numeric'},{'scalar'});
                n = varargin{1};
            else
                n = 1;
            end
            
            if isequal(getStreamingState(obj),true)
                data = obj.RawFrames(end-(n-1):end,:);
            else
                cachedArray = obj.RawFrames;
                cachedSampleRate = obj.SampleRate;
                obj.RawFrames = [];
                obj.SampleRate = 1000;
                obj.enableBackgroundProcessing;
                while (size(obj.RawFrames,1)<n)
                    pause(obj.deviceTimeout);
                end
                obj.disableBackgroundProcessing;
                % Flush data in Bluetooth buffer and MATLAB EDT
                flushinput(obj.BTObject);
                drawnow;
                data = decodeFrames(obj,obj.RawFrames(end-(n-1):end,:));
                obj.RawFrames = cachedArray;
                obj.SampleRate = cachedSampleRate;
            end
        end
        
        %% Set BITalino to stream data into MATLAB
        function startBackground(obj)
            % Starts the acquisition of data from the Bitalino without
            % blocking the execution of MATLAB commands. Any existing data
            % in the Bitalino object's buffer is cleared. Example:
            %
            % startBackground(b)
            
            if isequal(getStreamingState(obj),false)
                obj.RawFrames = [];
                enableBackgroundProcessing(obj);
                obj.isStreaming = true;
            else
                throw(MException('bitalino:startBackground:isStreaming','This operation is only allowed when the bitalino is not streaming data'));
            end
        end
        
        %% Set the BITalino to stop streaming data into MATLAB
        function stopBackground(obj)
            % Stops the acquisition of data from the Bitalino and sets the 
            % device into idle state. Any data in the buffer is not cleared
            % on stop. Example:
            % 
            % stopBackground(b)
            
            if isequal(getStreamingState(obj),true)
                disableBackgroundProcessing(obj);
                obj.isStreaming = false;
            else
                throw(MException('bitalino:stopBackground:notStreaming','This operation is only allowed when the bitalino is streaming data'));
            end
        end
        
        %% Set BITalino SampleRate
        function set.SampleRate(obj, value)
            % Set the sampling rate, in Hz, of the Bitalino. Valid sample 
            % rates are 1Hz, 10Hz, 100Hz and 1000Hz. Example:
            %
            % b.SampleRate = 100
            
            if isequal(getStreamingState(obj),true)
                throw(MException('bitalino:sampleRate:cannotChangeWhenStreaming','Cannot change the sample rate when streaming. To change the sample rate, STOP the object first.'));
            end
            
            switch value
                % 0b11000011 - 1000hz sample rate
                % 0b10000011 - 100hz sample rate
                % 0b01000011 - 10hz sample rate
                % 0b00000011 - 1hz sample rate
                case 1000
                    valueToWrite = bitor(3,bitshift(3,6));
                    setNumBytesPerRead(obj,800);
                case 100
                    valueToWrite = bitor(3,bitshift(2,6));
                    setNumBytesPerRead(obj,200);
                case 10
                    valueToWrite = bitor(3,bitshift(1,6));
                    setNumBytesPerRead(obj,40);
                case 1
                    valueToWrite = bitor(3,bitshift(0,6));
                    setNumBytesPerRead(obj,8);
                otherwise
                    throw(MException('bitalino:sampleRate:invalidSampleRate','Invalid sample rate specified. Valid rates are 1, 10, 100, 1000 Hz'));
            end
            write(obj,valueToWrite);
            obj.SampleRate = value;
        end
                
        %% Write to one of the BITalino's D0...D3 pins
        function writeDigitalPins(obj, pins, values)
            % Writes the specified values to the specified pins. Example:
            % 
            % writeDigitalPins(b,{'D0','D1','D2','D3'},{1,0,1,0}) turns on
            % the D1 and D3 pins and turns off the D2 and D3 digital output
            % pins. 
            
            if (numel(unique(pins)) ~= numel(pins))
                throw(MException('bitalino:writeDigitalPins:invalidInputs','The value for a digital output pin is specified more than once in the list of pins. Ensure the list only contains a unique value for each output pin'));
            end
                      
            if (numel(pins) ~= numel(values))
                throw(MException('bitalino:writeDigitalPins:invalidInputs','The specified number of digital pins does not match the specified number of output values'));
            end

            for i = 1:numel(pins)
                switch lower(pins{i})
                    case 'd0'
                        if values{i}
                            obj.D0Value = 1;
                        else
                            obj.D0Value = 0;
                        end
                    case 'd1'
                        if values{i}
                            obj.D1Value = 1;
                        else
                            obj.D1Value = 0;
                        end
                    case 'd2'
                        if values{i}
                            obj.D2Value = 1;
                        else
                            obj.D2Value = 0;
                        end
                    case 'd3'
                        if values{i}
                            obj.D3Value = 1;
                        else
                            obj.D3Value = 0;
                        end
                    otherwise
                        throw(MException('bitalino:writeDigitalPins:invalidOutputPin','Invalid digital output pin specified. Valid values are ''D0'',''D1'',''D2'' and ''D3'''));
                end
            end
            
            valueToWrite = bitshift(obj.D0Value,2,'uint8') + ...
                           bitshift(obj.D1Value,3,'uint8') + ...
                           bitshift(obj.D2Value,4,'uint8') + ...
                           bitshift(obj.D3Value,5,'uint8');

            % Digital pin command is 0b00xxxx11, where x is the value
            % of pin D3...D0
            valueToWrite = bitor(3,valueToWrite);                           % 3 = bin2dec('00000011')
            
            if isequal(getStreamingState(obj),true)
                write(obj, valueToWrite);
            else
                % If the device isn't streaming, cache the current sample
                % rate, temporarily turn it to streaming at 1000Hz, write
                % the data and turn it back to idle
                cachedSampleRate = obj.SampleRate;
                obj.SampleRate = 1000;
                sendToLive(obj);
                write(obj, valueToWrite);
                sendToIdle(obj);
                % Flush any data the Bitalino may have put on the buffer
                % during the period when it is streaming.
                flushinput(obj.BTObject);
                % Flush MATLAB EDT
                drawnow;
                obj.SampleRate = cachedSampleRate;
            end
        end
    end
    
    methods ( Access = 'private' )       
        %% Decode a single frame of data
        function decodedData = decodeFrames(obj, data)
            % Decode the data Frames and return an array of data
            
            % NOTE: The following code does bitwise operations to decode the
            % data in each packet. Refer to the Bitalino's MCU block
            % datasheet for information on ordering of data within a packet
            % http://bitalino.com/datasheets/MCU_Block_Datasheet.pdf
            
            decodedData = zeros(size(data,1),11);
            for i = 1:size(data,1)
                
                % Only decode CRC if the hidden property, VerifyCRC, is
                % true. NOTE: Doing this has a significant performance
                % impact.
                if (obj.VerifyCRC)
                    % Extract CRC
                    CRC = bitand(data(i,8),15,'uint8');                         % 15 = bin2dec('00001111')
                    data(i,8) = bitand(data(i,8),240,'uint8');                  % 240 = bin2dec('11110000')
                    % Decode the Cyclic Redundancy Check and cross verify
                    data(i,8) = bitand(data(i,8),240);
                    calcCRC = 0;
                    for j = 1:1:8
                        for bit = 7:-1:0
                            calcCRC = bitshift(calcCRC,1,'uint8');
                            if bitand(calcCRC,16)
                                calcCRC = bitxor(calcCRC,3,'uint8');
                            end
                            calcCRC = bitxor(calcCRC, ...
                                bitand(1, bitshift(data(i,j),-1*bit)),'uint8');
                        end
                    end
                    calcCRC = bitand(uint8(calcCRC),15,'uint8');
                    if ~isequal(CRC,calcCRC)
                        throw(MException('bitalino:read:CRCError',sprintf('Error when decoding frame. CRC = %d, calculated CRC = %d',CRC, calcCRC)));
                    end
                end
                
                % Decode the Sequential Number (packetNumber). This ranges from 0-15
                packetNumber = bitshift(data(i,8),-4,'uint8');
                
                % Decode digitalInputs
                D0 = bitshift(bitand(data(i,7),128),-7);                % 128 = bin2dec('10000000');
                D1 = bitshift(bitand(data(i,7),64),-6);                 % 64 = bin2dec('01000000');
                D2 = bitshift(bitand(data(i,7),32),-5);                 % 32 = bin2dec('00100000');
                D3 = bitshift(bitand(data(i,7),16),-4);                 % 16 = bin2dec('00010000');
                
                % Decode A0 bits. This should have a range of 0-1023
                A0 = bitor(bitshift(bitand(data(i,7),15,'uint8'),6,'uint16'), ...
                    bitshift(data(i,6),-2,'uint8'));
                
                % Decode A1 bits. This should have a range of 0-1023
                A1 = bitor(bitshift(bitand(data(i,6),3,'uint8'),-8,'uint16'), ...
                    data(i,5));
                
                % Decode A2 bits. This should have a range of 0-1023
                A2 = bitor(bitshift(data(i,4),2,'uint16'), ...
                    bitshift(data(i,3),-6,'uint8'));
                
                % Decode A3 bits. This should have a range of 0-1023
                A3 = bitor(bitshift(bitand(data(i,3),63,'uint8'),4,'uint16'), ...
                    bitshift(data(i,2),-4,'uint8'));
                
                % Decode A4 bits. This has a range of 0-63
                A4 = bitor(bitshift(bitand(data(i,2),15,'uint8'),2,'uint8'), ...
                    bitshift(data(i,1),-6),'uint8');
                
                % Decode A5 bits. This has a range of 0-63
                A5 = bitand(data(i,1),63,'uint8');
                
                decodedData(i,:) = [packetNumber D0 D1 D2 D3 A0 A1 A2 A3 A4 A5];
            end
        end
                
        %% Disable the bluetooth object's callback function
        function disableBackgroundProcessing(obj)
            % Send Bitalino into idle mode
            
            sendToIdle(obj);
            fclose(obj.BTObject);
            % Flush data in Bluetooth buffer and MATLAB EDT
            flushinput(obj.BTObject);
            drawnow;
            set(obj.BTObject, 'BytesAvailableFcn','', ...
                'BytesAvailableFcnMode', 'byte', ...
                'BytesAvailableFcnCount', obj.numBytesPerRead);
            fopen(obj.BTObject);
        end

        %% Enable the Bluetooth object's callback for background processing
        function enableBackgroundProcessing(obj)
            % Send Bitalino into live mode and stream data from the device
            
            fclose(obj.BTObject);
            % Flush data in Bluetooth buffer and MATLAB EDT
            flushinput(obj.BTObject);
            set(obj.BTObject, 'BytesAvailableFcn',@(handle,object)obj.readFrame, ...
                'BytesAvailableFcnMode', 'byte', ...
                'BytesAvailableFcnCount', obj.numBytesPerRead);
            drawnow;
            fopen(obj.BTObject);
            sendToLive(obj);
        end
        
        %% Return BITalino streaming status
        function Value = getStreamingState(obj)
            % 1 = object is streaming
            % 0 = object is not streaming
            Value = obj.isStreaming;
        end
        
        %% Read data frame for BITalino object
        function readFrame(obj,~)
            % Receive data frame from the bitalino device on callback
            
            % Read bytes of data from bitalino
            data=fread(obj.BTObject,obj.numBytesPerRead,'uchar');
            obj.RawFrames = [obj.RawFrames; reshape(data,[8,floor(obj.numBytesPerRead/8)])'];
        end
                        
        %% Turn on idle mode
        function obj=sendToIdle(obj)
            write(obj,0);
        end

        %% Turn on live mode
        function obj=sendToLive(obj)
            % Enable streaming of data from the device
            % 253 = 0b11111101 - live 6 analog channels
            % 254 = 0b11110110 - simulated 6 analog channels
            write(obj,253);
        end
        
        %% Set the internal property numBytesPerRead
        function setNumBytesPerRead(obj,Value)
            obj.numBytesPerRead = Value;
        end

        %% Write data to the BITalino
        function obj=write(obj, data)
            
            % Flush MATLAB EDT
            drawnow;
            % Internal function used to send data to the bitalino
            fwrite(obj.BTObject,data,'uint8');
            % The bitalino firmware needs time to process commands. Pause
            % here to prevent commands from being dropped by the firmware.
            pause(obj.deviceTimeout);
        end        
    end
end