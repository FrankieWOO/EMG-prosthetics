% Control the actuator by Matlab
   % Install the support package first. (https://cn.mathworks.com/matlabcentral/fileexchange/47522?download=true)
   % Noticing: this program is suggested not to run directly.
   % The specific tutorial can be acquired by searching 'Control Servo Motors' in Mathwork.

%% Initialization 
a = arduino('COM9','uno'); % Connecting with the Arduinoboard.
index = servo(a,'D10','MinPulseDuration',1*10^-3,'MaxPulseDuration',2*10^-3); % Configure the pin
middle = servo(a,'D3','MinPulseDuration',1*10^-3,'MaxPulseDuration',2*10^-3);% The values of Max and Min are based on datasheet.
thumb = servo(a,'D9','MinPulseDuration',1*10^-3,'MaxPulseDuration',2*10^-3); 

%% Operations 
for angle = 0.2:0.1:0.8 % The area is between 0 and 1. According to the 3D-hand in lab, it should between 0.2 and 0.8.
                        % Thumb is arround 0.4 and 0.6, the structure seems has some problem.
    writePosition(middle,angle); % Drive the motors.
    current_pos=readPosition(middle);
    current_pos=current_pos*100 +160; 
    fprintf('Current motor position is %d degrees\n',current_pos);
    pause(2); % Pause 2 seconds.
end

%% Close all (COM)
%delete(instrfindall);
%clear s a
