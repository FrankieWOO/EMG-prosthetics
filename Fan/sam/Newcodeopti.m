close all 
clear all 

%% Experiment Value
% Sampling rate 2000Hz
% Rows = EMG Samples
% Column = EMG Channels

%% Amputee A1 data of channel 1

[F1,f1] = newcutdataamp('A1_Ball_high_t1.mat',1,1); 
[F2,f2] = newcutdataamp('A1_Ball_high_t2.mat',2,1); 
[F3,f3] = newcutdataamp('A1_Ball_high_t3.mat',3,1); 
[F4,f4] = newcutdataamp('A1_Ball_high_t4.mat',4,1); 
[F5,f5] = newcutdataamp('A1_Ball_high_t5.mat',5,1); 
[F6,f6] = newcutdataamp('A1_Ball_med_t1.mat',1,1); 
[F7,f7] = newcutdataamp('A1_Ball_med_t2.mat',2,1); 
[F8,f8] = newcutdataamp('A1_Ball_med_t3.mat',3,1); 
[F9,f9] = newcutdataamp('A1_Ball_med_t4.mat',4,1); 
[F10,f10] = newcutdataamp('A1_Ball_med_t5.mat',5,1); 
Ftot=fusion(F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10);

[I1,i1] = newcutdataamp('A1_Ind_high_t1.mat',1,1); 
[I2,i2] = newcutdataamp('A1_Ind_high_t2.mat',2,1); 
[I3,i3] = newcutdataamp('A1_Ind_high_t3.mat',3,1); 
[I4,i4] = newcutdataamp('A1_Ind_high_t4.mat',4,1); 
[I5,i5] = newcutdataamp('A1_Ind_high_t5.mat',5,1); 
[I6,i6] = newcutdataamp('A1_Ind_med_t1.mat',1,1); 
[I7,i7] = newcutdataamp('A1_Ind_med_t2.mat',2,1); 
[I8,i8] = newcutdataamp('A1_Ind_med_t3.mat',3,1); 
[I9,i9] = newcutdataamp('A1_Ind_med_t4.mat',4,1); 
[I10,i10] = newcutdataamp('A1_Ind_med_t5.mat',5,1); 
Itot=fusion(I1,I2,I3,I4,I5,I6,I7,I8,I9,I10,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10);
 
%% Choose some features for the learning

x11 = mean(abs(Ftot),2);
x21 = mean(abs(Itot),2);
x12 = median(abs(Ftot),2);
x22 = median(abs(Itot),2);
X = [x11,x12;x21,x22];

%Test 
% i=3;
% xsort=x11(i,1);
% xlol=x11;
% % x11(i,1)=0;
% x11=x11(x11~=xsort);
% l=length(x11);


%% Optimization of parameters NUMBER 1

