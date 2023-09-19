%Dana Schultz, Jul 21 2020
%Phyl Peng edited, Oct 21 2022
function parameters = InitialiseParameters(varargin)
%constant parameters
parameters = struct(...
    %{
    'cycle_limit',...
        [10; ... %length of each trial
        100; ... %number of trials
        1; ...
        1],... 
    'lpmi',                         1,... loop position of main iteration; i.e. if external input changes to next time step when inc_vect is [0,1,0] then lpmi is 2.
    %}
    ... % visualization toggles
    'toggle_figures',                       true,...
    'toggle_visualize_IMaze',               true,...
    'toggle_save_input_sequence_to_file',   true,...
    'toggle_display_failure_mode',          true,...
    'toggle_display_param',                 false,...
    'toggle_display_seed',                  false,...
    ...
    ... % data recording settings
    'toggle_record_success',        true,...
    'toggle_record_training',       true,...
    'toggle_record_y',              true,... % y and z dimensions: # neurons x timesteps x trials
    'toggle_record_z_train',        true,... 
    'toggle_record_z_test',         true,...
    'toggle_record_weights_exc',    true,...
    'toggle_record_weights_inh',    true,...
    'toggle_record_k0',             true,...
    'toggle_record_kff',            true,...
    ...
    ... % stopwatch toggle
    'toggle_fxn_stopwatch',         true,... % toggle true to record elapsed time
    ...
    ... % general settings
    'toggle_training',              true,...
    'toggle_testing' ,              true,...
    'number_of_trials',             50,... 
    'consecutive_successes_to_halt',5,... % after this many successes-in-a-row, halt the program (this saves time); will only run if the previous toggle is on.
    ...
    ... % boxcar settings
    'toggle_divisive_refractory',   true,...
    'boxcar_refractory_period',     1,... %when set to 1 there is no refractory period
    'boxcar_window',                1,... %excitation boxcar
    'boxcar_scales',                [1],... % should sum to 1
    'boxcar_window_inh',            2,...
    'boxcar_scales_inh',            [1 0],...
    ...
    ... % random number seeds
    'network_construction_seed',    randi(100,1),... 
    'z_0_seed',                     randi(100,1),... 
    ...
    ... % network topology settings
    'number_of_neurons',            uint16(2000),...
    'connectivity',                 0.1,... %fan in is exact i.e. each postsyn. nrn is enervated by same number of nrns
    'desired_mean_z',               0.1,...
    'gradient',                     -0.25,...
    ...
    'n_patterns',                   uint16(40),... %!!!!!!! 60 was working boxcar 2
    'extra_timesteps_train',        0,... % add this many timesteps with no external activation to the end of each trial; use test_length_of_each_trial to add timesteps during testing
    'on_noise',                     0,... %probability between 0-1
    'off_noise',                    0.5,... %probability between 0-1
    'test_off_noise',               0.5,...
    'test_on_noise',                0.0,...
    ...
    ... % testing parameters
    'test_length_of_each_trial',    40*5,... %set this equal to stutter * number of patterns
    'first_stimulus_length',        uint16(5),... %in general, set this equal to stutter * boxcar window. This param for I-maze is adjusted below.
    ...
    ... % trace conditioning
    'trace_interval',               uint16(0),...
    'toggle_trace',                 false,... %true trace, false normal
    ...
    ... % I-Maze & Straight-sequence, shares some input settings with straight sequence, could potentially combine
    'toggle_I_Maze',                true,...
    ... %  shared params
    'toggle_external_input',        true,... 
    'ext_activation',               uint16(60),... %default 30
    'stutter',                      uint16(5),...x
    'shift',                        uint16(30),... %default 15, must be less than 30 (?)
    'paradigm',                     [10 5], ...
    'num_start_block',              uint16(0),...
    'num_shared_block',             uint16(3),...
    'num_end_block',                uint16(4),...
    'attr_percent_ext_nrns',        0.0,... % specify the percentage of externals block that are attractors
    ... % test I-Maze params
    'test_num_stimuli',              uint16(3),... $ equivalent to first_stimulus_length for straight sequence
    'num_test_pattern',              uint16(4),... % default to 4 as there are four patterns in total          
    'test_reps_for_each_pattern',    uint16(1),...
    ...
    ... % modification rates
    'toggle_k0_preliminary_mod',    true,...%adjust k0 before training begins to attune to desired activity 
    'toggle_k0_training_mod',       false,...%modify k0 at the end of each trial to maintain desired activity
    'epsilon_pre_then_post',        0.005,...%0.001,...
    'epsilon_post_then_pre',        0.005,...%0.001,...
    'epsilon_feedback',             0.01,...
    'epsilon_k_0',                  0.5,... %modification rate used to adapt k0 before and/or during training; make sure appropriate toggles above are turned on
    'epsilon_k_ff',                 0.5,...%kff will not be updated unless pre then post is off
    ... 
    ... % synaptic modification settings
    'toggle_pre_then_post',         true,...
    'toggle_post_then_pre',         true,... %!!!!!!!
    'toggle_stutter_e_fold_decay',  false,... %set to false when changing decay rates
    'fractional_mem_pre',           0.74,... %nmda; used with pre_then_post, controls Zbar pre decay, -1/log(fractional) = exponential time constant
    'fractional_mem_post',          0.74,... %spiketiming; used with post_then_pre, controls Zbar post decay
    'offset_pre_then_post',         0,...
    'offset_post_then_pre',         0,...
    ...
    ... % starting values for some variables
    'k_0_start',                    .65,...  
    'k_fb_start',                   0.047,...
    'k_ff_start',                   0.0003+0.0051,... 0.0066 ...
    ...
    ... % weight settings
    'toggle_rand_weights',          false,... %toggle between random and uniform excitatory weights
    'weight_start',                 0.4,... %starting value if using uniform weights
    'weight_high',                  0.2,... %upper limit for weight values if using random distribution
    'weight_low',                   0.8,... %lower limit for weight values if using random distribution
    'weight_inhib_start',           1 ... %choose starting weight value for inhibitory synapse; default 1
    ...
);
if nargin>0
    parameters = WriteToStruct(parameters,varargin{:});
