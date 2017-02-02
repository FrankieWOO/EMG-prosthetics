function bitalinoApp
% This is a simple streaming application that usese the BITalino and its
% sensors to ready and display sensor data.

% Copyright 2015 The MathWorks, Inc.
% 08/25/2015: v1.0. AT

if ~isempty(findobj(0,'Tag','bitalinoApp'))
    errordlg('An instance of bitalinoApp is already running. Switch to that instance','bitalinoApp');
    return;
end

%% CREATE UI
mainWindow=figure('Name','Data Streaming with BITalino','NumberTitle','off',...
    'Position',[500,100,750,750],'MenuBar','none','Toolbar','Figure',...
    'CloseRequestFcn',{@closeRequestFcn},'Tag','bitalinoApp','DockControls','off','Resize','off');
titleText=uicontrol('Style','text','String','Data Streaming with BITalino',...
    'Position',[5,715,300,25],'FontSize',13.5,'FontWeight','Bold','Units','Normalized');

% Connection Panel
connectionPanel=uipanel('Title','Connection','FontWeight','bold','Position',[.05,.85,.375,.1],...
    'Units','Normalized');
availableDevices=Bitalino.findDevices();
remoteIDsMenu = uicontrol('Parent',connectionPanel,'Style','popupmenu',...
    'String',{'Select a Remote ID',availableDevices{1:end}},'Value',1,...
    'Position',[20,35,150,10],'Units','Normalized');
connectButton = uicontrol('Parent',connectionPanel,'Style', 'togglebutton',...
    'String','Connect','Position',[185,20,75,30],'BackgroundColor','green',...
    'Value', 0,'Callback',{@connectButton_callback},'Units','Normalized');

% Construct Radio buttons
inputPanel=uipanel('Title','Inputs','FontWeight','Bold','Position',[0.45,0.85,.25,0.1],'Units','Normalized');
input1=uicontrol('Parent',inputPanel,'Style','text','String','Digital Input 1: OFF','FontWeight','bold',...
    'FontSize',11,'BackgroundColor','red','Position',[17.5,35,150,20],'Units','Normalized');
input2=uicontrol('Parent',inputPanel,'Style','text','String','Digital Input 2: OFF','FontWeight','bold',...
    'FontSize',11,'BackgroundColor','red','Position',[17.5,5,150,20],'Units','Normalized');

outputPanel=uipanel('Title','Outputs','FontWeight','Bold','Position',[0.725,0.85,0.225,0.1],'Units','Normalized');
output1=uicontrol('Parent',outputPanel,'Style','checkbox','String','Digital Output 1',...
    'Position',[15,35,125,15],'FontWeight','bold','FontSize',10,'Callback',{@output1_callback});
output2=uicontrol('Parent',outputPanel,'Style','checkbox','String','Digital Output 2',...
    'Position',[15,10,125,15],'FontWeight','bold','FontSize',10,'Callback',{@output2_callback});

%% CONSTRUCT GRAPHS

channel0Panel=uipanel('Title','Channel 0','Position',[.05,.625,.925,.2],'FontWeight','bold',...
    'FontSize',10,'Units','Normalized');
channel0Axes=axes('Parent',channel0Panel,'Position',[.05,.2,.8,.7],'Units','Normalized');
channel0Plot = plot(channel0Axes,0);
set(channel0Axes,'XTickLabel',[]);
axis tight; grid on;
dropdownText0=uicontrol('Parent',channel0Panel,'Style','text','String','Data Type',...
    'Position',[595,110,80,15],'Units','Normalized');
channel0Dropdown=uicontrol('Parent',channel0Panel,'Style','popupmenu',...
    'String',{'Unused','Raw','EMG','ECG','EDA','ACC','LUX'},'Value',1,...
    'Position',[595,60,80,50],'Units','Normalized');

channel1Panel=uipanel('Title','Channel 1','Position',[.05,.425,.925,.2],'FontWeight','bold',....
    'FontSize',10,'Units','Normalized');
