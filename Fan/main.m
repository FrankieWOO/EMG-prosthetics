
b = Bitalino('BITalino-15-11');

timerObj = timer('TimerFcn',@timerFcn_callback,'Period',0.5, ...
                 'ExecutionMode','FixedRate','BusyMode','drop');
             
function timerFcn_callback(~,~,~)
    
    % reads data from buffer
    rawData = read(bitalinoObj);
    % add new data to old data
        
    % Scales data according to factor selected on dropdown menu
        
        
    % if data array is bigger than 5000 points, cuts array to the most
    % recent 5000 data points
    if length(channel1Data) > 5000
        channel1Data=channel1Data(end-5000:end);
        channel2Data=channel2Data(end-5000:end);
        channel3Data=channel3Data(end-5000:end);
        channel4Data=channel4Data(end-5000:end);
    end
        
    % plots data
    set(channel0Plot,'XData',1:length(channel1Data),'YData',channel1Data);
    set(channel1Plot,'XData',1:length(channel2Data),'YData',channel2Data);
    set(channel2Plot,'XData',1:length(channel3Data),'YData',channel3Data);
    set(channel3Plot,'XData',1:length(channel4Data),'YData',channel4Data);
        
    refreshdata;
    drawnow;
end