%Dana Schultz, 27 Jul 2020
%Jin Lee, 26 Jun 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%added option of halting the program after a configurable number of
%successes in a row, and included data.success which is a boolean vector
%that records the trials that are successful


function [vars,data] = RunModel(param,vars,data)

    %nested loop lengths are determined by the number of trials and the length
    %of each trial
    vars.z_0_mean = [];
    if param.toggle_display_param
        disp(param)
    end
    
    seed = param.z_0_seed;

    if param.toggle_display_seed
        disp(['seed 2 = ', num2str(seed)]);
    end 
    
    rng(seed)

    n_trials = param.number_of_trials; %modify the multiplier 2 if only want to train on one attractor, have to also modify initilaiseCoreVar, genIMazePattern and rescaleparameters
    len_trial = param.length_of_each_trial;
    %disp("run model len trial")
    %disp(len_trial)
    data.successful_learning = false;
    
    %check for I-Maze/T-Maze
    if param.num_start_block > 0
        IMaze = true;
    else
        IMaze = false;
    end
    
    if param.toggle_trace == true && param.toggle_record_success == true % success data for trace conditioning
        data.successful_predictions = 0;
        data.prediction_too_soon = 0;
        data.prediction_too_late = 0;
        data.failure_to_predict = 0;
        data.list_of_results = strings(n_trials,1); 
    end
    
    if param.toggle_record_success > 0
        n_consec_successes = 0;
    end

    %tic %starts stopwatch, to measure time it takes to run through all trials
    
    for trial_number = 1:n_trials
        % initialize the input_prototype for this trial, as specified by
        % vars. input_pattern generated in InitialiseCoreVars.
        if param.toggle_I_Maze == true
            if vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 1
                vars.input_prototypes = vars.input_prototypesL1;
                vars.attractor_position = vars.attractor_posL1;
            elseif IMaze && vars.input_pattern(1, trial_number) == 2 && vars.input_attractor(1, trial_number) == 1
                vars.input_prototypes = vars.input_prototypesR1;    
                vars.attractor_position = vars.attractor_posR1;
            elseif vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 2
                vars.input_prototypes = vars.input_prototypesL2;
                vars.attractor_position = vars.attractor_posL2;
            elseif IMaze && vars.input_pattern(1, trial_number) == 2 && vars.input_attractor(1, trial_number) == 2
                vars.input_prototypes = vars.input_prototypesR2;
                vars.attractor_position = vars.attractor_posR2;
            else
                disp("ERROR: incorrect input pattern generated. Must be either 1 or 2. Check genIMazePatten.")
            end
        end 
        %disp("size of input proto at start of trial")
        %disp(size(vars.input_prototypes))
        [vars,data] = InitialiseTrial(param,vars,data);

        for timestep = 1:len_trial

            %update variables for the current timestep
            vars = UpdateSpike(param,vars,timestep);
            vars = UpdateWeights(param,vars);

            %check for errors
            CatchNegativeValues(vars)

            %track changes in variables
            vars = RecordMeanZ(vars,timestep);
            data = RecordTimestep(vars,data,timestep);
        end
        
        vars = UpdateK0(param,vars); 
        
        %Record variables of interest into the 'data' struct.
        if param.toggle_record_training == true
            data = RecordTrial(param,vars,data,trial_number);
        end

        %Keeping the current weights constant, let the network
        %run on its own and see if it is able to remember the input sequence.
        if param.toggle_testing == true
            data = TestNetwork(param,vars,data,trial_number);
        end

        if param.epsilon_k_ff > 0 %
            vars = UpdateKff(param,vars,data); %kff will not be updated unless pre then post is off
        end

        % Simple sequence success
        if param.toggle_record_success == true && param.toggle_trace == false
            if param.toggle_I_Maze == true
               current_trial_success = DetermineTrialSuccessIMaze(param,vars,data,trial_number);
            else
               current_trial_success = DetermineTrialSuccess(param,vars,data,trial_number);

            end
            %disp("result in runmodel")
            %disp(current_trial_success)
            [data,n_consec_successes] =...
                RecordSuccess(param,data,current_trial_success,n_consec_successes,trial_number);

            if param.consecutive_successes_to_halt > 0

                if n_consec_successes >= param.consecutive_successes_to_halt
                    disp([num2str(param.n_patterns),' success at trial ',num2str(trial_number)])
                    data.successful_learning = true;
                    break
                end
            end
        end
        
        % Trace sequence success
        if param.toggle_record_success == true && param.toggle_trace == true
            current_trial_success = DetermineTrialSuccessTrace(param, data, trial_number);           
            success_boolean = 0;

            % for programmer viewing (probably change to display on spy)            
            disp(['trial ', num2str(trial_number),': ', current_trial_success]);
            data.list_of_results(trial_number) = current_trial_success;
     
            if strcmp(current_trial_success, 'success')
                data.successful_predictions = data.successful_predictions + 1;
                success_boolean = 1; 
            end
            
            [data,n_consec_successes] =...
                RecordSuccessTrace(param,data,success_boolean,n_consec_successes,trial_number);
            
            if strcmp(current_trial_success, 'failure - prediction too soon')
                data.prediction_too_soon = data.prediction_too_soon + 1;
            end
            
            if strcmp(current_trial_success, 'failure - prediction too late')
                data.prediction_too_late = data.prediction_too_late + 1;
            end
            
            if strcmp(current_trial_success, 'failure to predict') 
                data.failure_to_predict = data.failure_to_predict + 1;
            end
            
            if param.toggle_display_failure_mode == true
                xlabel(current_trial_success);
            end
            
            % stop after hitting x number of consecutive successes
            % (defined in InitialiseParameters.m)
            if n_consec_successes >= param.consecutive_successes_to_halt 
                disp(['success at trial ',num2str(trial_number)])
                data.successful_learning = true;
                break
            end

            %waitforbuttonpress
            
        end   
        
    end
    
    if param.toggle_I_Maze == true
        [vars.I_Maze_test_data, data] = testIMaze(param,vars,data);
    end
    
    if true
        pause(0.0000000000000001)       
    end
