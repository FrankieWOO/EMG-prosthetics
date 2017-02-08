classdef emgClassifier < handle
    %EMGCLASSIFIER EMG classifier
    %   created by Fan on 3/2/2017
    
    properties
        userName;   % name of the user
        model;  % the trained model
        trigger_thredshold;
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
                % train the model
                % ...
            end
            
            % calculate trigger thredshold
            % better to add a calibration procedure
            % ...
            
        end
        function trainSVM(obj)
            % import train dataset, which is a cell array, each cell is a
            % datatable for one action
            trainData = emgClassifier.importTrainData(obj.userName);
            % segment the time series data into samples
            % samples are cell array where each cell is a sample
            % represented by a matrix
            samples = cellfun(@emgSegment,trainData,'UniformOutput',false);
            features = cell(size(samples));
            for i = 1:length(features)
                features{i,1} = cellfun(@emgClassifier.extractFeatures,samples{i,1},'UniformOutput',false);
            end
            
            ffist = features{1,1};
            fpoint = features{2,1};
            fwristf = features{3,1};
            fwriste = features{4,1};
            
            lf=size(ffist,1);
            lp= size(fpoint,1);
            lwf= size(fwristf,1);
            lwe= size(fwriste,1);
            
            for i=1:lf
                Tffist(i,:)=ffist{i,1};
            end
            for i=1:lp
                Tfpoint(i,:)=fpoint{i,1};
            end
            for i=1:lwf
                Tfwristf(i,:)=fwristf{i,1};
            end
            for i=1:lwe
               Tfwriste(i,:)=fwriste{i,1};
            end
            
            X=[Tffist;Tfpoint;Tfwristf;Tfwriste];
            labels = [ones(lf,1);2*ones(lp,1);3*ones(lwf,1);4*ones(lwe,1)];
            
            gamma=1;
            C=1;
            
            T=templateSVM('KernelFunction','gaussian','Standardize' ,true,'KernelScale',gamma,'BoxConstraint',C);
            SVMModel=fitcecoc(X,labels,'Coding','onevsone','Learners',T);
            
            % calculate the trigger_thredshold
            
            
            path2save = ['data/' obj.userName '/model/SVMmodel.mat'];
            save(path2save,'SVMModel');
            
        end
        
        function resClass = recognize(obj,emgData)
            % window for computing features
            window_analysis = 200;
            
            if ( size(emgData,1) > window_analysis )
                emgData = emgData(end-window_analysis+1:end,:);
            end
            emg_savg = mean(emgData.^2,2).^0.5; % root mean of squared value
            % root mean of squared
            if (mean(emg_savg.^2,1)^0.5 <= obj.trigger_thredshold)
                resClass = 0;
                return
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
            filepath1 = ['data/' userName '/train/fist.csv'];
            filepath2 = ['data/' userName '/train/point.csv'];
            filepath3 = ['data/' userName '/train/wrist_flexion.csv'];
            filepath4 = ['data/' userName '/train/wrist_extension.csv'];
            % the data file should be csv file whose first line are
            % variable names, which are seqN, channel1, channel2, channel3 and
            % channel4. seqN will be read as row names
            data1 = readtable(filepath1);
            data2 = readtable(filepath2);
            data3 = readtable(filepath3);
            data4 = readtable(filepath4);
            
%             data1 = adc2emg(data1{:,:});
%             data2 = adc2emg(data2{:,:});
%             data3 = adc2emg(data3{:,:});
%             data4 = adc2emg(data4{:,:});
            
            trainData = {data1;data2;data3;data4};
        end
        function model = loadModel(userName)
            read = load(['data/' userName '/model/SVMmodel.mat']);
            model = read.SVMModel;
        end
    end
    
end

