% Phyl Peng (10/8/2022) 
% Purpose: creates a training input sequence to simulate I-Maze training. 
% If the user sets toggle_I_Maze=true in InitialiseParameters.m (line ??), 
% the function genIMaze will be called in InitialiseCoreVars.m (line ?). 

% Noise: Noise (on and off) can be adjusted by the user in
% InitialiseParameters.m (lines ??) for the training trace sequence.
function [input_sequence, attractor_position, external_stimulation_time_steps_start, external_stimulation_time_steps_shared, external_stimulation_time_steps_end, positions] = genIMaze(pm, pattern, attractor)
% GENIMAZE: this function creates a training sequence pattern starting with
% two starting positions for the I-Maze, the left and right branch, turned
% on for a specified duration of time (stutter), followed by a trace interval
% (specified duration of time with no firing neurons), ending with
% unconditioned stimulus neurons (positioned orthogonal to the CS neurons)
% turned on for a specified duration of time

% two starting positions (combined look):
% left     right
% -         -
%  -       -
%   -     -
%    -   -
%      |
%      |
%      | <- shared sequence
%      |
%     - -
%    -   -
%   -     -
%  -       -
% -         -
% attr. 1 attr. 2
% two ending positions

% two starting positions (combined look):
% left     right
% -       
%  -       
%   -     
%    -   
%      |
%       |
%        | <- shared sequence
%         |
%          -
%            -
%   -     -
%  -       -
% -         -
% attr. 1 attr. 2
% two ending positions

% PARAMETERS: takes in parameters from InitialiseParameters.m and requires
% users to set additional parameters (right_start_length,
% left_start_length, shared_length, right_end_length, left_end_length,
% shift, stutter)

% RETURN: returns the training I-Maze sequence (without noise) 

% Global Variables: These variables are accessed in other files in this
% workspace (genNoiseTrace.m, DetermineTrialSuccessTrace.m). 
% It is important to note that when global variable values are
% altered, they are altered in all files. 
    %disp("in genIMaze")
    n_nrns = pm.number_of_neurons;
    ext_activation = pm.ext_activation;
    stutter = pm.stutter;
    shift = pm.shift;
    num_start_block = pm.num_start_block;
    num_shared_block = pm.num_shared_block;
    num_end_block = pm.num_end_block;
    attr_percent_ext_nrns = pm.attr_percent_ext_nrns;
    extra_steps = pm.extra_timesteps_train;
    toggle_produce_visualisation_of_input = pm.toggle_visualize_IMaze;
    toggle_save_input_sequence_to_file = pm.toggle_save_input_sequence_to_file;

    [input_sequence, attractor_position,external_stimulation_time_steps_start, external_stimulation_time_steps_shared, external_stimulation_time_steps_end, positions] = genPrototypes(pattern, attractor, n_nrns, ext_activation, ...
        stutter, shift,num_start_block, num_shared_block, num_end_block,attr_percent_ext_nrns);
    
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
        set(gca, 'PlotBoxAspectRatio', [1 5 1])
     end
     
    %-------------------------------
    % Save Sequence
    %-------------------------------
    pattern_name = "Pattern" + num2str(pattern) + num2str(attractor) + ".mat";
    if toggle_save_input_sequence_to_file == true
        save(pattern_name,'input_sequence')
    end
end

function [prototypes, attractor_position, external_stimulation_time_steps_start, external_stimulation_time_steps_shared, external_stimulation_time_steps_end,positions] = genPrototypes(pattern, attractor, n_nrns, ext_activation, stutter,...
                                    shift,num_start_block, num_shared_block, num_end_block, attr_percent_ext_nrns)
%GENPROTOTYPES: This function does the main implementation of the trace
%conditioning sequence. It is called by genIMaze.  
    
    % Initialize an empty matrix with dimensions number of neurons by
    % length of trial
    prototype = zeros(n_nrns, stutter*(num_start_block + num_shared_block + num_end_block));
    
    % Create unit block:
    % The building block that are stacked later to create the beginning,
    % shared and end sequences for the I-Maze. Each block is indicated in
    % teh figure above as a dash or a separater. 
    block_unit = ones(ext_activation, stutter);
   
    % these variables act as moving pointers to indicate
    % where the next pattern of firing neurons is located
