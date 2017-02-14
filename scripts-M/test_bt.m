% test Bitalino class
% created by Fan on 1/2/2017

btinfo = instrhwinfo('Bluetooth');

% lookup bluetooth devices' names and IDs
btinfo.RemoteNames
btinfo.RemoteIDs

% lookup device properties
%instrhwinfo('bluetooth','BITalino-15-11')


bt = Bitalino('BITalino-15-11',100); % create Bitalino object given remoteName
%%
startBackground(bt) % start background data streaming
tic
%%
bt.AvailableSamples % show the number of available samples in buffer
% read data from raw dataFrame, columns of data are...resorted, 4 chanels 
% start from 6th to 9th 
data2 = read(bt); 
toc
%%
stopBackground(bt) % stop background data streaming
%%
delete(bt) % delete object