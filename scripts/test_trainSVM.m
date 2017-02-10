%%  set username and movement
user = 'Fan';
movement = 'fist'; 
trialNo = [1,2,3,4];
%% plot and choose TH
nfiles = length(trialNo);
dataset = cell(nfiles,1); msa = cell(nfiles,1);data=[];
for i=1:nfiles
filename = ['data/' user '/record/' movement '_trial' trialNo(i) '.csv'];
dataset{i} = readtable(filename);
msa{i} = msavg(table2array(dataset{i}),200);
data = cat(1,data,table2array(dataset{i}));
figure
plot(msa{i})
end

%% Choose TH and do segmentation
% set TH by observing the plot
TH = 0.5 ;
segments = emgSegment(data,TH);

%%
save(['data/' user '/train/' movement '.mat'],segments)