close all 
clear all 

%% Trial multiclass classifier
%% Experiment Value
% Sampling rate 1000Hz
movel = 3000 ; %Length of a movement /// 1 Movement = 2 sec rest + 1 sec action
actionl = 1000 ; %length of 1 action : 1000 set

%% Fist Data
T=readtable('fist4__20161122_17h54m53s.txt','Delimiter','tab','ReadVariableNames',false,'HeaderLines',3);
T=T(:,[1:8]);
T.Properties.VariableNames = {'SeqN', 'Digital0', 'Digital1', 'Digital2', 'Digital3', 'EMG1', 'EMG2', 'EMG3'};
Channel1 = T(:,6);
Channel2 = T(:,7);
Channel3 = T(:,8);

% Turning Values into mV (http://bitalino.com/datasheets/EMG_Sensor_Datasheet.pdf)
EMGV1 = (((Channel1{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV2 = (((Channel2{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV3 = (((Channel3{:,1}/(2^10))-1/2)*3.3)/1000;

%Final EMG Value in mV
EMG1F= EMGV1*1000;
EMG2F= EMGV2*1000;
EMG3F= EMGV3*1000;
lF=length(EMG2F);

EMG1F=EMG1F(1066:lF);
EMG2F=EMG2F(1066:lF);
EMG3F=EMG3F(1066:lF);

for i=1:20
   trimcutEMG_F1(i,:) = EMG1F(movel*i-actionl:movel*i);
   trimcutEMG_F2(i,:) = EMG2F(movel*i-actionl:movel*i);
   trimcutEMG_F3(i,:) = EMG3F(movel*i-actionl:movel*i);
end

%% Index Data
T=readtable('index3__20161122_18h07m45s.txt','Delimiter','tab','ReadVariableNames',false,'HeaderLines',3);
T=T(:,[1:8]);
T.Properties.VariableNames = {'SeqN', 'Digital0', 'Digital1', 'Digital2', 'Digital3', 'EMG1', 'EMG2', 'EMG3'};
Channel1 = T(:,6);
Channel2 = T(:,7);
Channel3 = T(:,8);

% Turning Values into mV (http://bitalino.com/datasheets/EMG_Sensor_Datasheet.pdf)
EMGV1 = (((Channel1{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV2 = (((Channel2{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV3 = (((Channel3{:,1}/(2^10))-1/2)*3.3)/1000;

%Final EMG Value in mV
EMG1I= EMGV1*1000;
EMG2I= EMGV2*1000;
EMG3I= EMGV3*1000;
lI=length(EMG2I);

EMG1I=EMG1I(552:lI);
EMG2I=EMG2I(552:lI);
EMG3I=EMG3I(552:lI);

for i=1:20
   trimcutEMG_I1(i,:) = EMG1I(movel*i-actionl:movel*i);
   trimcutEMG_I2(i,:) = EMG2I(movel*i-actionl:movel*i);
   trimcutEMG_I3(i,:) = EMG3I(movel*i-actionl:movel*i);
end

%% Wrist Flexion Data
T=readtable('wf__20161122_18h10m51s.txt','Delimiter','tab','ReadVariableNames',false,'HeaderLines',3);
T=T(:,[1:8]);
T.Properties.VariableNames = {'SeqN', 'Digital0', 'Digital1', 'Digital2', 'Digital3', 'EMG1', 'EMG2', 'EMG3'};
Channel1 = T(:,6);
Channel2 = T(:,7);
Channel3 = T(:,8);

% Turning Values into mV (http://bitalino.com/datasheets/EMG_Sensor_Datasheet.pdf)
EMGV1 = (((Channel1{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV2 = (((Channel2{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV3 = (((Channel3{:,1}/(2^10))-1/2)*3.3)/1000;

%Final EMG Value in mV
EMG1Wf= EMGV1*1000;
EMG2Wf= EMGV2*1000;
EMG3Wf= EMGV3*1000;
lWf=length(EMG2Wf);

EMG1Wf=EMG1Wf(343:lWf);
EMG2Wf=EMG2Wf(343:lWf);
EMG3Wf=EMG3Wf(343:lWf);

for i=1:20
   trimcutEMG_F1Wf(i,:) = EMG1Wf(movel*i-actionl:movel*i);
   trimcutEMG_F2Wf(i,:) = EMG2Wf(movel*i-actionl:movel*i);
   trimcutEMG_F3Wf(i,:) = EMG3Wf(movel*i-actionl:movel*i);
end


%% Wrist extension Data
T=readtable('we2__20161122_17h59m03s.txt','Delimiter','tab','ReadVariableNames',false,'HeaderLines',3);
T=T(:,[1:8]);
T.Properties.VariableNames = {'SeqN', 'Digital0', 'Digital1', 'Digital2', 'Digital3', 'EMG1', 'EMG2', 'EMG3'};
Channel1 = T(:,6);
Channel2 = T(:,7);
Channel3 = T(:,8);

% Turning Values into mV (http://bitalino.com/datasheets/EMG_Sensor_Datasheet.pdf)
EMGV1 = (((Channel1{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV2 = (((Channel2{:,1}/(2^10))-1/2)*3.3)/1000;
EMGV3 = (((Channel3{:,1}/(2^10))-1/2)*3.3)/1000;

%Final EMG Value in mV
EMG1We= EMGV1*1000;
EMG2We= EMGV2*1000;
EMG3We= EMGV3*1000;
lWe=length(EMG2We);  

EMG1We=EMG1We(667:lWe);
EMG2We=EMG2We(667:lWe);
EMG3We=EMG3We(667:lWe);

for i=1:20
   trimcutEMG_F1We(i,:) = EMG1We(movel*i-actionl:movel*i);
   trimcutEMG_F2We(i,:) = EMG2We(movel*i-actionl:movel*i);
   trimcutEMG_F3We(i,:) = EMG3We(movel*i-actionl:movel*i);
end


%% Features extraction

% x11 = mean(abs(trimcutEMG_F2),2)+mean(abs(trimcutEMG_F1),2)+mean(abs(trimcutEMG_F3),2);
% x12 = median(abs(trimcutEMG_F2),2)+median(abs(trimcutEMG_F1),2)+median(abs(trimcutEMG_F3),2);
% 
% x21 = mean(abs(trimcutEMG_I2),2)+mean(abs(trimcutEMG_I1),2)+mean(abs(trimcutEMG_I3),2);
% x22 = median(abs(trimcutEMG_I2),2)+median(abs(trimcutEMG_I1),2)+median(abs(trimcutEMG_I3),2);
% 
% x31 = mean(abs(trimcutEMG_F1Wf),2)+mean(abs(trimcutEMG_F2Wf),2)+mean(abs(trimcutEMG_F3Wf),2);
% x32 = median(abs(trimcutEMG_F1Wf),2)+median(abs(trimcutEMG_F2Wf),2)+median(abs(trimcutEMG_F3Wf),2);
% 
% x41 = mean(abs(trimcutEMG_F2We),2)+mean(abs(trimcutEMG_F3We),2)+mean(abs(trimcutEMG_F1We),2);
% x42 = median(abs(trimcutEMG_F2We),2)+median(abs(trimcutEMG_F3We),2)+median(abs(trimcutEMG_F1We),2);

x11 = mean(abs(trimcutEMG_F2),2);
x12 = median(abs(trimcutEMG_F2),2);

x21 = mean(abs(trimcutEMG_I2),2);
x22 = median(abs(trimcutEMG_I2),2);

x31 = mean(abs(trimcutEMG_F2Wf),2);
x32 = median(abs(trimcutEMG_F2Wf),2);

x41 = mean(abs(trimcutEMG_F2We),2);
x42 = median(abs(trimcutEMG_F2We),2);

X= [x11,x12;x21,x22;x31,x32;x41,x42];
%% Parameter optimization

% gamma=[20 15 10 5 1 0.5]; % I began with a wider range of gamma and C
% C=[85 90 95 100 110 115];
% 
%  for m=1:6
%      for n=1:6
%         for k= 1:10
% rnum = randperm(20);
% 
% %% Features for training
% for i=1:10
% x11train(i,1) = x11(rnum(1,i),1);
% x21train(i,1) = x21(rnum(1,i),1);
% x12train(i,1) = x12(rnum(1,i),1);
% x22train(i,1) = x22(rnum(1,i),1);
% 
% x31train(i,1) = x31(rnum(1,i),1);
% x32train(i,1) = x32(rnum(1,i),1);
% x41train(i,1) = x41(rnum(1,i),1);
% x42train(i,1) = x42(rnum(1,i),1);
% end
% %% Features for testing 
% for i=11:20
% x11test(i-10,1) = x11(rnum(1,i),1);
% x21test(i-10,1) = x21(rnum(1,i),1);
% x12test(i-10,1) = x12(rnum(1,i),1);
% x22test(i-10,1) = x22(rnum(1,i),1);
% 
% x31test(i-10,1) = x31(rnum(1,i),1);
% x32test(i-10,1) = x32(rnum(1,i),1);
% x41test(i-10,1) = x41(rnum(1,i),1);
% x42test(i-10,1) = x42(rnum(1,i),1);
% end
% 
% Xtest = [x11test,x12test;x21test,x22test;x31test,x32test;x41test,x42test];
% Xtrain = [x11train,x12train;x21train,x22train;x31train,x32train;x41train,x42train];
% 
% labels = [ones(10,1);-1*ones(10,1);2*ones(10,1);3*ones(10,1)];
% T=templateSVM('KernelFunction','gaussian','Standardize' ,true,'KernelScale',gamma(m),'BoxConstraint',C(n));
% 
% SVMModel=fitcecoc(Xtrain,labels,'Coding','onevsone','Learners',T);
% 
% CVM=crossval(SVMModel);
% LSVM(k,1)=kfoldLoss(CVM);
% 
% 
% resultstrain = predict(SVMModel,Xtrain);
% training_accuracy=100*(sum(resultstrain==labels)/length(labels)) ;
% 
% resultstest = predict(SVMModel,Xtest);
% testing_accuracy =100*(sum(resultstest==labels)/length(labels)) ;
% 
%  rtable(k,1)= training_accuracy;
%  rtable(k,2)= testing_accuracy;
% 
%         end
%         %% Calculate mean
% meanLSVM(m,n)=mean(LSVM(:,1));
% 
% meantraining(m,n)=mean(rtable(:,1));
% stdtrain(m,n) = std(rtable(:,1));
% 
% %disp(['Mean Training accuracy is ' num2str(meantraining) '+/-' num2str(stdtrain)])
% 
% meantesting(m,n)=mean(rtable(:,2));
% stdtest(m,n) = std(rtable(:,2));
% %disp(['Mean testing accuracy is ' num2str(meantesting) '+/-' num2str(stdtest) ]);
%      end
%  end

%% With Optimized Param
gamma=1;
C=95;
 for k= 1:10
rnum = randperm(20);

%% Features for training
for i=1:10
x11train(i,1) = x11(rnum(1,i),1);
x21train(i,1) = x21(rnum(1,i),1);
x12train(i,1) = x12(rnum(1,i),1);
x22train(i,1) = x22(rnum(1,i),1);

x31train(i,1) = x31(rnum(1,i),1);
x32train(i,1) = x32(rnum(1,i),1);
x41train(i,1) = x41(rnum(1,i),1);
x42train(i,1) = x42(rnum(1,i),1);
end
%% Features for testing 
for i=11:20
x11test(i-10,1) = x11(rnum(1,i),1);
x21test(i-10,1) = x21(rnum(1,i),1);
x12test(i-10,1) = x12(rnum(1,i),1);
x22test(i-10,1) = x22(rnum(1,i),1);

x31test(i-10,1) = x31(rnum(1,i),1);
x32test(i-10,1) = x32(rnum(1,i),1);
x41test(i-10,1) = x41(rnum(1,i),1);
x42test(i-10,1) = x42(rnum(1,i),1);
end

Xtest = [x11test,x12test;x21test,x22test;x31test,x32test;x41test,x42test];
Xtrain = [x11train,x12train;x21train,x22train;x31train,x32train;x41train,x42train];

labels = [ones(10,1);-1*ones(10,1);2*ones(10,1);3*ones(10,1)];
T=templateSVM('KernelFunction','gaussian','Standardize' ,true,'KernelScale',gamma,'BoxConstraint',C);

SVMModel=fitcecoc(Xtrain,labels,'Coding','onevsone','Learners',T);

CVM=crossval(SVMModel);
LSVM=kfoldLoss(CVM);


resultstrain = predict(SVMModel,Xtrain);
training_accuracy=100*(sum(resultstrain==labels)/length(labels)) ;

resultstest = predict(SVMModel,Xtest);
testing_accuracy =100*(sum(resultstest==labels)/length(labels)) ;

 rtable(k,1)= training_accuracy;
 rtable(k,2)= testing_accuracy;

        end
        %% Calculate mean
meantraining=mean(rtable(:,1));
stdtrain = std(rtable(:,1));

%disp(['Mean Training accuracy is ' num2str(meantraining) '+/-' num2str(stdtrain)])

meantesting=mean(rtable(:,2));
stdtest= std(rtable(:,2));

%disp(['Mean testing accuracy is ' num2str(meantesting) '+/-' num2str(stdtest) ]);

        %% Plot Points 
figure(3);clf; hold on; xlabel('Feature 1'); ylabel('Feature 2'); %ylim([0.007 0.04])
gscatter(Xtrain(:,1),Xtrain(:,2),labels)

%Plot the Test point
i=find(resultstest ==1);
scatter(Xtest(i,1),Xtest(i,2),'go')
i=find(resultstest ==-1);
scatter(Xtest(i,1),Xtest(i,2),'ro')
i=find(resultstest ==2);
scatter(Xtest(i,1),Xtest(i,2),'co')
i=find(resultstest ==3);
scatter(Xtest(i,1),Xtest(i,2),'bo')


% sv = SVMModel.SupportVectors;
% scatter(sv(:,1),sv(:,2),'+') % this doesn't work, as the SVs are standardised, and the points are not
% legend('C1','C2','Support Vector')

%% Find missmatches
% find(labels'-resultstest'>0)

%% plot boundary
x1plane = min(X(:,1)):0.001:max(X(:,1));
x2plane = min(X(:,2)):0.001:max(X(:,2));
[xv,yv]=meshgrid(x1plane,x2plane);
plot_points =[xv(:),yv(:)];
vpredict = predict(SVMModel,plot_points);

gscatter(xv(:),yv(:),vpredict)
