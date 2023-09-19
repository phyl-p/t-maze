function fname_struct = InterpretResultFName(fname)
%we want a function that can take as input the filename
%'Bid_bx4np08sd029maxconssucc004.mat' and tell us that this file contains
%the information for a trial that was bidirectional, boxcar 4, with 8
%patterns on rng seed 29, with a maximum number of consecutive success of 4

index = struct(...
    ...%index of score indicator in fname (in our case, max # of consec successes)
    'score'         ,28:30  ,...
    ...%indices that are self explanatory
    'boxcar'        ,7      ,...
    'n_patterns'    ,10:11  ,...
    'seed'          ,14:16 ...
    );


fname_struct = struct;
for varname = fieldnames(index)'
    fname_struct.(varname{:}) = str2double(fname(index.(varname{:})));
end
