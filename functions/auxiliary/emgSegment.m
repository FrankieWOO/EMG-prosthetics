function [ segments ] = emgSegment( data,method, TH ,sampleRate)
%EMGSEGMENT auto segmentation of EMG time series data (datatable) into segments
%   data: datatable, columns are the channels
%   return segments: matrix
%   created by Fan on 4/2/2017
%   segmentation method refers to Wang2007, An Adaptive Feature Extractor
%   for Gesture SEMG Recognition
    
    %trigger_thredshold = 0.0001;   %set default thredshold value to select segment
    %window_analysis = 200*obj.sampleRate/1000; % 200ms assuming sampling rate is 1000Hz
    contraction_length = 1000*sampleRate/1000;
    %silent_length = 2000*obj.sampleRate/1000; 
    
    if (istable(data))
        data_mat = table2array(data);
    elseif(ismatrix(data))
        data_mat = data;
    else
        error('Input format wrong!');
    end
    
%     emg_savg = mean(data_mat.^2,2).^0.5; % root mean of squared value
%     emg_mavg = tsmovavg(emg_savg,'s',window_ma,1);
%     trigger_thredshold = prctile(emg_savg(window_ma:silent_length),95);
%     disp('trigger thredshold of EMG signal is:')
%        disp(trigger_thredshold);
    if (strcmp(method,'thredshold'))
        window_ma = 200*sampleRate/1000;    %sliding window for moving average
        emg_mavg = msavg(data_mat,window_ma);
        emg_rect = emg_mavg.*(emg_mavg > TH);
    
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
    elseif (strcmp(method,'wave'))
        
    end
    selection_method = 1;
    switch selection_method
        case 1
            % if segment length less than contraction_length, abandon it
            for m=nSample:-1:1
                if (size(segments{m},1)<contraction_length)
                segments(m)=[];
                end
            end
        
        case 2
            % use analysis window to segment data
    end
    
end