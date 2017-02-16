function [trainingaccuracyT,testingaccuracyT] = parameteropt(features,labelnames)
%SVM parameter optimization function
%features = feature table 
%trainingaccuracy and testing accuracy = table containing accuracy for a
%given pair of C and gamma
% Reference : A Practical Guide to Support Vector Classication by Chih-Wei Hsu, Chih-Chung Chang, and Chih-Jen

%Call in main program using: [table1,table2] = parameteropt(features,labelnames);
% and pick the manually the pair of C and gamma that has the best testing
% accuracy

nClass = size(features,1);

%2 Optmization parameters : gamma and C, the gaussian width and the
%penalization parameter
%gamma is KernelScale , C is BoxConstraint

%The column of the accuracy table are gamma and the rows are C
for k= -3 : 3
    for j= -3 : 3
C=10^(k);
gamma=10^(j);
for g= 1 : 10 % Here we want to use 
training_featureMatrix = []; training_labelVector = [];
testing_featureMatrix = []; testing_labelVector = [];
 for i = 1:nClass
                feT = cell2mat(features{i,1});   
                l=size(features{i,1},1);
                testing_samples=floor(l*0.1);
                % we take 10% of the data for the 
                testing_matrix = feT(g*testing_samples-testing_samples+1:g*testing_samples,:);
                training_matrix = feT;
                training_matrix(g*testing_samples-testing_samples+1:g*testing_samples,:)=[];
                
                training_featureMatrix = cat(1,training_featureMatrix,training_matrix);
                testing_featureMatrix = cat(1,testing_featureMatrix,testing_matrix);
           
                training_labelVector = cat(1,training_labelVector,labelnames.label(i)*ones(size(training_matrix,1),1));
                testing_labelVector = cat(1,testing_labelVector,labelnames.label(i)*ones(size(testing_matrix,1),1));
 end %end features split
  T=templateSVM('KernelFunction','gaussian','Standardize' ,true,'KernelScale',gamma,'BoxConstraint',C);
  SVMModel=fitcecoc(training_featureMatrix,training_labelVector,'Coding','onevsone','Learners',T);
  
  predicttrain=predict(SVMModel,training_featureMatrix);
  trainingaccuracy(g) = 100*(sum(predicttrain==training_labelVector)/length(training_labelVector));
            
  predicttest=predict(SVMModel,testing_featureMatrix);
  testingaccuracy(g) = 100*(sum(predicttest==testing_labelVector)/length(testing_labelVector));
  
end % end crossvalidation
 TableTraining(4+k,4+j) = mean(trainingaccuracy);
 TableTesting(4+k,4+j)= mean(testingaccuracy);
    end % end gamma loop
end %end C loop

trainingaccuracyT = TableTraining;
testingaccuracyT = TableTesting;
end