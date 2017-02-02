% test Bitalino class
% created by Fan on 1/2/2017

btinfo = instrhwinfo('Bluetooth');

% lookup bluetooth devices' names and IDs
btinfo.RemoteNames
btinfo.RemoteIDs

% lookup device properties
%instrhwinfo('bluetooth','BITalino-15-11')


b = Bitalino('BITalino-15-11'); % create Bitalino object given remoteName
startBackground(b) % start background data streaming

b.AvailableSamples % show the number of available samples in buffer
% read data from raw dataFrame, columns of data are...resorted, 4 chanels 
% start from 6th to 9th 
data = read(b); 

stopBackground(b) % stop background data streaming

delete(b) % delete object