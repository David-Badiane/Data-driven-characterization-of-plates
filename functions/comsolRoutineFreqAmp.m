function [FA_Info, inputsTable, outputsEigTable, outputsAmpTable] = comsolRoutineFreqAmp(model, nSim, nModes, referenceVals,...
                                   varyingParamsNames,  standardDev,  simFolder, csvPath, writeNow)
                               
%COMSOLROUTINEFREQAMP Summary of this function goes here
%   Detailed explanation goes here

% - - - - - - - - - - - - - - - - - - - - - - - - - SETUP
    cd(csvPath);
    FA_Info = struct('inputs',[] ,'outputsEig',[] ,'outputsAmp',[] );
    if writeNow
    else
        FA_Info.inputs = table2array(readtable('inputs.csv'));
        FA_Info.outputsEig = table2array(readtable('outputsEig.csv'));
        FA_Info.outputsAmp = table2array(readtable('outputsAmp.csv'));
    end
    
    if isempty(FA_Info.inputs)
        start = 1;
    else
        start = length(FA_Info.inputs(:,1))+1;
    end
    
    varNamesModeshapes = cell(nModes+3,1);
    varNamesxyz = {'x' 'y' 'z'};
    for ii = 1:(nModes +3)
        if ii <4
       varNamesModeshapes{ii} = varNamesxyz{ii}; 
        else 
            varNamesModeshapes{ii} = ['disp f',int2str(ii-3)]; 
        end
    end
    
%- - - - - - - - - - - - - - - - - - - - - - - - - - - START SIMULATION LOOP
    
    for ii = start:nSim
        disp(ii)        
        cd(simFolder);
        % 1) gaussian sample mechanical parameters
        if ii == 1
            % if first iteration - run reference values
            for jj = 1:length(referenceVals)
                model.param.set(varyingParamsNames(jj), referenceVals(jj));
            end
            currentVals = referenceVals;
        else
            % else - generate gaussian sampling of MP
            gauss = randn(size(referenceVals));
            currentVals = referenceVals.*(ones(size(referenceVals)) + standardDev.*gauss);
            disp(referenceVals);
            disp(currentVals);
            for jj = 1:length(referenceVals)
                model.param.set(varyingParamsNames(jj), currentVals(jj));
            end
        end
        
        % eigenfrequency study
        model.study('std1').feature('eig').set('neigs', int2str(nModes)); % ---> set number of modes
        model.component('comp1').physics('solid').feature('lemm1').feature('dmp1').active(false); % --> deactivate damping
        model.study('std1').run(); 
        model.component('comp1').physics('solid').feature('lemm1').feature('dmp1').active(true); % --> activate damping
        
        % save modeshapes
        modesFileName = 'solidDisp';
        expression = {'solid.disp'};
        
        model.result.export('data1').set('data', 'dset1');
        exportAllModesFromDataset(model, modesFileName,simFolder,expression);
        fileData = readTuples([modesFileName,'.txt'], nModes+3, true);
        delete([modesFileName,'.txt']); 
        writeMat2File(fileData,['modeshapes', int2str(ii),'.csv'], varNamesModeshapes, nModes+3, true);

        cd(csvPath)
        % save eigenfrequencies
        evalFreqz = mpheval(model,'solid.freq','Dataset','dset1','edim',0,'selection',1); % --> evaluate eigenfrequencies
        eigenFreqz = real(evalFreqz.d1');
        eigenFreqz = eigenFreqz(:).';
        
        % frequency domain
        model.study('std2').feature('freq').set('plist', num2str(eigenFreqz)); % --> set FD studies at eigenfrequencies value
        model.study('std2').run(); 

        % export FD results
        dirName = pwd;
        model.result.export('data1').set('transpose', true);
        model.result.export('data1').set('sdim', 'fromdataset');
        exportData(model,'cpt1', dirName,['vel'],'solid.u_tZ'); % velocity 
        [vel] = readTuples(['vel.txt'], 1, false);
        delete('vel.txt');
        vel = vel(4:end);

        % Update results
        FA_Info.inputs = [FA_Info.inputs; currentVals]
        FA_Info.outputsEig = [FA_Info.outputsEig; eigenFreqz]
        FA_Info.outputsAmp = [FA_Info.outputsAmp; vel]

        % Save results
        inputsTable  = writeMat2File(FA_Info.inputs,'inputs.csv', varyingParamsNames(1:12), 10,true);   
        outputsEigTable = writeMat2File(FA_Info.outputsEig,'outputsEig.csv', {'f'}, 1,false);  
        outputsAmpTable = writeMat2File(FA_Info.outputsAmp,'outputsAmp.csv', {'f'}, 1,false);
    end
end
