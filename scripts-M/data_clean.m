% look at original data from bitalino record, trim it and save into backup

subject = 'S2';
subfolder = 'opensignal';
datafile = 's2-fabric-_WP.txt';
filepath = fullfile('data',subject,subfolder,datafile);
data = readtable(filepath,'ReadVariableNames',false,'HeaderLines',3);
data = data(:,6:9);
data = adc2emg(table2array(data));
plot(data)

%%
trim_start = 1600;
data_trim = data(trim_start:end,:);

%%
trial = 'trial1';
savename = [subject, '_fabric_',
savepath = fullfile('data','record',savename);