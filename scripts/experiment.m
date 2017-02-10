

userName = 'Fan';
samplingRate = 100;
%%

dataRecordApp

%% run dataprocess procedures


%% train model

   % put the user's name here
classifierObj = emgClassifier(userName,samplingRate);
trainSVM(classifierObj)

%%
mac = '201607181511';
handControlObj = handControl(userName,mac,'COM7',100);
% start realtime processing

%%

start(handControlObj)

%% stop realtime processing
stop(handControlObj)
%%
% delete the object when finish
delete(handControlObj)
clear('handControlObj')