end

%time_taken = toc;
%disp(['Runtime: ', num2str(time_taken), ' seconds'])


%% Subfunctions %%
%{
(When viewing on Matlab, collapsing parts of the script by clicking on the 
boxed minus sign to the left of 'function' in blue letters helps remove 
the clutter and clarify how the functions are organised)
%}
%%%%%%%%%%%%%%%%%%%%%% Training %%%%%%%%%%%%%%%%%%%%%%
function [vars,data] = InitialiseTrial(param,vars,data)
    %1. introduces noise to the prototype input sequence;
    %2. sets z to a random vector with a mean z that is roughly equal to
    %the desired average spike probability (i.e. equal to vars.desired_mean_z). 
        %The entries of the random vector are chosen by
        %generating a number on the uniform distribution between 0 and 1,
        %then checking whether that number is less than the 
        %desired_mean_z, which is also a number between 0 and 1.
        %This event has a probability equal to the desired mean z
    %3. reset the decay variables back to zero
        %Note: there are scenarios in which the network might not stop at the
        %last pattern, going back to the first and cycling through the sequence
        %again during a test run. This happens when the decay variables or 
        %the z_prev variable are not reset to zero at the beginning of each
        %training trial, in which case the network will believe that the first
        %pattern of a sequence comes immediately after the last pattern of the
        %preceding trial and create an association between the two.
    vars.z_prev     = zeros(size(vars.z_prev));
    vars.boxcar_exc = ones(size(vars.boxcar_exc)) .* mean(mean(vars.weights_excite))...
        * param.desired_mean_z * param.n_fanin;
    vars.boxcar_inh = ones(size(vars.boxcar_inh)) * param.desired_mean_z...
        * param.weight_inhib_start;
    if param.toggle_training_attractor == false && param.toggle_I_Maze == true
        attractor_start = vars.attractor_position(1);
        attractor_end = vars.attractor_position(2);
        vars.input_prototypes(attractor_start:attractor_end, :) = zeros(attractor_end - attractor_start+1,size(vars.input_prototypes, 2));
    end
    if param.toggle_trace == true
         vars.input_current_trial = genNoiseTrace(vars.input_prototypes,param.on_noise,param.off_noise);%trace conditioning
    elseif param.toggle_I_Maze == true
        %disp("size prototypes in initrialise")
        %disp(size(vars.input_prototypes))
         vars.input_current_trial = genNoise(vars.input_prototypes,param.on_noise,param.off_noise);%I-Maze genNoise
    else
        vars.input_current_trial = genNoise(vars.input_prototypes,param.on_noise,param.off_noise); %simple sequence
    end
    vars.z = rand(param.number_of_neurons,1) < param.desired_mean_z; % z_0 : initialize random z vector at time 0 
    vars.z_0_mean = [vars.z_0_mean, mean(vars.z)];
    vars.z_pre_then_post_decay = zeros(param.number_of_neurons,1);
    vars.z_post_then_pre_decay = zeros(param.number_of_neurons,1);

    %use if testing the network's ability to control its activity;
    %this turns off external inputs and lets the network run on its own.
    if param.toggle_external_input == 0
        vars.input_current_trial=zeros(size(vars.input_prototypes));
    end
end


