
clear;clc;clear java;
% For Matlab versions previous to 2010, run these lines:
javaaddpath(fullfile('/lib/bluecove-2.1.1-SNAPSHOT.jar'));
javaaddpath(fullfile('/lib'));

%%

mac = '201607181511';
SamplingRate = 1000;
analogChannels = [0 1 2 3];
nSamples = 100;

bit = bitalino();

% Open bluetooth connection with bitalino
bit = bit.open(mac,SamplingRate);
%%
% while 1
if bit.connection
    % get bitalino version
    bit.version();
    pause(0.5);
    %start acquisition on channel A4
    bit = bit.start(analogChannels);
    disp('Start Acquisition')
    pause(0.1);
    tic
    n = bit.iStream.available()/7;
    % read samples
    data = bit.read(n);
    toc
    disp('Data read')
    %stop acquisition
    bit.stop();
    
    %plot channel acquired
    %plot(data(6,:))
end

%%
%close connection
bit.close();




