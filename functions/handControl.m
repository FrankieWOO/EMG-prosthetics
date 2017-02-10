classdef handControl < handle
    % real-time EMG acquisition and hand control
    % created by Fan on 2/2/2017
    properties
        dataFeed;   % datafeed object, e.g. Bitalino
        timerObj;   % timer object
        serialObj;
        emgMonitor;
        ch1Plot;
        ch2Plot;
        ch3Plot;
        ch4Plot;
        ch1Data;
        ch2Data;
        ch3Data;
        ch4Data;
        userName;
        gestureClass;
        btName; % EMG device name
        serialport;
        classifierObj;
        sampleRate = 1000;
        nSample = 200;
        mac;
        plotting = false;
        % default 4 channels
        analogChannels = [0 1 2 3];
        
    end
    
    methods
        function obj = handControl(userName,mac,serialport)
            %obj.btName = btName;
            obj.mac = mac;
            obj.serialport = serialport;
            obj.dataFeed = bitalino();
            
            
            try
                obj.dataFeed = obj.dataFeed.open(obj.mac,obj.sampleRate);
                disp('Connection to Bitalino established')
            catch
                error('Connection to Bitalino failed!');
            end
            obj.timerObj = timer('TimerFcn',@(~,~)timerFcn_callback(obj),'Period',0.1, ...
                 'ExecutionMode','FixedRate','BusyMode','drop');
             
            if (obj.plotting == true) 
            obj.emgMonitor = EmgMonitorApp;
            obj.ch1Plot = plot(obj.emgMonitor.ch1Axes,0);
            set(obj.emgMonitor.ch1Axes,'XTickLabel',[]);
            axis tight; grid on;
            obj.ch2Plot = plot(obj.emgMonitor.ch2Axes,0);
            set(obj.emgMonitor.ch2Axes,'XTickLabel',[]);
            axis tight; grid on;
            obj.ch3Plot = plot(obj.emgMonitor.ch3Axes,0);
            set(obj.emgMonitor.ch3Axes,'XTickLabel',[]);
            axis tight; grid on;
            obj.ch4Plot = plot(obj.emgMonitor.ch4Axes,0);
            set(obj.emgMonitor.ch4Axes,'XTickLabel',[]);
            axis tight; grid on;
            end
            
            obj.userName = userName;
            obj.classifierObj = emgClassifier(userName);
            % prepare the trained model, if model not exist, train it if
            % have data
            prepareModel(obj.classifierObj);
            
            % create serialport object
            obj.serialObj = serial(serialport);
            obj.gestureClass = 0;
            
        end
        function delete(obj)
            delete(obj.dataFeed);
            delete(obj.serialObj);
            delete(Obj.timerObj);
            
        end
                
        function start(obj)
            % start live streaming of Bitalino
            obj.dataFeed = obj.dataFeed.start(obj.analogChannels);
            fopen(obj.serialObj);
            % start timer
            start(obj.timerObj);
            
            if (obj.plotting == true)
            set(obj.ch1Plot,'XData',1,'YData',0);
            set(obj.ch2Plot,'XData',1,'YData',0);
            set(obj.ch3Plot,'XData',1,'YData',0);
            set(obj.ch4Plot,'XData',1,'YData',0);
            refreshdata;
            drawnow;
            end
        end
        
        function stop(obj)
            stop(obj.timerObj);
            obj.dataFeed = obj.dataFeed.stop();
            % close serial
            fclose(obj.serialObj);
        end
        
        function timerFcn_callback(obj)
            % reads nSample data
            rawData = obj.dataFeed.read(obj.nSample);
            nData = size(rawData,1);
            if nData == 0
                disp('no data read. wait, restart or check connection')
            end
            rawData_analog = rawData(:,6:end);
            rawData_analog(rawData_analog == -1) = 511.5;
            % convert adc data to emg data (mV)
            emgData = adc2emg(rawData_analog);
            
            if (obj.plotting == true)
                ch1Data_new = adc2emg(rawData(:,6));
                ch2Data_new = adc2emg(rawData(:,7));
                ch3Data_new = adc2emg(rawData(:,8));
                ch4Data_new = adc2emg(rawData(:,9));
                % add new data to old data
                obj.ch1Data = [obj.ch1Data; ch1Data_new];
                obj.ch2Data = [obj.ch2Data; ch2Data_new];
                obj.ch3Data = [obj.ch3Data; ch3Data_new];
                obj.ch4Data = [obj.ch4Data; ch4Data_new];
                % if data array is bigger than 5000 points, cuts array to the most
                % recent 5000 data points
                if length(obj.ch1Data) > 5000
                    obj.ch1Data=obj.ch1Data(end-5000+1:end);
                    obj.ch2Data=obj.ch2Data(end-5000+1:end);
                    obj.ch3Data=obj.ch3Data(end-5000+1:end);
                    obj.ch4Data=obj.ch4Data(end-5000+1:end);
                end
                % plot data
                set(obj.ch1Plot,'XData',1:length(obj.ch1Data),'YData',obj.ch1Data);
                set(obj.ch2Plot,'XData',1:length(obj.ch2Data),'YData',obj.ch2Data);
                set(obj.ch3Plot,'XData',1:length(obj.ch3Data),'YData',obj.ch3Data);
                set(obj.ch4Plot,'XData',1:length(obj.ch4Data),'YData',obj.ch4Data);
                refreshdata;
                drawnow;
            end
            
            % use classifier to output gesture class
            class_predict = obj.classifierObj.recognize(emgData);
            
            % if the event of gesture changing happens, trigger the event
            % to send command to serial port; or use another timer to
            % execute command
            fwrite(obj.serialObj,class_predict);
        end
        
    end
    
    events
        
    end
             
end