channel1Axes=axes('Parent',channel1Panel,'Position',[.05,.20,.8,.7]);
channel1Plot = plot(channel1Axes,0);
set(channel1Axes,'XTickLabel',[]);
axis tight; grid on;
dropdownText1=uicontrol('Parent',channel1Panel,'Style','text','String','Data Type',...
    'Position',[595,110,80,15],'Units','Normalized');
channel1Dropdown=uicontrol('Parent',channel1Panel,'Style','popupmenu',...
    'String',{'Unused','Raw','EMG','ECG','EDA','ACC','LUX'},'Value',1,...
    'Position',[595,60,80,50],'Units','Normalized');

channel2Panel=uipanel('Title','Channel 2','Position',[.05,.225,.925,.2],'FontWeight','bold',...
    'FontSize',10,'Units','Normalized');
channel2Axes=axes('Parent',channel2Panel,'Position',[.05,.20,.8,.7],'Units','Normalized');
channel2Plot = plot(channel2Axes,0);
set(channel2Axes,'XTickLabel',[]);
axis tight; grid on;
dropdownText2=uicontrol('Parent',channel2Panel,'Style','text','String','Data Type',...
    'Position',[595,110,80,15],'Units','Normalized');
channel2Dropdown=uicontrol('Parent',channel2Panel,'Style','popupmenu',...
    'String',{'Unused','Raw','EMG','ECG','EDA','ACC','LUX'},'Value',1,...
    'Position',[595,60,80,50],'Units','Normalized');

channel3Panel=uipanel('Title','Channel 3','Position',[.05,.025,.925,.2],...
    'FontWeight','bold','FontSize',10,'Units','Normalized');
channel3Axes=axes('Parent',channel3Panel,'Position',[.05,.20,.8,.7],'Units','Normalized');
channel3Plot = plot(channel3Axes,0);
set(channel3Axes,'XTickLabel',[]);
axis tight; grid on;
dropdownText3=uicontrol('Parent',channel3Panel,'Style','text','String','Data Type',...
    'Position',[595,110,80,15],'Units','Normalized');
channel3Dropdown=uicontrol('Parent',channel3Panel,'Style','popupmenu',...
    'String',{'Unused','Raw','EMG','ECG','EDA','ACC','LUX'},'Value',1,...
    'Position',[595,60,80,50],'Units','Normalized');

%% CREATE OBJECTS/VARIABLES
isStreaming = 0;
bitalinoObj = [];
timerObj = timer('TimerFcn',@timerFcn_callback,'Period',0.5, ...
                 'ExecutionMode','FixedRate','BusyMode','drop');

%% CLOSEREQUESTFCN
    function closeRequestFcn(source,callbackdata)
        try 
            stop(timerObj);
            delete(timerObj);
        catch
            errordlg('An error occurred trying to delete the objects.','Close Request Function Error');
        end
        delete(bitalinoObj);
        delete(mainWindow);
    end

%% CONNECTBUTTON_CALLBACK
    function connectButton_callback(source,eventData)
        if ~isStreaming
            if ~isequal(size(bitalinoObj,1),1)
                remoteIDList = get(remoteIDsMenu,'String');
                remoteID = remoteIDList{get(remoteIDsMenu,'Value')};
                if ~strcmpi(remoteID,'Select a Remote ID')
                    try
                    bitalinoObj = Bitalino(remoteID);
                    catch
                        errordlg('Connection failed. Please reset your BITalino and try again.','BITalino Connection Error');
                        connectButton.Value=0;
                        return;
                    end
                    bitalinoObj.SampleRate=1000;
                else
                    errordlg('Connection failed, please select a RemoteID and try again.','BITalino RemoteID Error');
                    connectButton.Value = 0;
                    return;
                end
            end
            startBackground(bitalinoObj);
            start(timerObj);
            set(channel0Plot,'XData',1,'YData',0);
            set(channel1Plot,'XData',1,'YData',0);
            set(channel2Plot,'XData',1,'YData',0);
            set(channel3Plot,'XData',1,'YData',0);
            refreshdata;
            drawnow;
            isStreaming = 1;
            connectButton.String = 'Pause';
            connectButton.BackgroundColor = 'red';
            connectButton.Value = 0;
        else
            stop(timerObj);
            bitalinoObj.stopBackground;
            isStreaming = 0;
            connectButton.String = 'Start';
            connectButton.BackgroundColor = 'green';
            connectButton.Value = 0;
        end
    end