end
parameters = AdjustParameters(parameters);
end

function parameters = AdjustParameters(parameters)

    if parameters.toggle_stutter_e_fold_decay
        stutter = double(parameters.stutter);
        parameters.fractional_mem_pre = exp(-1/(stutter-2));
        parameters.fractional_mem_post = exp(-1/(stutter-2));
    end
    
    % Doing extra calculations based on what the behavioral model is. 
    if parameters.toggle_I_Maze == true
        if parameters.num_start_block > 0
            num_seq = 4;
        else 
            num_seq = 2;
        end
        parameters.n_patterns = sum(parameters.num_start_block + parameters.num_shared_block + parameters.num_end_block);
        parameters.length_of_each_trial = parameters.stutter*parameters.n_patterns;
        parameters.number_of_trials = num_seq*sum(parameters.paradigm);
        parameters.test_length_of_each_trial = parameters.length_of_each_trial;
        %disp("IP length_of_each_trial")
        %disp(parameters.length_of_each_trial)
        
    else
        parameters.length_of_each_trial = parameters.n_patterns * ...
            (parameters.stutter + parameters.trace_interval);
    end
    
    if parameters.test_num_stimuli > sum(parameters.num_start_block + parameters.num_shared_block)
        disp("ERROR: number of testing stimuli should not go past the stem of I-Maze. Meaning it should not exceed total start + shared blocks")
    else
        parameters.first_stimulus_length = parameters.stutter*sum(parameters.test_num_stimuli);
    end
    %network and topology settings
    n_nrns = double(parameters.number_of_neurons);
%     parameters.n_fanin = uint16(n_nrns*parameters.connectivity);
    parameters.n_fanin = round(n_nrns*parameters.connectivity);
    %set range of neurons that are to be viewed during the simulation
    if parameters.toggle_I_Maze == true
        parameters.nrn_viewing_range = [1, (2*parameters.n_patterns-parameters.num_shared_block) * parameters.ext_activation - (parameters.ext_activation - parameters.shift) * ((2*parameters.n_patterns-parameters.num_shared_block)  - 1) ];  
        disp("parameters.nrn_viewing_range")
        disp(parameters.nrn_viewing_range)
    else
        parameters.nrn_viewing_range = [1,parameters.number_of_neurons];
    end
end



