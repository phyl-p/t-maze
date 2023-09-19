% Katie Winn (9/3/2020) 
% Purpose: creates a training input sequence to simulate trace conditioning. 
% If the user sets toggle_trace=true in InitialiseParameters.m (line 71), 
% the function genTrace will be called in InitialiseCoreVars.m (line 6). 

% Noise: Noise (on and off) can be adjusted by the user in
% InitialiseParameters.m (lines 61 and 62) for the training trace sequence.

function input_sequence = genTrace(pm)
% GENTRACE: this function creates a training sequence pattern starting with
% conditioned stimulus neurons turned on for a specified duration of time,
% followed by a trace interval (specified duration of time with no firing neurons), 
% ending with unconditioned stimulus neurons (positioned orthogonal to the
% CS neurons) turned on for a specified duration of time

% PARAMETERS: takes in parameters from InitialiseParameters.m and requires
% users to set additional parameters (cs_nrns, cs_duration, us_nrns,
% us_duration)

% RETURN: returns the training trace conditioning sequence (without noise) 

% Global Variables: These variables are accessed in other files in this
% workspace (genNoiseTrace.m, DetermineTrialSuccessTrace.m). 
% It is important to note that when global variable values are
% altered, they are altered in all files. 
global cs_nrns;
global us_nrns;
global cs_duration;
global trace_duration;

global off_noise_during_cs;
global off_noise_during_us;
global on_noise_during_cs;
global on_noise_during_trace;
global on_noise_during_us;

global off_noise_during_cs_test;
global on_noise_during_cs_test;
global on_noise_after_cs_test;

global total_success_neurons;
global distinct_success_neurons;
global required_number_of_firings_per_neuron;
global success_timestep_1;
global success_timestep_2;

    %-------------------
    % PARAMETERS 
    %-------------------
    % Parameters from InitialiseParameters.m:  
    n_nrns          = pm.number_of_neurons;
    timescale       = pm.boxcar_window; %for boxcar adjustments
    
    % Parameters to be set by user:
    cs_nrns        = 40; %number of conditioned stiumulus neurons
    us_nrns        = 40; %number of unconditioned stiumulus neurons
    cs_duration    = 5; %number of timesteps conditioned stimulus neurons are on
    trace_duration = 20; %number of timesteps of the trace interval
    us_duration    = 8; %number of timesteps unconditioned stimulus neurons are on
    extra_steps    = 0; %padding zeros at the end of training sequence
    len_trial      = cs_duration + trace_duration + us_duration + extra_steps; %33
   
    % Noise options (make sure probabilities are set for on_noise
    % and off_noise in InitialiseParameters.m) 
    % There are multiple noise options because there are three different
    % stages in a training trial and two different in the test trial
       
        % training noises
    off_noise_during_cs     = true; 
    off_noise_during_us     = true; 
    on_noise_during_cs      = false; %cs neurons not eligible
    on_noise_during_trace   = true; %option to turn on noise on only during trace interval. Make sure on_noise is a value between 0-1 in InitialiseParameters. 
    on_noise_during_us      = false; %us neurons not eligible
    
        % test noises
    off_noise_during_cs_test = true; 
    on_noise_during_cs_test  = false; %cs neurons not eligible
    on_noise_after_cs_test   = false; %all neurons are eligible 
    
    
    % Success parameters to be set by user:
    total_success_neurons    = 0; %total number of neurons within a temporal window for a successful prediction
    distinct_success_neurons = 12; %distinct number of neurons within a temporal window for a successful prediction    
    required_number_of_firings_per_neuron = 2; %required number of times a distinct neuron fires (does not have to be sequential)

    % Temporal window in which prediction neurons need to fire
    % Prediction too early is in a moving window that precedes the successful prediction window
    success_timestep_1   = 16; %timestep at which prediction window begins 
    success_timestep_2   = 23; %last timestep of the prediction window  
    
    toggle_produce_visualisation_of_input = true;
    toggle_save_input_sequence_to_file    = false;
    
    
    % BOXCAR RESCALE
