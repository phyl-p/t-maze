%Dana Schultz,18 Jun 2020
function [parameters,variables] = RescaleParameters(parameters,variables,timescale)


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%BOXCAR ADJUSTMENTS,%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SCALE trial length and adjust dependent variables accordingly
    if parameters.toggle_trace == true  % trace sequence
        parameters.length_of_each_trial = parameters.length_of_each_trial * timescale;
    elseif parameters.toggle_I_Maze == true
        parameters.length_of_each_trial = parameters.length_of_each_trial * timescale;
    else
        parameters.length_of_each_trial = parameters.extra_timesteps_train ... % default simple sequence
            + timescale*parameters.n_patterns*parameters.stutter;
        
    end 
    
    variables.mean_z_history_during_trial ...
        = zeros(1,parameters.length_of_each_trial);

    % scale testing parameters
    parameters.test_length_of_each_trial = ...
        parameters.test_length_of_each_trial * timescale;
    parameters.first_stimulus_length = ...
        parameters.first_stimulus_length * timescale;

    %interlace matrices of zeros with the input_prototypes s.t.
    %each prototype vector is followed by timescale-1 i.e. boxcarlength-1
    %0 vectors
    if parameters.toggle_I_Maze == true
        variables.input_prototypesL1...
            = RepCols(variables.input_prototypesL1,timescale);
        variables.input_prototypesL2...
            = RepCols(variables.input_prototypesL2,timescale);
        if parameters.num_start_block > 0
            variables.input_prototypesR1...
                = RepCols(variables.input_prototypesR1,timescale);
            variables.input_prototypesR2...
                = RepCols(variables.input_prototypesR2,timescale);
        end
    else
        variables.input_prototypes...
        = RepCols(variables.input_prototypes,timescale);
    end
    %note that this results in the scaling of the so-called stutter length
    parameters.stutter = parameters.stutter*timescale;

    %SCALE network activity parameters:

    parameters.desired_mean_z = parameters.desired_mean_z/timescale;
    %parameters.desired_mean_z = parameters.desired_mean_z/1.5;

    %parameters.k_0_start  = parameters.k_0_start /timescale;
    %parameters.k_fb_start = parameters.k_fb_start/timescale;
    %parameters.k_ff_start = parameters.k_ff_start/timescale;
    %parameters.k_0_start  = 0.9393;
    %parameters.epsilon_k_0 = parameters.epsilon_k_0/2;

    parameters.epsilon_pre_then_post = parameters.epsilon_pre_then_post/timescale;
    parameters.epsilon_post_then_pre = parameters.epsilon_post_then_pre/timescale;
    parameters.epsilon_feedback = parameters.epsilon_feedback/timescale;

    %decay rates / fractional memory
    parameters.fractional_mem_pre = parameters.fractional_mem_pre^(1/timescale);
    parameters.fractional_mem_post = parameters.fractional_mem_post^(1/timescale);
end