function vars = UpdateSpike(param,vars,timestep)
    %if error indicates 'index in position 2 is invalid', check if t is -1.
    %if it is, then there is a problem with the function triggers. Refer to
    %ControlFxnTriggerIdx


    %% Get Inputs:
    %assign variables from the cv struct into variables accessed directly
    %by this function
%     disp("timestep")
%     disp(timestep)
%     disp("size of input current trial")
%     disp(size(vars.input_current_trial))
    x               = vars.input_current_trial(:,timestep);
    z               = vars.z;
    connection_mat  = vars.connections_fanin;
    k_0             = vars.k_0;
    k_fb            = vars.k_fb;
    k_ff            = vars.k_ff;
    w_fbinhib       = vars.weights_feedback_inhib;
    w_excite        = vars.weights_excite;
    boxcar_exc      = vars.boxcar_exc;
    boxcar_inh      = vars.boxcar_inh;
    exc_scales      = vars.boxcar_scales;
    inh_scales      = vars.boxcar_scales_inh;
    refractory      = vars.boxcar_refractory_period;
    
    %% update Spike at timestep t

    %as the output vector z hasn't been updated yet for the current timestep, 
    %it still corresponds to the activation of the previous timestep.
    z_prev = z;

    
    %recall that connection_mat is a fanin connection matrix. Therefore,
    %every ith row vector specifies the indices of the presynaptic neurons 
    %that ennervate the ith neuron. 
    %z(connection_mat) is a matrix the rearranges the output z into a matrix
    %corresponding to connection_mat, such that every entry on the ith row 
    %indicates which presynaptic neurons that ennervate the ith 
    %neuron have fired.
    %
    %the excitatory weights (w_excite) are organised according to the same 
    %fanin connection scheme, so an element by element multiplication '.*'
    %of the rearranged output matrix and weights as done below should indicate
    %(on every ith row) the individual presynaptic activations that take place
    %before being summed up postsynaptically by the ith neuron.

    Wz_exc = sum(z(connection_mat) .* w_excite,2);

    %{
    %push each boxcar by 1 column to the right and replace the first column 
    %of the boxcar matrix with Wz_exc
    boxcar_exc = PushBoxcar(boxcar_exc, Wz_exc); %matrix is in M_{n_nrns\times n_boxcars}
    %sum boxcar terms according to the distribution specified in boxcar_pmf
    excite = boxcar_exc*boxcar_pmf'; %boxcar_pmf is a vector in \mathbb{R}^n_boxcars
    %}

    %speeded up the code
    
    %returns total excitation(scalar) and new boxcar window of Wz values(matrix)
    [excite,boxcar_exc] = BoxcarStep(Wz_exc, boxcar_exc, exc_scales);
    
    %{
    %function [excite,boxcar_exc] = BoxcarStep(Wz_exc, boxcar_exc, boxcar_pmf, timestep)
    t_modulo = mod(timestep,numel(boxcar_pmf));
    boxcar_exc(:,t_modulo) = Wz_exc;
    excite = boxcar_exc * boxcar_pmf([t_modulo:end,1:t_modulo-1])';
    %}

    %the same boxcar algorithm is used to calculate inhibition
    Wz_inh = sum(w_fbinhib .* z_prev);
    %boxcar_inh = PushBoxcar(boxcar_inh, Wz_inh);
    %fb_inh=boxcar_inh*boxcar_pmf';
    [inhib_fb,boxcar_inh] = BoxcarStep(Wz_inh, boxcar_inh, inh_scales);

    %The following inhibition equation is based on Dave's rule. 
    %k_0 ensures that the mean_z activity of the network equals the desired
    %   mean_z specified. This is done at the end of each trial by 
    %   increasing k_0, and therefore inhibition, whenever there is too much 
    %   activity, and decreasing it when there is too little.
    %w_fbinhib, which stands for feedback inhibitory weights, corresponds to 
    %   the inhibition based on the activity of individual neurons;
    %k_ff*sum(x), just as k_0, controls overall activity,
    %   but is based on external inputs and is therefore set to 0 when testing
    %   (as the external stimulus is turned on only when training)
    inhib = k_0   +    k_fb*(inhib_fb)   +   k_ff*sum(x);

    %the y postsynaptic activation vector is calculated based
    %on the excitation and inhibition vectors
    y = excite./(excite+inhib);
    
    %each neuron spikes if its activation is greater than the spike_threshold
    %(which is arbitrarily set to 0.5 in this model)
    z = y>vars.spike_threshold | x == 1;
    if param.toggle_activity_coerce
        bound = param.bound_percent;
        activity = sum(z) - sum(x, 'all'); 
        non_extern_y = y.*(~x); % x: external input, get rid of the externals for this process, temporarily
        desired_firing_count = param.desired_mean_z*param.number_of_neurons - sum(x, 'all'); %count total number of desired firing nrn
