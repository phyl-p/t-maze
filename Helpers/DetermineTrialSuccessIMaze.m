% Katie Winn
% Purpose: DetermineTrialSuccessTrace is a success detector for the trace
% conditioning sequence.

function result = DetermineTrialSuccessIMaze(parameters,vars,data, trial)
    %%params and varaibles needed
    n_patterns = parameters.n_patterns;
    length_of_trial = parameters.length_of_each_trial; % for I-Maze, the training and test length are equal
    attractor = vars.input_pattern(1, trial);
    pattern = vars.input_pattern(1, trial);
    attr_percent_ext_nrns = parameters.attr_percent_ext_nrns;
    
    test_stimuli_length = parameters.test_num_stimuli;    
    num_start_block = parameters.num_start_block;
    num_shared_block = parameters.num_shared_block;
    num_end_block = parameters.num_end_block;
    
    shift = parameters.shift;
    stutter = parameters.stutter;
    ext_activation = parameters.ext_activation;
    attr_percent_ext_nrns = parameters.attr_percent_ext_nrns;
    % current trial test matrix
    test_mat = data.z_test(:,:,trial);
    
    
    %param adjustment based on attractor and pattern of the trial
    if pattern == 1
        nrn_padding_start = 0;
        
    else
        nrn_padding_start = num_start_block;
        
    end
    
    if attractor == 1
            nrn_padding_end = num_start_block*2 + num_shared_block;
    else
        nrn_padding_end = num_start_block*2 + num_shared_block + num_end_block;
    end
    
    nrn_padding_shared = num_start_block*2;
    
    timestp_padding_start = 0;
    timestp_padding_shared = num_start_block;
    timestp_padding_end = num_start_block + num_shared_block;
    %-----------------------------------
    % Success Detector Implmementation 
    %----------------------------------- 
    % To find the total of success_matrix, we use the
    % MatLab sum function. The sum of success_matrix is compared to the
    % user-defined total_success_neurons. 
    % To find the number of distinct neurons, we look at the sum of each
    % row. Rows with a non-zero number indicate distinct neurons. We take 
    % sum of the distinct neurons and compare it to the user-defined
    % distinct_success_neurons. 
    % A string that describes the type of success or failure is stored and 
    % returned as the variable 'result'. 
    
    %result = 'failure to predict';     
    
    success_vec = [];
    add_attractor = 0;
    success_vec = DetermineArmSuccess(success_vec, test_mat, add_attractor, num_start_block, ...
                                nrn_padding_start, timestp_padding_start, shift, stutter, ext_activation, attr_percent_ext_nrns);
    
    % insert **shared** sequence
    %disp("build shared")
    add_attractor = 0;
    success_vec = DetermineArmSuccess(success_vec, test_mat, add_attractor, num_shared_block, ...
                                nrn_padding_shared, timestp_padding_shared, shift, stutter, ext_activation, attr_percent_ext_nrns);
    
    % insert ***end*** sequence
    %disp("build end")
    add_attractor = 1;
    success_vec = DetermineArmSuccess(success_vec, test_mat, add_attractor, num_end_block, ...
                                nrn_padding_end, timestp_padding_end, shift, stutter, ext_activation, attr_percent_ext_nrns);
    %disp("success_vec")
    %disp(success_vec)

% new method to determine success:
% compare choice point firing count:
    
    if sum(success_vec) == n_patterns
        result = FailureModeDictionary('success');
    else
        result = 0;
    end
end

function success_vect = DetermineArmSuccess(success_vect, test_mat, add_attractor, num_of_blocks, ...
                                padding, time_padding, shift, stutter, ext_activation, attr_percent_ext_nrns)
    initial_nrn = 1 + padding*ext_activation;
    ts_padding = time_padding*stutter;
    %attractor_position = [];
    for i = 1:num_of_blocks
        % this for loop builds the sequence
        % x-axis (start:stop) is the duration of external input neurons firing
        % y-axis (initial_nrn:final_nrn) are the neurons firing
        if i > 1
            shift_factor = 1;
        else
            shift_factor = 0;
        end
        initial_nrn = initial_nrn + shift_factor*shift;
        final_nrn = initial_nrn + ext_activation - 1;
        start = ts_padding + 1 + (i - 1) * stutter;
        stop = ts_padding + (i)* stutter; % interval = 0
        start = 5;
%         disp(initial_nrn)
%         disp(final_nrn)
%         disp(start)
%         disp(stop)
%         disp("------")
        block = test_mat(initial_nrn:final_nrn, start:stop);
        if add_attractor == 1 && i == num_of_blocks
           block = test_mat(initial_nrn:initial_nrn+attr_percent_ext_nrns*ext_activation, 1:stop);
        end
        if sum(block, 'all') > 12
            success_vect = [success_vect 1];
        else
            success_vect = [success_vect 0];
        end
    end
end