function [average,pattern_stretch] = HistogramofPatternInducedContextFiringLength(reordered_matrix, index_selected_context_nrns, i_reorder, end_ts, stutter)
    % this is a function that makes a histogram for a specific pattern's
    % context neuron firing.
    % the exact context neurons are determined via the function "ExaminePatternExcitedContextNeurons"
    num_of_firings = zeros(length(index_selected_context_nrns),1);
    pattern_stretch = zeros(length(index_selected_context_nrns),1);
    for context_nrn = 1: length(index_selected_context_nrns)
        num_of_firings(context_nrn, 1 ) = sum(reordered_matrix(context_nrn, :),'all');
        %pattern_stretch = num_of_firings(context_nrn, 1 ) - (end_ts - i_reorder(index_selected_context_nrns))/stutter;
    end
    disp(num_of_firings)
    figure
    histogram(num_of_firings)
    title("Histogram of Number of Repeated Firings for ")
    average = mean(num_of_firings);
end
