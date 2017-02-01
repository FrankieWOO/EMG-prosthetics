%btinfo = instrhwinfo('Bluetooth');

% lookup bluetooth devices' names and IDs
%btinfo.RemoteNames
%btinfo.RemoteIDs

% lookup device properties
%instrhwinfo('bluetooth','BITalino-15-11')

b = Bitalino('BITalino-15-11');
startBackground(b)

b.AvailableSamples

stopBackground(b)

delete(b)