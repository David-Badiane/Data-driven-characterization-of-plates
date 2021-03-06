function [NCC] = NCC(simSig,measSig)
%NCC this function computes the normalized cross correlation function
%   
% simSig  (array) = simulated signal
% measSig (array) = measured signal

if length(simSig(:,1)) == 1
    simSig = simSig.';
end
if length(measSig(:,1)) == 1
    measSig = measSig.';
end

simSig = simSig/max(simSig);
measSig = measSig/max(measSig);
NCC  = ( measSig'*simSig)/(norm(simSig,2)*norm(measSig,2));
end

