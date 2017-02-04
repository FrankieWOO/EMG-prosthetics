classdef dataRecord
    %DATARECORD record EMG data and store the data
    %   created by Fan on 3/2/2017
    
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
        function obj = dataRecord()
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
        function startRecord(obj)
            
        end
        function stopRecord(obj)
            
        end
    end
    
end