%     initial_cs_nrn = 1;
%     final_cs_nrn = cs_nrns;
%     start = 1;
%     stop = cs_duration;
%     
    
    % --- Main Training Sequence Generator ---

    % Fills in start branch neurons
    corner_shift = (ext_activation - shift)/ext_activation;
    
    if pattern == 1
        nrn_padding_start = 0;
        
    else
        nrn_padding_start = num_start_block;
        
    end
    
    if attractor == 1
            nrn_padding_end = num_start_block*2 + num_shared_block + 3*corner_shift;
    else
        nrn_padding_end = num_start_block*2 + num_shared_block + num_end_block +4*corner_shift;
    end
    
    nrn_padding_shared = num_start_block*2 + (ext_activation - shift)/ext_activation + 1*corner_shift;
    
    timestp_padding_start = 0;
    timestp_padding_shared = num_start_block;
    timestp_padding_end = num_start_block + num_shared_block;
    %disp("pattern")
    %disp(pattern)
    % build start sequence
    %disp("build start")
    add_attractor = 0;
    extra_shift = 0;
    positions = [];
    [prototypes, ~, external_stimulation_time_steps_start, positions] = buildPrototypes(prototype, extra_shift, add_attractor, block_unit, num_start_block, ...
                                nrn_padding_start, timestp_padding_start, shift, stutter, ext_activation, attr_percent_ext_nrns, positions);
    
    % insert **shared** sequence
    %disp("build shared")
    add_attractor = 0;
    extra_shift = 1;
    [prototypes, ~, external_stimulation_time_steps_shared, positions] = buildPrototypes(prototypes, extra_shift, add_attractor, block_unit, num_shared_block, ...
                                nrn_padding_shared, timestp_padding_shared, shift, stutter, ext_activation, attr_percent_ext_nrns, positions);
    
    % insert ***end*** sequence
    %disp("build end")
    add_attractor = 1;
    extra_shift = 1;
    [prototypes, attractor_position, external_stimulation_time_steps_end, positions] = buildPrototypes(prototypes, extra_shift, add_attractor, block_unit, num_end_block, ...
                                nrn_padding_end, timestp_padding_end, shift, stutter, ext_activation, attr_percent_ext_nrns, positions);
end

function [prototype, attractor_position, external_stimulation_time_steps, positions] = buildPrototypes(prototype, extra_shift, add_attractor, block_unit, num_of_blocks, ...
                                padding, time_padding, shift, stutter, ext_activation, attr_percent_ext_nrns, positions)
    %disp(" in buildPrototypes")
    %disp(extra_shift*(ext_activation - shift))
    initial_nrn = 1 + padding*ext_activation-(padding)*(ext_activation - shift);% + extra_shift*(ext_activation - shift);
    ts_padding = time_padding*stutter;
    attractor_position = [];
%     disp(["initial_nrn", num2str(initial_nrn)]);
    external_stimulation_time_steps = zeros(2,num_of_blocks);
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
%         disp(initial_nrn)
%         disp(final_nrn)
%         disp(start)
%         disp(stop)
%         disp("------")
        external_stimulation_time_steps(1,i) = start;
        external_stimulation_time_steps(2,i) = stop;
        positions = [positions initial_nrn final_nrn];
        prototype(initial_nrn:final_nrn, start:stop) = block_unit;   
        if add_attractor == 1 && i == num_of_blocks
           prototype(initial_nrn+(1-attr_percent_ext_nrns)*ext_activation:final_nrn, 1:stop) = ones(attr_percent_ext_nrns*ext_activation, stop);
           attractor_position = [initial_nrn + (1-attr_percent_ext_nrns)*ext_activation, final_nrn];
        end
    end
end