%         disp(desired_firing_count)
%         disp(sum(x))
        [~,sorted_index] = sort(non_extern_y, 'descend');
        
        if activity < desired_firing_count*(1-bound)
            z(sorted_index(1:desired_firing_count*(1-bound))) = ones(1,desired_firing_count*(1-bound));
        elseif activity > desired_firing_count*(1+bound)
            z(sorted_index(desired_firing_count*(1+bound)+1:end)) = zeros(1,length(y)-desired_firing_count*(1+bound));
        end 
    end
    z(x == 1) = ones(1, sum(x)); 
    if sum(z) < desired_firing_count*(1-bound)
        disp("WARNING LOW ACTIVITY!!!")
        disp(timestep)
        disp(desired_firing_count)
        disp(sum(x))
    end
    if refractory > 0 ...    %if refractory period is nonzero
            && length(exc_scales)>refractory       %and is well defined
        switch param.toggle_divisive_refractory
            case false
                boxcar_exc = BoxcarRefractory(z,boxcar_exc,refractory,inhib,exc_scales,timestep);
                %subtracts the appropriate amount from the parts of the boxcar
                %corresponding to the refractory value, thereby preventing
                %the neuron from firing during the refractory period
            case true
                [boxcar_exc] = BoxcarRefractory2(z,boxcar_exc,refractory);
                %divides the boxcar by the refractory value
        end
            
    end

    %% Output
    %assign output to the struct
    vars.boxcar_exc = boxcar_exc;
    vars.boxcar_inh = boxcar_inh;
    vars.z_prev = PushBoxcar(vars.z_prev,z_prev); %vars.z_prev is a matrix of previous values; insert most recent z_prev in left column and push all other columns to the right (deleting the rightmost column)
    vars.z = z;
    vars.y = y;
end


