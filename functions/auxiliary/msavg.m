function [ mavg ] = msavg( data,window )
%MSAVG moving average of squared mean of 4 channels
%   data is matrix, each row is a sample
    savg = mean(data.^2,2).^0.5;
    mavg = tsmovavg(savg,'s',window,1);

end

