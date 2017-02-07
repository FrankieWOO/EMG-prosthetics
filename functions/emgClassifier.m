classdef emgClassifier < handle
    %EMGCLASSIFIER EMG classifier
    %   created by Fan on 3/2/2017
    
    properties
        userName;   % name of the user
        model;  % the trained model
        
    end
    
    methods
        function obj = emgClassifier(name)
            obj.userName = name;
            %obj.model = [];
        end
        function prepareModel(obj)
            try
                obj.model = emgClassifier.loadModel(obj.userName);
            catch
                error('loading model failed');
            end
        end
        function trainSVM(obj)
            % import train dataset, which is a cell array, each cell is a
            % datatable for one action
            trainData = emgClassifier.importTrainData(obj.userName);
            % segment the time series data into samples
            % samples are cell array where each cell is a sample
            % represented by a matrix
%             data1 = trainData{1};
%             data2 = trainData{2};
%             data3 = trainData{3};
%             data4 = trainData{4};
%             samples1 = emgSegment(data1);
%             samples2 = emgSegment(data2);
%             samples3 = emgSegment(data3);
%             samples4 = emgSegment(data4);
            samples = cellfun(@emgSegment,trainData);
            features = cell(size(samples));
            for i = 1:length(features)
                features{i} = cellfun(@extractFeatures,samples{i});
            end
            
           ffist = features{1,1};
           fpoint = features{2,1};
           fwristf = features{3,1};
           fwriste = features{4,1};
           
           % We keep Channel 1-4
           ffist = ffist(:,2:5);
           fpoint = fpoint(:,2:5);
           fwristf = fwristf(:,2:5);
           fwriste = fwriste(:,2:5);
           
           lf=height(ffist);
           lp= height(fpoint);
           lwf= height(fwristf);
           lwe= height(fwriste);
           
           X=[ffist;fpoint;fwristf;fwriste];
           labels = [ones(lf,1);2*ones(lp,1);3*ones(lwf,1);4*ones(lwe,1)];
           
           gamma=1;
           C=1;
           
           T=templateSVM('KernelFunction','gaussian','Standardize' ,true,'KernelScale',gamma,'BoxConstraint',C);
           SVMModel=fitcecoc(Xtrain,labels,'Coding','onevsone','Learners',T);
           
        end
        
        function resClass = recognize(obj,emgData)
            % window for computing features
            window = 500;
            if ( size(emgData,1) > 500 )
                emgData = emgData(end:end-window+1,:);
            end
            feature = emgClassifier.extractFeatures(emgData);
            resClass = predict(obj.model,feature);
        end
        
    end
    
    methods(Static)
        function features = extractFeatures(sample)
            % include different feature extraction methods here.
            % 
            method = 1;
            switch method
                case 1
                    % mean of absolute
                    features = mean(abs(sample),1);
                case 2
                    % rms: root mean square, usually provide amplitude
                    % information
                    features = mean(sample.^2,1).^0.5;
            end
            
        end
        function trainData = importTrainData(userName)
            filepath1 = ['\functions\fist.xlsx'];
            filepath2 = ['\functions\point.xlsx'];
            filepath3 = ['\functions\wrist_flex.xlsx'];
            filepath4 = ['\functions\wrist_extend.xlsx'];
            % the data file should be csv file whose first line are
            % variable names, which are seqN, channel1, channel2, channel3 and
            % channel4. seqN will be read as row names
            data1 = readtable(filepath1);
            data2 = readtable(filepath2);
            data3 = readtable(filepath3);
            data4 = readtable(filepath4);
            trainData = {data1;data2;data3;data4};
        end
        function model = loadModel(userName)
            model = load(['/data/' userName '/model/SVMmodel.mat']);
        end
    end
    
end

