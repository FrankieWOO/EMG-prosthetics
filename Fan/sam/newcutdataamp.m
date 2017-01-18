function [C,l] = newcutdataamp(nfile,tnum,channel)

D1=load(nfile);
if tnum ==1
    D=D1.t1(:,channel);
elseif tnum ==2
    D=D1.t2(:,channel);
elseif tnum ==3
    D=D1.t3(:,channel);
elseif tnum ==4
    D=D1.t4(:,channel);
elseif tnum ==5
    D=D1.t5(:,channel);
end
D=D';
l= length(D);
C=D;
end
