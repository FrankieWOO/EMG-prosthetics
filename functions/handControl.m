classdef handControl < handle
    % real-time EMG acquisition and hand control
    
    properties
        dataFeed;   % datafeed object, e.g. Bitalino
        timerObj;   % timer object
        emgMonitor;
        ch1Plot;
        ch2Plot;
        ch3Plot;
        ch4Plot;
        rawData;
        ch1Data;
        ch2Data;
        ch3Data;
        ch4Data;
    end
    
    methods
        function obj = handControl()
            initialize(obj);
        end
        
        function initialize(obj)
            try
                obj.dataFeed = Bitalino('BITalino-15-11');
                disp('Connection to Bitalino established')
            catch
                error('Connection to Bitalino failed!');
            end
            obj.timerObj = timer('TimerFcn',@(~,~)timerFcn_callback(obj),'Period',0.5, ...
                 'ExecutionMode','FixedRate','BusyMode','drop');
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
        
        
        
        function start(obj)
            
            startBackground(obj.dataFeed);
            start(obj.timerObj);
            set(obj.ch1Plot,'XData',1,'YData',0);
            set(obj.ch2Plot,'XData',1,'YData',0);
            set(obj.ch3Plot,'XData',1,'YData',0);
            set(obj.ch4Plot,'XData',1,'YData',0);
            refreshdata;
            drawnow;
            
               
        end
        
        function stop(obj)
            stop(obj.timerObj);
            stopBackground(obj.dataFeed);
        end
        function timerFcn_callback(obj)
    
            % reads data from buffer
            obj.rawData = read(obj.dataFeed);
            nData = size(obj.rawData,1);
            disp('read:')
            disp(nData)
            % Scales data according to factor selected on dropdown menu
            ch1Data_new = adc2emg(obj.rawData(:,6));
            ch2Data_new = adc2emg(obj.rawData(:,7));
            ch3Data_new = adc2emg(obj.rawData(:,8));
            ch4Data_new = adc2emg(obj.rawData(:,9));
            % add new data to old data
            obj.ch1Data = [obj.ch1Data; ch1Data_new];
            obj.ch2Data = [obj.ch2Data; ch2Data_new];
            obj.ch3Data = [obj.ch3Data; ch3Data_new];
            obj.ch4Data = [obj.ch4Data; ch4Data_new];
            % if data array is bigger than 5000 points, cuts array to the most
            % recent 5000 data points
            if length(obj.ch1Data) > 5000
                obj.ch1Data=obj.ch1Data(end-5000-1:end);
                obj.ch2Data=obj.ch2Data(end-5000-1:end);
                obj.ch3Data=obj.ch3Data(end-5000-1:end);
                obj.ch4Data=obj.ch4Data(end-5000-1:end);
            end
        
            % plot data
            set(obj.ch1Plot,'XData',1:length(obj.ch1Data),'YData',obj.ch1Data);
            set(obj.ch2Plot,'XData',1:length(obj.ch2Data),'YData',obj.ch2Data);
            set(obj.ch3Plot,'XData',1:length(obj.ch3Data),'YData',obj.ch3Data);
            set(obj.ch4Plot,'XData',1:length(obj.ch4Data),'YData',obj.ch4Data);
            refreshdata;
            drawnow;
        end
        
    end
    
    events
        
    end
             



    

    
end