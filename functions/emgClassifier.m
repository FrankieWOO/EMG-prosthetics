classdef emgClassifier < handle
    %EMGCLASSIFIER EMG classifier
    %   created by Fan on 3/2/2017
    
    properties
        userName;   % name of the user
        model;  % the trained model
        %triggerThredshold;
        sampleRate = 100;
    end
    
    methods
        function obj = emgClassifier(name,sampleRate)
            obj.userName = name;
            %obj.model = [];
            obj.sampleRate = sampleRate;
        end
        function prepareModel(obj)
            try
                %obj.model = emgClassifier.loadModel(obj.userName);
                read = load(['data/' obj.userName '/model/SVMmodel.mat']);
                obj.model = read.SVMModel;
                
                % load trigger thredshold
                % better to add a calibration procedure
                % ...
                %obj.triggerThredshold = read.trigger_thredshold;
            catch
                error('loading model failed, please train the model');
                % train the model
                % ...
            end
        end
        function trainSVM(obj,segmented)
            
            if( nargin==1)
                segmented = true;
            end
            labelnames = readtable(['data/' obj.userName '/model/labelnames.txt']);
            nClass = size(labelnames,1);
            samples = cell(nClass,1);
            if (segmented == false)
                % do segmentation using auto TH
                window_analysis = 200*obj.sampleRate/1000;
                %silent_length = 2000*obj.sampleRate/1000;
                % import train dataset, which is a cell array, each cell is a
                % datatable for one action
                trainData = emgClassifier.importTrainData(obj.userName);
                % segment the time series data into samples
                % samples are cell array where each cell is a sample
                % represented by a matrix
                data0 = trainData{1};
                data0_savg = mean(data0.^2,2).^0.5;
                data0_mavg = tsmovavg(data0_savg,'s',window_analysis,1);
                trigger_thredshold = prctile(data0_mavg(window_analysis:end),99);
                samples = cellfun(@emgSegment,trainData(2:end,1),num2cell(trigger_thredshold*ones(4,1)),'UniformOutput',false);
            else
                % load segments
                for i = 1:nClass
                    variables_read = load(['data/' obj.userName '/train/' labelnames.class{i} '.mat'],'segments');
                    samples{i}=variables_read.segments;
                end
            end
            
            
            features = cell(nClass,1);
            featureMatrix = []; labelVector = [];
            for i = 1:nClass
                features{i,1} = cellfun(@emgClassifier.extractFeatures,samples{i,1},'UniformOutput',false);
                featureMatrix = cat(1,featureMatrix,cell2mat(features{i,1}));
                labelVector = cat(1,labelVector,labelnames.label(i)*ones(size(features{i},1),1));
            end
                       
%             ffist = features{1,1};
%             fpoint = features{2,1};
%             fwristf = features{3,1};
%             fwriste = features{4,1};
%             
%             lf=size(ffist,1);
%             lp= size(fpoint,1);
%             lwf= size(fwristf,1);
%             lwe= size(fwriste,1);
%             
%             for i=1:lf
%                 Tffist(i,:)=ffist{i,1};
%             end
%             for i=1:lp
%                 Tfpoint(i,:)=fpoint{i,1};
%             end
%             for i=1:lwf
%                 Tfwristf(i,:)=fwristf{i,1};
%             end
%             for i=1:lwe
%                Tfwriste(i,:)=fwriste{i,1};
%             end
%             
%            X=[Tffist;Tfpoint;Tfwristf;Tfwriste];
            %labels = [ones(lf,1);2*ones(lp,1);3*ones(lwf,1);4*ones(lwe,1)];
            
            gamma=1;
            C=1;
            
            T=templateSVM('KernelFunction','gaussian','Standardize' ,true,'KernelScale',gamma,'BoxConstraint',C);
            SVMModel=fitcecoc(featureMatrix,labelVector,'Coding','onevsone','Learners',T);
            obj.model = SVMModel;
            
%             % calculate the trigger_thredshold
%             emg_savg = mean(table2array(trainData{1}(1:silent_length,:)).^2,2).^0.5;
%             emg_mavg = tsmovavg(emg_savg,'s',window_analysis,1);
%             trigger_thredshold = prctile(emg_mavg(window_analysis:end),95);
%             obj.triggerThredshold = trigger_thredshold;
%             
            % save file
            path2save = ['data/' obj.userName '/model/SVMmodel.mat'];
            save(path2save,'SVMModel');
            disp('SVM model train done')
        end
        
        function resClass = recognize(obj,emgData)
            % window for computing features
            window_analysis = 200*obj.sampleRate/1000;
            
            if ( size(emgData,1) > window_analysis )
                emgData = emgData(end-window_analysis+1:end,:);
            end
            emg_savg = mean(emgData.^2,2).^0.5; % root mean of squared value
            feature = emgClassifier.extractFeatures(emgData);
            resClass = predict(obj.model,feature);
            disp('class predicted:')
            disp(resClass)
            % mean in the analysis window
%             if (mean(emg_savg,1) <= obj.triggerThredshold)
%                 resClass = 0;
%             end
            
            
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
            filepath0 = ['data/' userName '/train/relax.csv'];
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
            data0 = readtable(filepath0);
%             data1 = adc2emg(data1{:,:});
%             data2 = adc2emg(data2{:,:});
%             data3 = adc2emg(data3{:,:});
%             data4 = adc2emg(data4{:,:});
            
            trainData = {data0;data1;data2;data3;data4};
        end
        function model = loadModel(userName)
            read = load(['data/' userName '/model/SVMmodel.mat']);
            model = read.SVMModel;
        end
    end
    
end

