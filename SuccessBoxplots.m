%transform a trial_map into a boxplot showing the distribution of
%successful trials
%{
%for example, if we wanted to create a boxplot of the following data:
c = container.Map
c(4) = [1,2,3]
c(5) = [4,5]
c(6) = [6,7,8,9]

%then 
bplot_vect = [1,2,3,4,5,6,7,8,9]
%and 
bplot_grps = [4,4,4,5,5,6,6,6,6]

and this will result in 3 boxplots
%}

function SuccessBoxplots(rule)
rule = 'Uni';
f = load(['Results',rule,'SuccessVects.mat']);

trial_map = f.trial_map;

[bplot_vect,bplot_grps] = BPlotData(trial_map);


boxplot(bplot_vect,bplot_grps)
if rule == 'Bid'
    fullrulename = 'Bidirectional';
else
    fullrulename = 'Unidirectional';
end
title([fullrulename,'; Boxplots of successful trials'])
xlabel('number of patterns')
ylabel('trial number')


function [bplot_vect,bplot_grps] = BPlotData(trial_map)
val_set = values(trial_map);
bplot_vect = [val_set{:}];

bplot_grps = zeros(size(bplot_vect));
acc = 0;

for npat_cell = keys(trial_map)
    npat = npat_cell{:};
    n_datapoints = length(trial_map(npat));
    if n_datapoints>0
        bplot_grps(acc+1:acc+n_datapoints) = npat;
    end
    acc = acc+n_datapoints;
end