%     cs_duration = cs_duration * timescale; 
%     trace_duration = trace_duration * timescale;
%     us_duration = us_duration * timescale;
%     extra_steps = extra_steps * timescale;
%     len_trial = len_trial * timescale;
    

    %-------------------------------
    % Function Preconditions
    %-------------------------------
    if n_nrns < (cs_nrns + us_nrns)
        disp('n_nrns must be greater than or equal to cs_nrns + us_nrns. Try increasing n_nrns, decreasing cs_nrns, or decreasing us_nrns')
    end 
    if success_timestep_2 > (cs_duration + trace_duration)
        disp('the user-defined window of a successful prediction should not overlap with unconditioned simulus neurons firing. Check and/or decrease success_timestep_2.');
    end
    if len_trial ~= pm.length_of_each_trial
        error(['Check InitialiseParameters.m to ensure parameter.length_of_each_trial is correct. Trial length should equal CS_duration + trace_duration + US_duration + extra_steps. The correct length is ', num2str(len_trial), '. Find or Ctrl+F: parameter.length_of_each_trial']);
    end
    if len_trial ~= pm.test_length_of_each_trial
        error(['Check InitialiseParameters.m to ensure test_length_of_each_trial is correct. The test trial length should equal CS_duration + trace_duration + US_duration + extra_steps. The correct length is ', num2str(len_trial), '. Find or Ctrl+F: test_length_of_each_trial']);
    end
    if cs_duration ~= pm.first_stimulus_length
        error('Check InitialiseParameters.m under testing to ensure the first stimulus length is correct. first_stimulus_length should equal cs_duration. Find or Ctrl+F: first_stimulus_length');
    end
    %-----------------------------------------------
    % Implementation (calls function genPrototypes) 
    %-----------------------------------------------
    input_sequence = genPrototypes(n_nrns,len_trial,cs_nrns,cs_duration,trace_duration, us_nrns, us_duration);
    if extra_steps > 0
        % padding of zeros at the end
        input_sequence = [input_sequence, zeros(n_nrns,extra_steps)];
    end
    
    %-------------------------------
    % Visualize Sequence
    %-------------------------------
     if toggle_produce_visualisation_of_input == true
        figure
        spy(input_sequence)
     end
     
    %-------------------------------
    % Save Sequence
    %-------------------------------
    if toggle_save_input_sequence_to_file == true
        save('Input.mat','input_sequence')
    end

end

function prototypes = genPrototypes(n_nrns,len_trial,cs_nrns,cs_duration,trace_duration, us_nrns, us_duration)
%GENPROTOTYPES: This function does the main implementation of the trace
%conditioning sequence. It is called by genTrace.  
    
    % Initialize an empty matrix with dimensions number of neurons by
    % length of trial
    prototypes = zeros(n_nrns, len_trial);
    
    % Conditioned Stimulus neurons:
    % A matrix representing the firing neurons between the conditioned stimulus onset
    % and conditioned stimulus offset 
    cs_block = ones(cs_nrns, cs_duration);
    
    % Unconditioned Stimulus neurons:
    % A matrix representing the firing neurons between the unconditioned
    % stimulus onset and uncondition stimulus offset
    us_block = ones(us_nrns, us_duration);
   
    % these variables act as moving pointers to indicate
    % where the next pattern of firing neurons is located
    initial_cs_nrn = 1;
    final_cs_nrn = cs_nrns;
    start = 1;
    stop = cs_duration;
    
    
    % --- Main Training Sequence Generator ---

    % Fills in CS neurons
    % x-axis (start:stop) is the duration of CS neurons firing
    % y-axis (initial_cs_nrn:final_cs_nrn) are the neurons firing
    prototypes(initial_cs_nrn:final_cs_nrn, start:stop) = cs_block;

    % Trace Interval
    % Sets up start and stop for for next pattern of US neurons (along x-axis)
    start = start + cs_duration + trace_duration;
    stop = stop + trace_duration + us_duration;

    % Sets up US neurons firing location (along y-axis)
    initial_us_nrn = final_cs_nrn + 1;
    final_us_nrn = initial_us_nrn + us_nrns - 1;

    % Fill in US neurons  
    % x-axis (start:stop) is the duration of US neurons firing
    % y-axis (initial_us_nrn:final_us_nrn) are the neurons firing
    prototypes(initial_us_nrn:final_us_nrn, start:stop) = us_block;
   
end
