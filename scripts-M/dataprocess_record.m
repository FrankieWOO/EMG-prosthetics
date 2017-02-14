%%  set username and movement
user = 'Fan';
movement = 'relax'; 
trialNo = [1];
sampleRate = 100;
%% plot and choose TH
nfiles = length(trialNo);
dataset = cell(nfiles,1); msa = cell(nfiles,1);data=[];
for i=1:nfiles
filename = ['data/' user '/record/' movement '_trial' num2str(trialNo(i)) '.csv'];
dataset{i} = readtable(filename);
msa{i} = msavg(table2array(dataset{i}),20);
data = cat(1,data,table2array(dataset{i}));
figure
plot(table2array(dataset{i}))
hold on
plot(msa{i})
hold off
end

%% Choose TH and do segmentation
% set TH by observing the plot
if(strcmp(movement,'relax'))
    window_analysis = 1000*sampleRate/1000;
    window_increment = 500*sampleRate/1000;
    nSegs = floor((size(data,1)-window_analysis)/window_increment + 1);
    segments = cell(nSegs,1);
    for i=1:nSegs
        segments{i} = data((i-1)*window_increment+1:(i-1)*window_increment+window_analysis,:);
    end
else
    % if not relax
    TH = 0.016 ;
    segments = emgSegment(data,'thredshold',TH,100);
end



%%
save(['data/' user '/train/' movement '.mat'],'segments')