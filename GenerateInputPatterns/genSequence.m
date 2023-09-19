% Jin Lee (jhl8sb) 12 June, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a shifting input sequence
% with optional noise

function input_sequence = genSequence(pm)

    toggle_produce_visualisation_of_input = false;
    toggle_save_input_sequence_to_file    = false;
    toggle_trace = pm.toggle_trace;

    n_nrns=pm.number_of_neurons;
    len_trial=pm.length_of_each_trial;
    n_active_nrns=pm.ext_activation;
    shift=pm.shift;
    n_patterns=pm.n_patterns;
    stutter=pm.stutter;
    extra_steps = pm.extra_timesteps_train; %padding zeros at the end of train
    
    %check if 'trace_interval' was specified; used an if block as previous
    %versions of sequence generators did not allow trace intervals
    if isfield(pm,'trace_interval') 
        interval = pm.trace_interval;
    else
        interval = 0;
    end

    %generates a descending sequence
    %-------------------------------
    % Parameters
    %-------------------------------
    %   sequence
%     if ~exist('off_noise','var')
%         disp('myfunc generateSequence: Not enough arguments supplied. Using default parameters')
%         pause(0.0000000001)
%         n_nrns=100; %number of neurons
%         n_active_nrns=8;    %number of input neurons that are active for any given pattern
%         shift=4;    %number of active neurons overlapping between current and previous pattern
% 
%         %   time
%         n_patterns=10;  %number of unique patterns.
%         stutter=5;
%     end

    %-------------------------------
    % Function preconditions
    %-------------------------------
    max_n_patterns=n_nrns/(n_active_nrns-shift)-1;
    if n_patterns > max_n_patterns
        %check if variables satisfy precondition; code is robust enough to allow
        %number of patterns to be too large compared to the number of neurons, 
        %but this will result in the input cycling back to the first few patterns.
        disp('too many patterns requested; inputs will cycle back to the beginning. Increase n_nrns, or decrease n_patterns or n_active_nrns')
    elseif shift>n_active_nrns
        error('error in myfunc generateSequence: Number of active neurons cannot be lesser than shift')
    end

    %-------------------------------
    % Implementation
    %-------------------------------
    %-------------------------------
    % Generate Prototypes

    
    input_sequence = genPrototypes(n_nrns,len_trial,n_active_nrns,stutter,shift,interval,n_patterns);
    if extra_steps > 0
        % padding of zeros at the end
        input_sequence = [input_sequence, zeros(n_nrns,extra_steps)];
    end
    
    %{
    %legacy code ; ignore this comment block, code was left here just in case
    prototypes=zeros(n_nrns,len_trial);
    for t = 1:min(len_stimuli,len_trial)
        current_pattern_number=floor((t-1)/stutter);            %current pattern number starts from 0, ends at n_patterns-1
        i_start=1+current_pattern_number*(n_active_nrns-shift);    %starting row at time t
        i_end=i_start+n_active_nrns-1;                        %ending row at time t
        prototypes(i_start:i_end,t)=1;
    end
    %}


    %-------------------------------
    % Only want to store a separate copy of prototypes without noise, which will
    % be added in dynamically at the start of each trial - DS

    % Generate Noise
    % if ~(on_noise==0 && off_noise==0)
    %     input_sequence=genNoise(prototypes,on_noise,off_noise);
    % else
    %     input_sequence=prototypes;
    % end

    %-------------------------------
    % Produce Visualisation of Input
    %-------------------------------
    if toggle_produce_visualisation_of_input == true
        figure
        spy(input_sequence)
    end

    %-------------------------------
    % save
    %-------------------------------
    if toggle_save_input_sequence_to_file == true
        save('Input.mat','input_sequence')
    end
end


function prototypes = genPrototypes(n_nrns,len_trial,n_active_nrns,stutter,shift,interval,n_patterns)

    prototypes = zeros(n_nrns, len_trial);

    %represents input vector from timesteps 1:stutter
    single_stim = [ones(n_active_nrns,stutter);zeros(n_nrns-n_active_nrns,stutter)];
    % pattern of ones and zeros 
    
    %represents input vector during trace interval, i.e. a zero vector
    no_stim = zeros(n_nrns,interval);

    %the shift_operator is an elementary row operation represented as a boolean
    %square matrix that transfers the last rows (number specified by shift) to
    %the top of the matrix. 
    shift_operator_step = [[zeros(shift,n_nrns-shift) ,  eye(shift)               ];
                      [eye(n_nrns-shift)         ,  zeros(n_nrns-shift,shift)]];
    
    stop = 0;
    shift_operator = eye(n_nrns);
    for i = 1:n_patterns
        % this for loop builds the sequence
        start = stop + 1;
        stop = stop + stutter + interval; % interval = 0
        prototypes(:,start:stop) = [shift_operator*single_stim, no_stim];
        %after shift_operator has been used, generate shift operator for next
        %pattern
        shift_operator = shift_operator * shift_operator_step;
        % this is moving the pattern over the length of stutter and down
        % number of shift neurons
    end
end