function [stats_context_nrns, mean_past, mean_same_pattern, mean_future] = checkConnectionsFiringSequence(...
                                        selected_context_nrns, ...
                                        collage_induced_weights, ...
                                        context_nrn_induced_nrns,...
                                        num_of_context_induced,...
                                        i_reorder, ...
                                        reordered_begin_end_pattern,...
                                        parameters, data, variables, trial_number)
    num_contxt_nrn =length(selected_context_nrns);
    stats_context_nrns = zeros(num_contxt_nrn, 3);
    
    pattern_start = reordered_begin_end_pattern(1);
    pattern_end = reordered_begin_end_pattern(2);
    
    
    
    beg_ = 1;
    end_ = 0;
    weight_past = [];
    weight_same = [];
    weight_future = [];
   
    n_nrns = parameters.number_of_neurons;
    wfanin = data.w_excite_trial(:,:, trial_number);
    cfanin = variables.connections_fanin;
    w_mat = FaninWeight2SquareMat(n_nrns,wfanin,cfanin);
    
    for context_nrn = 1:num_contxt_nrn
        end_ = end_ + num_of_context_induced(1, context_nrn);
%         disp(beg_)
%         disp(end_)
%         disp("------------------")
        past_induced = 0; 
        future_induced = 0;
        same_pattern_firing = 0;
        
        context_nrn_index = selected_context_nrns(context_nrn);
        disp("context nrn:")
        disp(context_nrn_index)
        disp("*******************")
        % find the index of the nrns that are induced by this nrn
        for induced_nrn = beg_ : end_
            induced = context_nrn_induced_nrns(induced_nrn);
            induced_index = find(i_reorder == induced);
            weight_of_induced = collage_induced_weights(induced_nrn);
            disp("weight_of_induced")
            disp(weight_of_induced)
            if induced_index > pattern_start
                future_induced = future_induced + 1;
                weight_future = [weight_future weight_of_induced];
            elseif induced_index < pattern_end
                past_induced = past_induced + 1;
                weight_past = [weight_past weight_of_induced];
            else
                same_pattern_firing = same_pattern_firing + 1;
                weight_same = [weight_same weight_of_induced];
                
            end
            stats_context_nrns(context_nrn, 1) = past_induced;
            stats_context_nrns(context_nrn, 2) = same_pattern_firing;
            stats_context_nrns(context_nrn, 3) = future_induced;
        end
        % compare the index of each of the nrn to the index of the
        % beginning /end of the pattern
        
        %update beg_ counter
        beg_ = end_ + 1;
    end
    
    % stats computation
    mean_past = sum(stats_context_nrns(:, 1))/num_contxt_nrn;
    mean_same_pattern = sum(stats_context_nrns(:, 2))/num_contxt_nrn;
    mean_future = sum(stats_context_nrns(:, 3))/num_contxt_nrn;
    
    % graph context-induced nrns' weights
    edges = [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];
    bincenters = [0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95];
    h1 = histogram(weight_past, 'BinEdges', edges);
    h1_values = h1.Values;
    h2 = histogram(weight_same, 'BinEdges', edges);
    h2_values = h2.Values;
    h3 = histogram(weight_future, 'BinEdges', edges);
    h3_values = h3.Values;
    y_max = [0 10+max([ max(h1_values) max(h2_values) max(h3_values)])] ;
    disp(y_max)
    
    figure
    
    subplot(1, 4, 1)
    bar(bincenters, h1_values)
    ylim(y_max);
    title("Histogram of Context Induced Firing Weights - Past ")
    
    subplot(1, 4, 2)
    bar(bincenters, h2_values)
    ylim(y_max);
    title("Histogram of Context Induced Firing Weights-Same Pattern")
    
    subplot(1, 4, 3)
    bar(bincenters, h3_values)
    ylim(y_max);
    title("Histogram of Context Induced Firing Weights-Future")
    
    
   
    
    subplot(1, 4, 4)
    combined_alues = [h1_values.' h2_values.' h3_values.'];
    disp(size(combined_alues))
    disp(size(bincenters))
    bar(bincenters, combined_alues);
    legend('Past','Same Pattern','Future')
    title("Histogram of Context Induced Firing Weights")
    
    
end