% for m=1:6
%     for n=1:6
%                 %(de 0.001 a 100)
%         for k= 1:10
% %% Features for training
% x11train = x11(x11~=x11(k,1),1);
% x21train = x21(x21~=x21(k,1),1);
% x12train = x12(x12~=x12(k,1),1);
% x22train = x22(x22~=x22(k,1),1);
% 
% x11test = x11(k,1);
% x21test = x21(k,1);
% x12test = x12(k,1);
% x22test = x22(k,1);
% 
% Xtest = [x11test,x12test;x21test,x22test];
% %% Visualisation features
% 
% % xvisumean= [x11;x21];
% % xvisumedian= [x12;x22];
% % 
% % figure(1);
% % plot(xvisumean);
% % figure(2);
% % plot(xvisumedian);
% 
% %% compute a rbf classifier
% Xtrain = [x11train,x12train;x21train,x22train];
% labels = [ones(9,1);-1*ones(9,1)];
% labelstest=[1;-1];
% 
% %SVMModel = fitcsvm(Xtrain,labels,'KernelFunction','rbf','Standardize',true','KernelScale','auto','OutlierFraction',0.05);  
% SVMModel = fitcsvm(Xtrain,labels,'KernelFunction','gaussian','Standardize',true','KernelScale',0.0001*10^m,'BoxConstraint',0.0001*10^n);
% % this wasn't working before because the data wasn't standardised. To standardise, each collumn is mean shifited
% % http://uk.mathworks.com/help/stats/fitcsvm.html#inputarg_Standardize
% % Estimate loss, should be no greater than 0.05%
% % CVSVMModel = crossval(SVMModel);
% %classLossT(m,n) = kfoldLoss(CVSVMModel);
% 
% resultstrain = predict(SVMModel,Xtrain);
% training_accuracy=100*(sum(resultstrain==labels)/length(labels)) ;
% %disp(['Training accuracy is ' num2str(training_accuracy) '%']);
% resultstest = predict(SVMModel,Xtest);
% testing_accuracy =100*(sum(resultstest==labelstest)/length(labelstest)) ;
% %disp(['Testing accuracy is ' num2str(testing_accuracy) '%']);
% %res= [training_accuracy,testing_accuracy];
% 
%  rtable(k,1)= training_accuracy;
%  rtable(k,2)= testing_accuracy;
%         end
% 
% %% Calculate mean
% meantraining(m,n)=mean(rtable(:,1));
% stdtrain(m,n) = std(rtable(:,1));
% 
% %disp(['Mean Training accuracy is ' num2str(meantraining) '+/-' num2str(stdtrain)])
% 
% meantesting(m,n)=mean(rtable(:,2));
% stdtest(m,n) = std(rtable(:,2));
% %disp(['Mean testing accuracy is ' num2str(meantesting) '+/-' num2str(stdtest) ]);
%     end
% end

%% Optimization of parameters NUMBER 2

% for m=1:6
%     for n=1:6
%                 %(de 0.001 a 100)
%         for k= 1:10
% %% Features for training
% rnum = randperm(10);
% for i=1:5
% x11train(i,1) = x11(rnum(1,i),1);
% x21train(i,1) = x21(rnum(1,i),1);
% x12train(i,1) = x12(rnum(1,i),1);
% x22train(i,1) = x22(rnum(1,i),1);
% end
% %% Features for testing 
% for i=6:10
% x11test(i-5,1) = x11(rnum(1,i),1);
% x21test(i-5,1) = x21(rnum(1,i),1);
% x12test(i-5,1) = x12(rnum(1,i),1);
% x22test(i-5,1) = x22(rnum(1,i),1);
% end
% 
% Xtest = [x11test,x12test;x21test,x22test];
% %% Visualisation features
% 
% % xvisumean= [x11;x21];
% % xvisumedian= [x12;x22];
% % 
% % figure(1);
% % plot(xvisumean);
% % figure(2);
% % plot(xvisumedian);
% 
% %% compute a rbf classifier
% Xtrain = [x11train,x12train;x21train,x22train];
% labels = [ones(5,1);-1*ones(5,1)];
% 
% 
% %SVMModel = fitcsvm(Xtrain,labels,'KernelFunction','rbf','Standardize',true','KernelScale','auto','OutlierFraction',0.05);  
% SVMModel = fitcsvm(Xtrain,labels,'KernelFunction','gaussian','Standardize',true','KernelScale',0.0001*10^m,'BoxConstraint',0.0001*10^n);
% % this wasn't working before because the data wasn't standardised. To standardise, each collumn is mean shifited
% % http://uk.mathworks.com/help/stats/fitcsvm.html#inputarg_Standardize
% % Estimate loss, should be no greater than 0.05%
% % CVSVMModel = crossval(SVMModel);
% %classLossT(m,n) = kfoldLoss(CVSVMModel);
% 
% resultstrain = predict(SVMModel,Xtrain);
% training_accuracy=100*(sum(resultstrain==labels)/length(labels)) ;
% %disp(['Training accuracy is ' num2str(training_accuracy) '%']);
% resultstest = predict(SVMModel,Xtest);
% testing_accuracy =100*(sum(resultstest==labels)/length(labels)) ;
% %disp(['Testing accuracy is ' num2str(testing_accuracy) '%']);
% %res= [training_accuracy,testing_accuracy];
% 
%  rtable(k,1)= training_accuracy;
%  rtable(k,2)= testing_accuracy;
%         end
% 
% %% Calculate mean
% meantraining(m,n)=mean(rtable(:,1));
% stdtrain(m,n) = std(rtable(:,1));
% 
% %disp(['Mean Training accuracy is ' num2str(meantraining) '+/-' num2str(stdtrain)])
% 
% meantesting(m,n)=mean(rtable(:,2));
% stdtest(m,n) = std(rtable(:,2));
% %disp(['Mean testing accuracy is ' num2str(meantesting) '+/-' num2str(stdtest) ]);
%     end
% end

%% Classifier with the optimized param
gamma=1;
C=0.1;

for k= 1:10
rnum = randperm(10);

%% Features for training
for i=1:7
x11train(i,1) = x11(rnum(1,i),1);
x21train(i,1) = x21(rnum(1,i),1);
x12train(i,1) = x12(rnum(1,i),1);
x22train(i,1) = x22(rnum(1,i),1);
end
%% Features for testing 
for i=8:10
x11test(i-7,1) = x11(rnum(1,i),1);
x21test(i-7,1) = x21(rnum(1,i),1);
x12test(i-7,1) = x12(rnum(1,i),1);
x22test(i-7,1) = x22(rnum(1,i),1);
end

Xtest = [x11test,x12test;x21test,x22test];
%% Visualisation features

% xvisumean= [x11;x21];
% xvisumedian= [x12;x22];
% 
% figure(1);
% plot(xvisumean);
% figure(2);
% plot(xvisumedian);

%% compute a rbf classifier
Xtrain = [x11train,x12train;x21train,x22train];
labels = [ones(7,1);-1*ones(7,1)];
labelstest = [ones(3,1);-1*ones(3,1)];
%SVMModel = fitcsvm(Xtrain,labels,'KernelFunction','rbf','Standardize',true','KernelScale','auto','OutlierFraction',0.05);  
SVMModel = fitcsvm(Xtrain,labels,'KernelFunction','gaussian','Standardize',true','KernelScale',gamma,'BoxConstraint',C);
% this wasn't working before because the data wasn't standardised. To standardise, each collumn is mean shifited
% http://uk.mathworks.com/help/stats/fitcsvm.html#inputarg_Standardize
% Estimate loss, should be no greater than 0.05%
% CVSVMModel = crossval(SVMModel);
%classLossT(m,n) = kfoldLoss(CVSVMModel);

resultstrain = predict(SVMModel,Xtrain);
training_accuracy=100*(sum(resultstrain==labels)/length(labels)) ;
%disp(['Training accuracy is ' num2str(training_accuracy) '%']);
resultstest = predict(SVMModel,Xtest);
testing_accuracy =100*(sum(resultstest==labelstest)/length(labelstest)) ;
%disp(['Testing accuracy is ' num2str(testing_accuracy) '%']);
%res= [training_accuracy,testing_accuracy];

 rtable(k,1)= training_accuracy;
 rtable(k,2)= testing_accuracy;
end
%% Calculate mean
meantraining = mean(rtable(:,1));
stdtrain = std(rtable(:,1));
disp(['Mean Training accuracy is ' num2str(meantraining) '+/-' num2str(stdtrain)])

meantesting =mean(rtable(:,2));
stdtest = std(rtable(:,2));
disp(['Mean testing accuracy is ' num2str(meantesting) '+/-' num2str(stdtest) ]);
 

%% Plot the data, and the classification regions
figure(3);clf; hold on; xlabel('Feature 1'); ylabel('Feature 2'); %ylim([0.007 0.04])
gscatter(Xtrain(:,1),Xtrain(:,2),labels)

%Plot the Test point
i=find(resultstest ==1);
scatter(Xtest(i,1),Xtest(i,2),'co')
i=find(resultstest ==-1);
scatter(Xtest(i,1),Xtest(i,2),'ro')
% 
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
