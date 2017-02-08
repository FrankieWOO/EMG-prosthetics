% test handControl class
% created by Fan on 2/2/2017
% create handControl object
userName = 'Fan';   % put the user's name here
handControlObj = handControl(userName,'BITalino-15-11','COM');
% start realtime processing
start(handControlObj)

%% stop realtime processing
stop(handControlObj)
%%
% delete the object when finish
delete(handControlObj)
clear('handControlObj')