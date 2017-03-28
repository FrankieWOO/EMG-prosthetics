function d = touchhand(reading)

if reading == 0
    fprintf('Palm relax');
    d = drivemotor(0.6,0.6,0,4);
elseif reading == 1
    fprintf('Fist flexion');
    d = drivemotor(0.8,0.8,0,6);
elseif reading == 2
    fprintf('Index pointing');
    d = drivemotor(0.2,0.8,0,6);
elseif reading == 3
    fprintf('Wrist extension');
    d = drivemotor(0.8,0.2,0,4);
elseif reading == 4
    fprintf('Wrist flexion');
    d = drivemotor(0.2,0.8,0,4);
elseif reading == 5
    fprintf('Grip it');
    d = drivemotor(0.8,0.2,0,6);
else
    fprintf('Unrecognized');
end
end

function drivemotor(i,m,t)
writePosition(index,i);
writePosition(middle,m);
writePosition(thumb,t);
end