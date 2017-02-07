function [ segments ] = emgSegment( data )
%EMGSEGMENT segmentation of EMG time series data (datatable) into segments
%   data: datatable, columns are the channels
%   return segments: matrix
%   created by Fan on 4/2/2017
%   segmentation method refers to Wang2007, An Adaptive Feature Extractor
%   for Gesture SEMG Recognition
    window = 50;    %sliding window for moving average
    thredshold = 0.0001;   %thredshold value to select segment
    
    if (istable(data))
        data_mat = table2array(data);
    else
        data_mat = data;
    end
    
    emg_savg = mean(data_mat,2).^2; % squared mean
    emg_mavg = tsmovavg(emg_savg,'s',window,1);
    emg_rect = emg_mavg.*(emg_mavg > thredshold);
    
    flag_start = zeros(length(emg_rect),1); 
    flag_end = zeros(length(emg_rect),1); 
    flag_seg = 0;
    for i=1:length(emg_rect)
        if(flag_seg ==0 )
            if(emg_rect(i)>0)
                flag_start(i) = 1;
                flag_seg = 1;
            end
        elseif(emg_rect(i)==0)
            flag_end(i-1) = 1;
            flag_seg = 0;
        elseif (i==length(emg_rect))
            flag_end(i) = 1;flag_seg = 0;
        end
    end
    
    ind_start = find(flag_start==1);
    ind_end = find(flag_end ==1);
    if (length(ind_start) ~= length(ind_end))
       error('segmentation wrong, starts and ends donot match.'); 
    end
    nSample = length(ind_start);
    segments = cell(nSample,1);
    for j=1:nSample
       segments{j} =  data_mat(ind_start(j):ind_end(j),:);
    end
    l=length(segments);
    
    for m=l:-1:1
        if (size(segments{m},1)<900)
        segments(m)=[];
        end
    end
    
end