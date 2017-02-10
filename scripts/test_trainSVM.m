%%  set username and movement
user = 'Sam';
movement = 'fist'; 
filename = ['data/' user '/train/' point '.csv'];
%% plot and choose TH
data = readtable(filename);
msa = msavg(table2array(data),200);
plot(msa)
%% Choose TH and do segmentation
% set TH by observing the plot
TH = 0.5 ;
segments = emgSegment(data,TH);

%%
save(['data/' user '/train/' point '.mat'],segments)