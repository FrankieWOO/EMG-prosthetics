function [ emg ] = adc2emg( adc )
%   ADC2EMG convert raw ADC data to EMG (mV)
%   created by Fan on 1/2/2017
%   VCC: operating voltage
%   sensor_gain
    VCC = 3.3;
    sensor_gain = 1000;
    emg = (adc/1023 - 0.5)*VCC*1000/sensor_gain;
end

