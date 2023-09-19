function [collage_induced_weights, selected_context_nrns, context_nrn_induced_nrns, reordered_matrix, i_reorder, index_selected_context_nrns, num_of_context_induced, reordered_begin_end_pattern ] = ...
    ExaminePatternExcitedContextNeurons(pattern_num, data, params, vars, trial_number)
    % Set up:
    [reordered_matrix,i_reorder, ~] = reorder(data.z_train(:,:,trial_number));
    externals = params.ext_activation;
    shift = params.shift;
    stutter = params.stutter;
    num_start_blocks = params.num_start_block;
    num_shared_blocks = params.num_shared_block;
    num_end_blocks = params.num_end_block;
    
    %get training z matrix with only context neurons
    total_external_nrns = shift*(num_start_blocks*2+num_shared_blocks+num_end_blocks*2);
    % determine which training sequence it is
    % code piece from RunModel.m by Phyl
    if vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 1
                vars.input_prototypes = vars.input_prototypesL1;
                vars.attractor_position = vars.attractor_posL1;
                last_external_index =shift*(num_start_blocks*2+num_shared_blocks+num_end_blocks);

            elseif vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 2
                vars.input_prototypes = vars.input_prototypesL2;
                vars.attractor_position = vars.attractor_posL2;
                last_external_index = shift*(num_start_blocks*2+num_shared_blocks+num_end_blocks*2);

    end
    
    % locate context neurons firing after the 
    % Assumption: use the training neural diagram of the last trial
   
    % the params struct has been scaled to the boxcar window.
    % NO NEED TO SCALE BY BOXCAR
    pattern_half_timestep_start = stutter*(pattern_num-1)+0.0*stutter;
    pattern_end_timestep = stutter*pattern_num;
    %disp(pattern_half_timestep
    reordered_begin_end_pattern = [pattern_half_timestep_start pattern_end_timestep];
    % index of pattern_half_timesteps
    possible_range = [];
    for neuron = pattern_half_timestep_start:pattern_end_timestep
        possible_range = [possible_range find(i_reorder == neuron)];
    end
    
     disp(min(possible_range))
     disp(max(possible_range))
    
    % find the overlap between context nrnrs that fired and context nrns
    % that are between the possible_range
%     disp(last_external_index)
    selected_range = i_reorder(min(possible_range):max(possible_range));
    index_selected_context_nrns = find(selected_range>last_external_index);
    selected_context_nrns = selected_range(index_selected_context_nrns);
    disp(selected_context_nrns)
    disp("total number of context nrns for the pattern:")
    disp(length(selected_context_nrns))
    % given the selected context nrns, find the neurons they are connected
    % to via the weight connection matrix
    
    n_nrns = params.number_of_neurons;
    wfanin = data.w_excite_trial(:,:, trial_number);
    cfanin = vars.connections_fanin;
    w_mat = FaninWeight2SquareMat(n_nrns,wfanin,cfanin);
    
    disp("context neurons and neurons they are connected to with large weights:")
    num_of_context_induced = []; % records in sequence how many nrn firing each context nrns induced
    context_nrn_induced_nrns = []; % records the indices of the induced nrn for each context nrn selected.
    collage_induced_weights = [];
    for i = 1 : length(selected_context_nrns)
        nrn = selected_context_nrns(i);
        nrn_fanout_weight = w_mat(:, nrn);
        max_weight = max(w_mat(:, nrn));
        large_weight_index = find(nrn_fanout_weight > 0.25).';
        %disp(nrn_fanout_weight(nrn_fanout_weight > 0.25))
        %size(large_weight_index)
        %size(context_nrn_induced_nrns)
        collage_induced_weights = [collage_induced_weights nrn_fanout_weight(nrn_fanout_weight > 0.25).'];
        context_nrn_induced_nrns = [context_nrn_induced_nrns large_weight_index]; % recording the index of 
        num_of_context_induced = [num_of_context_induced length(large_weight_index)]; % calculating the number of context induced nrns for each nrn
        %disp([num2str(nrn) " - " ])
        %disp(large_weight_index)
    end
    %histogram of context neuron firings
    disp(num_of_context_induced)
end