%% OUTPUT1_CALLBACK
    function output1_callback(hObject,~,~)
        if (get(hObject,'Value'))
            bitalinoObj.writeDigitalPins({'D0'},{1})
        else
            bitalinoObj.writeDigitalPins({'D0'},{0})
        end
    end

%% OUTPUT2_CALLBACK
    function output2_callback(hObject,~,~)
        if (get(hObject,'Value'))
            bitalinoObj.writeDigitalPins({'D1'},{1});
        else
            bitalinoObj.writeDigitalPins({'D1'},{0});
        end
    end

%% FUNCTION SCALEDATA
% 'Unused','Raw','EMG','ECG','EDA','ACC','LUX'
    function convertedData = scaleData(hObject,rawData)
        convertedData=zeros(1,numel(rawData));
        if hObject.Value==1
            % Unused | all values are 0.
        elseif hObject.Value==2
            % Raw | data does not change.
            convertedData = rawData;
        elseif hObject.Value==3
            % EMG | converts to mV [-1.65 1.65]
            for i=1:length(rawData)
                convertedData(i)= ((rawData(i)/((2^10)-1)-0.5)*3.3/1000);
            end
        elseif hObject.Value==4
            % ECG | converts to mV [-1.5 1.5]
            for i=1:length(rawData)
                convertedData(i)= ((rawData(i)/((2^10)-1)-0.5)*3.3/1100);
            end
        elseif hObject.Value==5
            % EDA | converts to mega-Ohms [1 infinity]
            for i=1:length(rawData)
                convertedData(i)=1/(1-(rawData(i)/((2^10)-1)));
            end
        elseif hObject.Value==6
            % ACC | converts to g-force [-3 3]
            for i=1:length(rawData)
            convertedData(i)=(((rawData(i)-208)/104)*2) - 1;
            end
        elseif hObject.Value==7
            % LUX | converts to percentage [0 100]
            for i=1:length(rawData)
            convertedData(i)=(rawData(i)/((2^10) - 1))*100;
            end
        end        
    end

%% TIMERUPDATEFCN
    function timerFcn_callback(~,~,~)
        % reads data from buffer
        rawData = read(bitalinoObj);
        
        % Scales data according to factor selected on dropdown menu
        channel1Data = scaleData(channel0Dropdown,rawData(:,6)');
        channel1Data = [get(channel0Plot,'YData') channel1Data];        
        channel2Data = scaleData(channel1Dropdown,rawData(:,7)');
        channel2Data = [get(channel1Plot,'YData') channel2Data];        
        channel3Data = scaleData(channel2Dropdown,rawData(:,8)');
        channel3Data = [get(channel2Plot,'YData') channel3Data];        
        channel4Data = scaleData(channel3Dropdown,rawData(:,9)');
        channel4Data = [get(channel3Plot,'YData') channel4Data];
        
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
        
        % changes input signs according input states
        if (size(rawData,1)>0)
            if rawData(end,2)
                set(input1,'String','Digital Input 1: ON','BackgroundColor','green');
            else
                set(input1,'String','Digital Input 1: OFF','BackgroundColor','red');
            end            
            if rawData(end,3)
                set(input2,'String','Digital Input 2: ON','BackgroundColor','green');
            else
                set(input2,'String','Digital Input 2: OFF','BackgroundColor','red');
            end
        end

        refreshdata;
        drawnow;
    end
end