function vars = UpdateWeights(params,vars)
    %% retrieve inputs from struct
    fractional_mem_pre      = params.fractional_mem_pre;
    fractional_mem_post     = params.fractional_mem_post;
    e_pre_then_post         = params.epsilon_pre_then_post;
    e_post_then_pre         = params.epsilon_post_then_pre;%st stands for spike timing
    e_fb                    = params.epsilon_feedback;%fb stands for feedback

    w_excite                = vars.weights_excite;
    connection_mat          = vars.connections_fanin;
    z_pre_then_post_decay   = vars.z_pre_then_post_decay;
    z_post_then_pre_decay   = vars.z_post_then_pre_decay;
    z                       = vars.z;
    w_fbinhib               = vars.weights_feedback_inhib;
    
    z_memory                = [z vars.z_prev]; %array of all stored z values; allows z bar to access current and past timesteps
    z_offset_pre            = z_memory(:,params.offset_pre_then_post + 2); %always looks at least 1 timestep back
    z_offset_post           = z_memory(:,params.offset_post_then_pre + 1); 
    z_prev                  = vars.z_prev(:,1);
    
    mean_z                  = vars.mean_z;
    desired_mean_z          = params.desired_mean_z;


    %% update weights 
    %weights for feedback excitation 

    if params.toggle_pre_then_post == true
        %(z_prev == true/false) can be seen as an if statement; 
        %e.g. 
        %>> (z_prev==1) + (z_prev == 0).*(decay_nmda.*z_nmda_decay)
        %can be interpreted as
        %   if (the previous output did fire), then return 1;
        %   if (the previous output did not fire),
        %       then return decay_nmda.*z_nmda_decay 
        %           (i.e. make the current value in z_nmda decay)

        %This method was used instead of for loops because it allows such
        %conditional operations to be executed on the entire vector 
        %all at once (taking advantage of Matlab's parallel operations on arrays),
        %which is much faster than looping through each vector entry.

        z_pre_then_post_decay = (z_offset_pre==1)+(z_offset_pre==0).* ...
            (fractional_mem_pre.*z_pre_then_post_decay); %saturate decay rate
        dw_excite = e_pre_then_post*z.*(z_pre_then_post_decay(connection_mat)-w_excite);
        w_excite = w_excite+dw_excite;
    end

    if params.toggle_post_then_pre == true
        % if there is a spike at the current output, rise to 1,
        % otherwise make the current value decay.
        z_post_then_pre_decay = (z_offset_post==1) + (z_offset_post==0) ...
            .* (fractional_mem_post .* z_post_then_pre_decay); %saturate decay
        dw_excite = -e_post_then_pre .* z_prev(connection_mat) .* z_post_then_pre_decay .* w_excite;
        w_excite = w_excite + dw_excite;
        % Old version:
        % z_post_then_pre_decay = (z==1) + (z==0) .* (fractional_mem_post .* z_post_then_pre_decay); %saturate decay
        % dw_excite = -e_post_then_pre .* z(connection_mat) .* z_post_then_pre_decay .* w_excite;
    end

    %update weights for feedback inhibition (aka Dave's rule)
    dw_fbinhib = e_fb* z_prev .* (mean_z - desired_mean_z);
    weights_feedback_inhib = w_fbinhib + dw_fbinhib;


    %% write outputs to struct
    vars.weights_excite = w_excite;
    vars.weights_feedback_inhib = weights_feedback_inhib;
    vars.z_pre_then_post_decay = z_pre_then_post_decay;
    vars.z_post_then_pre_decay = z_post_then_pre_decay;

end

function vars = UpdateK0(params,vars)
    %% get inputs from structs
    e_k_0            = params.epsilon_k_0; %rate constant epsilon for k_0
    k_0              = vars.k_0;
    mean_z_train     = vars.mean_z_train_current_trial;
    desired_mean_z   = params.desired_mean_z;
    trial_mean_z     = mean(mean_z_train);
    %^ this is the average spike rate of all neurons throughout the entire
    %trial

    %% update k_0
    %dk_0=e_k_0*(desired_mean_z - trial_mean_z);
    dk_0=e_k_0*(trial_mean_z - desired_mean_z);
    %disp(["trial_mean_z", num2str(trial_mean_z), " trial_mean_z - desired_mean_z ", num2str(trial_mean_z - desired_mean_z)])
    k_0=k_0+dk_0;

    %% record output to struct
    vars.k_0 = k_0;
    vars.k_ff = 0.1*k_0;
    %disp(["in update k0, new k0", num2str(vars.k_0)])
    vars.mean_z_current_trial = trial_mean_z;
end

function vars = UpdateKff(params,vars,data)
   %% get inputs from structs
    trial_mean_z     = vars.mean_z_current_trial;
    e_k_ff           = params.epsilon_k_ff;
    k_ff             = vars.k_ff;
    z_test           = data.z_test_last_trial; %actually means "current," as Kff updates happens after each trial
    test_mean_z      = mean(mean(z_test));
    desired_mean_z   = params.desired_mean_z;
    %vars for k_0 compensation
    k_0              = vars.k_0;
    %n_inputs         = params.n_active_nrns;
    off_noise        = params.off_noise;
    %disp(["prev kff", num2str(k_ff)])
    %% update k_ff
    dk_ff = e_k_ff*(trial_mean_z-desired_mean_z);
    %disp(["dk_ff", num2str(dk_ff)])
    k_ff = k_ff+dk_ff;

    %% compensate k_0
    %Note that as the contribution of feedforward inhibition is
    %k_ff*n_ext_nrns, to keep the total inhibition constant we need to subtract
    %this feedforward inhibition contribution from k_0.

    %n ext nrns that are active per timestep
%     n_ext_nrns = double(n_inputs-off_noise);
%     k_0 = k_0 - n_ext_nrns*dk_ff;
%     disp("dk_ff")
%     disp(dk_ff)
    %% record output to struct
    vars.k_ff = k_ff;
%     vars.k_0 = k_0;
%     disp("k_ff")
     %disp(k_ff)
end



%%%%%%%%%%%%%%%%%%%%%% Post training %%%%%%%%%%%%%%%%%%%%%%

function CatchNegativeValues(vars)
    if vars.k_0<0
        disp(vars)
        vars.k_0=0;
        warning('k_0 < 0; not biologically meaningful. To resolve, decrease k_fb or k_ff')
    elseif prod(vars.weights_excite>=0) == 0 %error if any weight is negative
        warning('there is a negative synaptic weight; not biologically meaningful')
    end
end


function vars = RecordMeanZ(vars,timestep)
    vars.mean_z=mean(vars.z);
    vars.mean_z_train_current_trial(timestep)=vars.mean_z;
end


function data = RecordTimestep(vars,data,timestep)
    data.z_train_last_trial(:,timestep) = vars.z;
    data.y_train_last_trial(:,timestep) = vars.y;
end


function data = RecordTrial(params,vars,data,trial_number)
    viewing_range = params.nrn_viewing_range(2);
    current_trial = data.z_train_last_trial;
    if params.toggle_record_z_train == true
        data.z_train(:,:,trial_number) = current_trial;
    end
    if params.toggle_record_y
        data.y_train(:,:,trial_number) = data.y_train_last_trial;
    end
    %spy(current_trial)
    if params.toggle_figures == true
        subplot(2,7,[1,8])
        SpySelected(current_trial,params.nrn_viewing_range)
        title('training')
        set(gca, 'PlotBoxAspectRatio', [1 5 1])
        if params.toggle_I_Maze == true
            
            yline(vars.attractor_posL1(2),'-','goal neurons');
            yline(vars.attractor_posL2(2),'-','goal neurons');
        end
        
        subplot(2,7,3)
        plot(mean(current_trial,1))
        ylim([0,params.desired_mean_z*2])
        line([0,params.length_of_each_trial],...
            repmat(params.desired_mean_z,[1,2]),'Color','red', 'LineStyle', ':')
        xlim([0,params.length_of_each_trial])
        title({'training trial mean activity,', 'with desired activity in red'})
        
        %spy context neurons
        subplot(2,7,[4,11])
        spy(current_trial(params.nrn_viewing_range(1, 2)+1:end,:))
        set(gca, 'PlotBoxAspectRatio', [1 5 1])
        title('training context nrns')
        set(gcf,'Position',[10 10 1200 1200])
        
        
    end
    title(['training trial ', num2str(trial_number)])
    xlabel(['training mean z = ', num2str(vars.mean_z_current_trial)])
    pause(0.000000000001)

    %%added part: 
    data.mean_z_train_all_trials(:,trial_number) = vars.mean_z_train_current_trial;
    data.mean_z_train_last_trial(:,:) = vars.mean_z_train_current_trial;
    
    if params.toggle_record_k0 == true
        data.k0_history(trial_number)       = vars.k_0;
    end
    if params.toggle_record_kff == true
        data.kff_history(trial_number)      = vars.k_ff;
    end

    if params.toggle_record_weights_exc == true && ...
            params.epsilon_pre_then_post > 0 && ...
            params.toggle_pre_then_post == true &&...
            params.toggle_I_Maze == true
        data.w_excite_trial(:,:,trial_number) = vars.weights_excite;
        subplot(2, 7, [6,7,13,14])
        
        %disp(size(vars.input_prototypes))
        
        if params.toggle_I_Maze == true
            template_matrix = data.w_excite_trial(1:vars.attractor_position(1,2), :, trial_number); %pull weight data for all 2000 neurons at this trial
        end
        %disp(size(template_matrix))

        
        h = histogram(template_matrix, 10);
        h.Normalization = 'probability';
        set(gca, 'PlotBoxAspectRatio', [1 4 1])
    end
    if params.toggle_record_weights_inh == true
        data.w_inhib_trial(:,trial_number) = vars.weights_feedback_inhib;
    end
end


function data = TestNetwork(params,vars,data,trial_number)
    %disp("in test network")
    %make sure cv is not an output variable of the function
    [vars,~] = InitialiseTrial(params,vars,000); %the 000 is just a stub

    len_trial = params.test_length_of_each_trial;
    n_nrns    = params.number_of_neurons;
    
    on_noise = double(params.test_on_noise); 
    off_noise = double(params.test_off_noise);
    %make sure the attractor is on for the entire duration of the stimuli

    attractor_beg = vars.attractor_position(1, 1);
    attractor_end = vars.attractor_position(1, 2);
    
    test_stimulus_no_noise = zeros(size(vars.input_prototypes, 1), len_trial);
    test_stimulus_no_noise(1:size(vars.input_prototypes, 1), 1:params.first_stimulus_length) = vars.input_prototypes(:,1:params.first_stimulus_length);
    test_stimulus_no_noise(attractor_beg:attractor_end, :) = ones(params.attr_percent_ext_nrns*params.ext_activation, len_trial);%makes the external test activation noisy
    %test_stimulus = genNoise(test_stimulus_no_noise, on_noise, off_noise);
    
    vars.input_current_trial = zeros(n_nrns,len_trial,'logical');
%     vars.input_current_trial = zeros(size(vars.input_current_trial),'logical');
    vars.input_current_trial(:,:) = test_stimulus_no_noise;
  
    current_test = zeros(n_nrns,len_trial,'logical');

    for timestep = 1:len_trial
        vars = UpdateSpike(params,vars,timestep);      
        if params.toggle_trace == true
            %vars.z = genNoiseTrace(vars.z,on_noise,off_noise); %apply noise to test trace sequence
        else
            %disp("gen noise for var.z")
            vars.z = genNoise(vars.z,on_noise,off_noise); %apply noise to test simple sequence
        end
        current_test(:,timestep) = vars.z;
    end
    [r_firing, w_firing,~, ~, choice_diff, goal_diff, r_start, r_end, w_start, w_end, t_start, t_end] = DetermineTMazeSuccess(trial_number, params, current_test, vars, 0);
    data.choice_point_firing(:, trial_number) = [r_firing, w_firing,0, 0, choice_diff, 0];
    %spy(current_test)
    if params.toggle_figures ==  true
        subplot(2,7,[2,9])
        SpySelected(current_test,params.nrn_viewing_range)
        title('testing')
        set(gca, 'PlotBoxAspectRatio', [1 5 1])
        yline(vars.attractor_posL1(2),'-','goal neurons');
        yline(vars.attractor_posL2(2),'-','goal neurons');
        fontsize = 10;
        yline(r_start,'--','correct CP','FontSize',  fontsize, 'LabelVerticalAlignment', 'top',"LineWidth", 2,"Color", "#ffe32b");
        yline(r_end,'--','FontSize',  fontsize, 'LabelVerticalAlignment', 'top',"LineWidth", 2,"Color", "#ffe32b");
        yline(w_start,'--','wrong CP','FontSize',  fontsize, 'LabelVerticalAlignment', 'top',"LineWidth", 2,"Color", "#e36319");
        yline(w_end,'--','FontSize''--','FontSize',  fontsize, 'LabelVerticalAlignment', 'top',"LineWidth", 2, "Color", "#e36319");
        xline(t_start,'--','t-start CP','FontSize',  fontsize, 'LabelVerticalAlignment', 'top',"LineWidth", 2);
        xline(t_end,'--','t-end CP','FontSize',  fontsize, 'LabelVerticalAlignment', 'top',"LineWidth", 2);
        xlabel(['choice_diff = ', num2str(choice_diff),  "goal_diff: ", num2str(goal_diff)])
        
        subplot(2,7,10)
        plot(mean(current_test,1))
        ylim([0,params.desired_mean_z*2])
        line([0,params.length_of_each_trial],...
            repmat(params.desired_mean_z,[1,2]),'Color','red','LineStyle',':')
        xlim([0,params.length_of_each_trial])
        title({'testing trial mean activity,', 'with desired activity in red'})
        
        %spy context neurons
        subplot(2,7,[5,12])
        spy(current_test(params.nrn_viewing_range(1, 2)+1:end,:))
        set(gca, 'PlotBoxAspectRatio', [1 5 1])
        title('testing context nrns')
        set(gcf,'Position',[10 10 1200 1200])
      
    end
    
    if params.toggle_record_success == true && params.toggle_trace == true %trace : display success lines
        global success_timestep_1;
        global success_timestep_2;
        global cs_duration;
        global trace_duration;
        start_of_us_nrns = cs_duration + trace_duration + 1; %timestep of US onset
        xline(success_timestep_1);
        xline(success_timestep_2);
        xline(start_of_us_nrns, '-','US onset');
    end   
    
    title({['test using weights from trial ',num2str(trial_number)],...
            ['mean',num2str(mean(mean(current_test)))]})    
    pause(0.00000000000001)
    data.z_test_last_trial = current_test;
    data.mean_z_test_last_trial = mean(current_test)';
    if params.toggle_record_z_test==true
        data.z_test(:,:,trial_number) = current_test;
    end
end


function [data,n_consec_successes] = RecordSuccess(params,data,result_code,n_consec_successes,trial_number)
    data.success_vect(trial_number) = result_code;
    success_code = FailureModeDictionary('success');
    n_consec_successes = (n_consec_successes+(result_code == success_code))*(result_code>0);
    data.max_consecutive_successes = max(n_consec_successes,data.max_consecutive_successes);

    if params.toggle_display_failure_mode == true
        failmode_msg = [char(FailureModeDictionary(result_code)), num2str(result_code)];
        xlabel(failmode_msg)
        pause(0.0000000000000001)
    end
end


function [data, n_consec_successes] = RecordSuccessTrace(params,data,trace_result_code,n_consec_successes,trial_number)
    data.success_vect(trial_number) = trace_result_code; 
    success_code = 1;
    n_consec_successes = (n_consec_successes+(trace_result_code == success_code))*(trace_result_code>0);
end    

function [success_rate, data] = testIMaze(params,vars,data)
    data.final_test_vect = [];
    data.final_test = [];
    toggle_I_Maze = params.num_start_block > 0;
    success_count = 0;
    trial = 0;
    data.final_choice_point_firing = zeros(6, 2*params.test_reps_for_each_pattern);
    if toggle_I_Maze
        num_patt_to_test = 4;
    else
        num_patt_to_test = 2;
    end
    
    for pattern = 1:num_patt_to_test
        %determine input prototype & attractor
        if pattern == 1
            vars.input_prototypes = vars.input_prototypesL1;
            vars.attractor_position = vars.attractor_posL1;
            tite_name = "testing L1";
        elseif pattern == 2
            vars.input_prototypes = vars.input_prototypesL2;
            vars.attractor_position = vars.attractor_posL2;
            tite_name = "testing L2";
        elseif toggle_I_Maze && pattern == 3
            vars.input_prototypes = vars.input_prototypesR1;
            vars.attractor_position = vars.attractor_posR2;
            tite_name = "testing R1";
        elseif toggle_I_Maze && pattern == 4
            vars.input_prototypes = vars.input_prototypesR2;
            vars.attractor_position = vars.attractor_posR2;
            tite_name = "testing R2";
        end
        for rep = 1:params.test_reps_for_each_pattern
            trial = trial + 1;
            %make sure cv is not an output variable of the function
            [vars,~] = InitialiseTrial(params,vars,000); %the 000 is just a stub

            len_trial = params.test_length_of_each_trial;
            n_nrns    = params.number_of_neurons;

            on_noise = double(params.test_on_noise); 
            off_noise = double(params.test_off_noise);
            %make sure the attractor is on for the entire duration of the stimuli
            attractor_beg = vars.attractor_position(1, 1) - 5;
            attractor_end = vars.attractor_position(1, 2);

            test_stimulus_no_noise = zeros(size(vars.input_prototypes, 1), len_trial);
            test_stimulus_no_noise(1:size(vars.input_prototypes, 1), 1:params.first_stimulus_length) = vars.input_prototypes(:,1:params.first_stimulus_length);
            test_stimulus_no_noise(attractor_beg:attractor_end, :) = ones(params.attr_percent_ext_nrns*params.ext_activation+5, len_trial);%makes the external test activation noisy
            test_stimulus = genNoise(test_stimulus_no_noise, on_noise, off_noise);

            vars.input_current_trial = zeros(n_nrns,len_trial,'logical');
            vars.input_current_trial = zeros(size(vars.input_current_trial),'logical');
            vars.input_current_trial(:,:) = test_stimulus;

            current_test = zeros(n_nrns,len_trial,'logical');

            for timestep = 1:len_trial
                vars = UpdateSpike(params,vars,timestep);      
                if params.toggle_trace == true
                    vars.z = genNoiseTrace(vars.z,on_noise,off_noise); %apply noise to test trace sequence
                else
                    %disp("gen noise for var.z")
                    vars.z = genNoise(vars.z,on_noise,off_noise); %apply noise to test simple sequence
                end
                current_test(:,timestep) = vars.z;
            end
            [right_firing, wrong_firing,~, ~, choice_diff, goal_diff,...
            r_start, r_end, w_start, w_end, t_start, t_end] = DetermineTMazeSuccess(trial, params, current_test, vars, 1);
            data.final_choice_point_firing(:, trial) = [right_firing, wrong_firing,0, 0, choice_diff, 0];
            %spy(current_test)
            if params.toggle_figures ==  true
                subplot(2,5,[2,7])
                SpySelected(current_test,params.nrn_viewing_range)
                title(['FINAL TESTING trial ', num2str(trial) ])
                set(gca, 'PlotBoxAspectRatio', [1 5 1])
                yline(vars.attractor_posL1(2),'-','goal neurons');
                yline(vars.attractor_posL2(2),'-','goal neurons');
                yline(vars.attractor_posL2(2),'-','goal neurons');
                xlabel(['choice_diff = ', num2str(choice_diff),  "goal_diff: ", num2str(goal_diff)])
          
                subplot(2,5,8)
                plot(mean(current_test,1))
                ylim([0,params.desired_mean_z*2])
                line([0,params.length_of_each_trial],...
                    repmat(params.desired_mean_z,[1,2]),'Color','red', 'LineStyle', ':')
                xlim([0,params.length_of_each_trial])
                title({'testing trial mean activity,', 'with desired activity in red'})
                
                %spy context neurons
                subplot(2,5,[5,10])
                spy(current_test(params.nrn_viewing_range(1, 2)+1:end,:))
                set(gca, 'PlotBoxAspectRatio', [1 5 1])
                title('FINAL TESTING context nrns')
                set(gcf,'Position',[10 10 1200 1200])
            end
            
            %current_trial_success = DetermineTrialSuccessIMaze(params,vars,data,rep);
            %disp("current_trial_success")
            %disp(current_trial_success)
            %if strcmp(current_trial_success, 'success')
            %data.final_test_vect = [data.final_test_vect current_trial_success];
            data.final_test(:, :, trial) = current_test;
%             title({[tite_name],['test using weights from rep ',num2str(rep), ],...
%                     ['mean',num2str(mean(mean(current_test)))], ['result:', num2str(current_trial_success)]})    
             pause(0.00000000000001)
            data.z_test_last_trial = current_test;
            data.mean_z_test_last_trial = mean(current_test)';
%             if params.toggle_record_z_final_tests == true
%                 data.z_final_test(:,:,trial_number) = current_test;
%             end
%             if current_trial_success == 10
%                 success_count = success_count + 1;
%             end
           
        end
    end
     %%disp("success_rate")
     success_rate = success_count/(params.num_test_pattern * params.test_reps_for_each_pattern);
end