function [vars,params] = InitialiseCoreVars(params)
    %generate input prototypes (trace sequence,I_Maze or simple sequence);
    %all inputs in the simulation will be noisy versions of the following prototype:
    if params.toggle_trace == true 
        vars.input_prototypes = genTrace(params);    % trace sequence
    elseif params.toggle_I_Maze == true
        %disp("InitialiseCoreVars -- genIMaze")
        % input_pattern is not the same as input_protoype. Due to the
        % special nature of I-Maze, each trial's input prototype will have
        % to be determined separately.
        extra_training_pattern_2 = params.extra_train_second_pattern_trials;
        I_Maze_toggle = (params.num_start_block > 0);
        [vars.input_pattern, vars.input_attractor, params] = genIMazePattern(I_Maze_toggle,params.paradigm_left, params.paradigm_right,extra_training_pattern_2, params);    % I-Maze pattern
        [vars.input_prototypesL1, vars.attractor_posL1,vars.time_start_L1, vars.time_shared_L1, vars.time_end_L1, vars.positions_1] = genIMaze(params, 1, 1); % genIMaze(params, pattern, attractor) 
        [vars.input_prototypesL2, vars.attractor_posL2, vars.time_start_L2, vars.time_shared_L2, vars.time_end_L2, vars.positions_2] = genIMaze(params, 1, 2); % pattern == 1: Left branch pattern == 2: right branch
        disp(vars.positions_1)
        disp(vars.positions_2)
        if I_Maze_toggle                                           
            [vars.input_prototypesR1, vars.attractor_posR1, vars.time_start_R1, vars.time_shared_R1, vars.time_end_R1] = genIMaze(params, 2, 1);
            [vars.input_prototypesR2, vars.attractor_posR2, vars.time_start_R2, vars.time_shared_R2, vars.time_end_R2] = genIMaze(params, 2, 2);
            params.nrn_viewing_range = [1, vars.attractor_posR2(1,2)+30];
        else
            params.nrn_viewing_range = [1, vars.attractor_posL2(1,2)+30];
        end
    else    
        vars.input_prototypes = genSequence(params); %default is simple sequence
    end
        
    %pre check if modifications to k_0 will be well behaved, ie no negative
    %values or divergence to k_0
    n_active_nrns = double(params.ext_activation); 
    n_nrns=params.number_of_neurons; 
    timescale = numel(params.boxcar);
    if params.desired_mean_z<(double(n_active_nrns)/(timescale*double(n_nrns)))
        error('desired_mean_z is too low, will result in infinite expansion of k_0')
    end
    
    %mutable numeric values, such as inhibition and excitation    
    vars.k_0 = params.k_0_start;
    vars.k_fb = params.k_fb_start;
    vars.k_ff = params.k_ff_start;
    vars=initVarArrays(vars,params);
    vars.success = false;
        
    %weights for excitation and feedback inhibition
    vars.weights_feedback_inhib = ones(params.number_of_neurons,1) * params.weight_inhib_start;
    vars = getWeights(vars,params);
    
end    
    
    
function vars = initVarArrays(vars,params)
    timescale = numel(params.boxcar);
    number_of_nrns = params.number_of_neurons;
    len_trial = params.length_of_each_trial;
    vars.y=zeros(number_of_nrns,1);
    vars.z=zeros(number_of_nrns,1,'logical');
    if params.offset_pre_then_post < 0 || params.offset_post_then_pre < 0
        error('offset values must be positive integers')
    else
        z_memory = max(params.offset_pre_then_post+1,params.offset_post_then_pre);
        vars.z_prev = zeros(number_of_nrns,z_memory); %params.offset_pre_then_post);
    end
    vars.excite=zeros(number_of_nrns,1);
    vars.inhib=zeros(number_of_nrns,1);
    %BOXCAR ADJUSTMENTS
    bcvect = params.boxcar;
    vars.boxcar_exc = zeros(number_of_nrns,length(bcvect));
    vars.boxcar_inh = zeros(1,params.boxcar_window_inh);
    if (numel(params.boxcar_scales) == params.boxcar_window) && (sum(params.boxcar_scales) == 1)...
            && (numel(params.boxcar_scales_inh) == params.boxcar_window_inh) ...
            && (sum(params.boxcar_scales) == 1)
        vars.boxcar_scales = params.boxcar_scales;
        vars.boxcar_scales_inh = params.boxcar_scales_inh;
    else
        error('boxcar_scales must sum to 1 and must contain the same number of elements as boxcar_window')
    end
    vars.boxcar_refractory_period = uint16(floor(timescale * params.boxcar_refractory_period));
    %activity
    vars.mean_z=0;
    vars.mean_z_history_during_trial=zeros(1,len_trial);
    %time scale constants
    vars.z_pre_then_post_decay=zeros(number_of_nrns,1);
    vars.z_post_then_pre_decay=zeros(number_of_nrns,1);
    vars.spike_threshold = 0.5; %params.spike_threshold;
    vars.dw_fbexcite=zeros(number_of_nrns,params.n_fanin);
    vars.mean_dw=0;
    if params.toggle_testing == 1
        vars.z_test = zeros(number_of_nrns,1);
    end
end

function vars = getWeights(vars,params)
    number_of_neurons = params.number_of_neurons;
    if params.toggle_rand_weights == 0
        vars.weights_excite=ones(number_of_neurons,params.n_fanin)*params.weight_start;
    else
        %a matrix with n_nrn rows, n_fanin columns with entries that
        %are drawn from a uniform random distribution on the interval
        %between params.weight_low and params.weight_high
        vars.weights_excite=rand(number_of_neurons,params.n_fanin)*(params.weight_high-params.weight_low)+params.weight_low;
    end
    vars.connections_fanin=zeros(number_of_neurons,params.n_fanin);
    for row = 1:number_of_neurons
        c_row=randperm(number_of_neurons,params.n_fanin);
        vars.connections_fanin(row,:) = c_row;
    end
end

