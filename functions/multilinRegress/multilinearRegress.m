function [ML] = multilinearRegress( trainSet, testSet, nModes, modesNames, referenceVals)
%MULTILINEARREGRESS Performs multilinear regression on input and output data

% ///////////////////////////////////////////////////////////////////////////////
%   inputs :
    % trainSet      = stuct with members
    % members       = 'inputs', 'outputs'
    % testSet       = stuct with members
    % members       = 'inputs', 'outputs'
    % nModes        = number of modes that we want to regress
    % modesNames    = names of the modes that we want to regress
    % referenceVals = nominal values of the inputs
%   output : 
%   ML      = struct with members  
%   members =  'linMdls', 'outs', 'coeffs', multilinCoeffs, 'R2', 'errors'

% //////////////////////////////////////////////////////////////////////////////

    
    nRegressors = length(referenceVals) -1;
    linearModels = cell(nModes,1);
    multilinCoeffs = zeros(nRegressors,nModes);
    trainSet.outputs =trainSet.outputs(:,1:nModes); 
    testSet.outputs = testSet.outputs(:,1:nModes);
    
    outliers = {};
    nOutliers = [];
    
    for ii = 1:nModes  
        modelfun = @(b,x) b(1) + b(2)*x(:,1)+ b(3)*x(:,2) + b(4)*x(:,3)+ b(5)*x(:,4)+...
         b(6)*x(:,5)+ b(7)*x(:,6) + b(8)*x(:,7)+ b(9)*x(:,8)+...
         b(10)*x(:,9)+ b(11)*x(:,10); %+ b(12)*x(:,11)+ b(13)*x(:,12);
        beta0 = ones(1,11);
    
        notNanIdxs = find(~isnan(trainSet.outputs(:,ii)));
        linearModels{ii} = fitnlm(trainSet.inputs(notNanIdxs,:), trainSet.outputs(notNanIdxs,ii),modelfun,beta0);
        dists = linearModels{ii}.Diagnostics.CooksDistance;
        levs = linearModels{ii}.Diagnostics.Leverage;
        res = linearModels{ii}.Residuals.Standardized;
        
        outliers{ii} = unique([find(dists>= 0.1*max(dists)).' find(levs>= 0.9*max(levs)).']);
        linearModels{ii} = fitnlm(trainSet.inputs(notNanIdxs,1:10), trainSet.outputs(notNanIdxs,ii),modelfun,beta0, 'exclude', outliers{ii});
        nOutliers(ii) = length(outliers{ii});
        %linearModels{ii} = fitlm(trainSet.inputs, trainSet.outputs(:,ii),'linear');   
        multilinCoeffs(:,ii) = table2array(linearModels{ii}.Coefficients(:,1));
        R2_train(ii) = linearModels{ii}.Rsquared.Ordinary;
     end
    disp(['newline n outliers: ', num2str(nOutliers)]);
    outliersIdxs = unique([outliers{:}]);
    
    [predictedOutputs] = predictEigenfrequencies(linearModels , testSet.inputs(:,1:10), nModes);
    
    [R2] = computeR2(testSet.outputs, predictedOutputs);
    
    errors = zeros(nModes,1);
    for ii = 1:nModes
       errors(ii) = NMSE(testSet.outputs(:,ii), predictedOutputs(:,ii)); 
    end
    
    R2Names = cell(nModes,1);
    
    R2 = array2table(R2, 'VariableNames', modesNames);
    
    ML = struct('linMdls', [], 'outs' ,[],'predOuts', [], 'coeffs', [], 'R2', [],...
        'errors', [], 'outliersIdxs', []);
    ML.linMdls = linearModels; 
    ML.outs = testSet.outputs;
    ML.predOuts = predictedOutputs;
    ML.coeffs = multilinCoeffs;
    ML.R2 = R2;
    ML.errors = errors;
    ML.outliersIdxs = outliersIdxs;
end


