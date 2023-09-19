function [k0,kff] = RetrievePresetK(parameters,fname)
%TODO: Add a function that can check if the original preset K parameters
%are identical to parameters struct given in the input
if ~exist('fname','var')
    fname = 'ktable';
end
load(['PresetKs/',fname], 'ktable', 'timescale')

if length(parameters.boxcar) ~= timescale
    error(['preset Ks prepared for boxcar ',num2str(timescale), ' which does not match boxcar timescale specified in Main'])
end



npat = parameters.n_patterns;

row_idx = ktable.npat == npat;

if sum(row_idx)==0
    error('none of the ktable entries in the saved file contain information on the requested number of patterns for this simulation.')
end

varnames = {'k0','kff'};
kcell = num2cell(ktable{row_idx,varnames});
%varargout = kcell;

[k0,kff] = kcell{:};

