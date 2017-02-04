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
            
        end
        function trainData = importTrainData(userName)
            filepath1 = ['/data/' userName '/fist.csv'];
            filepath2 = ['/data/' userName '/point.csv'];
            filepath3 = ['/data/' userName '/wrist_flex.csv'];
            filepath4 = ['/data/' userName '/wrist_extend.csv'];
            % the data file should be csv file whose first line are
            % variable names, which are seqN, channel1, channel2, channel3 and
            % channel4. seqN will be read as row names
            data1 = readtable(filepath1,'ReadRowNames',true);
            data2 = readtable(filepath2,'ReadRowNames',true);
            data3 = readtable(filepath3,'ReadRowNames',true);
            data4 = readtable(filepath4,'ReadRowNames',true);
            trainData = {data1;data2;data3;data4};
        end
        function model = loadModel(userName)
            model = load(['/data/' userName '/model/SVMmodel.mat']);
        end
    end
    
end

