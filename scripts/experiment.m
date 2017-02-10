
dataRecordApp

%%

userName = 'Sam';   % put the user's name here
classifierObj = emgClassifier(userName);
trainSVM(classifierObj)

%%
mac = '201607181511';
handControlObj = handControl(userName,mac,'COM7');
% start realtime processing

%%

start(handControlObj)

%% stop realtime processing
%stop(handControlObj)
%%
% delete the object when finish
%delete(handControlObj)
%clear('handControlObj')