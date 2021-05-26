function [R2_NN, R2_NN_new, netVector, net, testIdxs] = NN_trainTest_ALL(inputs, outputs, nNeurons, nLayers, strTitle, countFigureN)
%NN_TRAINTEST Summary of this function goes here
%   Detailed explanation goes here
close all

netLayers = ones(1,nLayers);
netVector = nNeurons*netLayers;

net = feedforwardnet(netVector);

for ii = 1:netLayers
    net.layers{ii}.transferFcn = 'logsig';
end


trainIdxs = 1:floor(0.9*length(inputs(:,1)));
testIdxs = trainIdxs(end)+1 : length(inputs(:,1));

linearModels = {};
R2_neuralNetwork = [];

names = {};
out_train = outputs(trainIdxs,:);
out_test = outputs(testIdxs,:);

net = train(net,inputs(trainIdxs,:).',out_train.');
inputTest = inputs(testIdxs,:);

y = net(inputTest.');
count = countFigureN;
plotN = 1;

for ii = 1:20
normTestDataset = (out_test(:,ii)./mean(out_test(:,ii)));
normNNout =y(ii,:)./mean(y(ii,:));    
if mod(ii-1,2) == 0
    count = count + 1 ;
    plotN = 1;
end    
figure(count)
subplot(2,1,plotN);
equalityLine = [min(normNNout, [], 'all'), max(normNNout, [], 'all') ];
scatter( normTestDataset.', normNNout,50, '.');
hold on 
plot(equalityLine,equalityLine,'lineWidth',1.2 );
xlabel('test data');
ylabel('predicted data');
title([strTitle,'_{', int2str(ii),'}']);
ax = gca;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';
ax.TickDir = 'out';
ax.FontSize = 17;

linearModels{ii} = fitlm(out_test(:,ii), y(ii,:));   
R2(ii) = linearModels{ii}.Rsquared.Adjusted;
names{ii} = [strTitle(1), int2str(ii)];
plotN = plotN +1;
end

[R2_new] = computeR2(out_test, y.');
R2_NN_new = array2table(round(R2_new,4), 'VariableNames', names)
R2_NN = array2table(round(R2,4), 'VariableNames', names)
end
