% Jin Lee (jhl8sb) 5 Jan, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine trial success FOR SLOWLY SHIFTING STRAIGHT STAIRCASE SEQUENCES

function result_code = DetermineTrialSuccess(parameters,variables,data,trial)
    debug_mode = false;
    %{
    %previously used was the path method (which is now discontinued), where
    %we define a valid path on the ordered set of patterns as being
    %x |-> x or x |-> x+1 where x is the current pattern number.
    %Take the cosine matrix, convert to logical and check if there
    %exists a path from the first to the last pattern where the steps allowed
    %are dwell and jump 1 pattern
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Ordered First Firing Method of Determining Successful Trials
    %to determine the success of a network, instead of thinking in terms of
    %neurons firing, we think in terms of 'patterns firing', where if even 1
    %neuron corresponding to pattern x fires, we consider it the same as every
    %neuron in pattern x firing. The matrix describing the firing of patterns
    %over time is referred to as the filter matrix.
    %The output of a trial is considered a successful one if the following 
    %conditions are all met:
    %1) every pattern must fire
    %2) There exist a sequence of nonzero entries (x_i,t_i)_{i \in 1:n_pat} 
    %   in the filter matrix, where
    %   for all i<j, x_i < x_j and t_i < t_j
    %3) the output must not be 'too noisy', where
    %
    %we use the following criterion to classify noisy inputs:
    %       the first and last patterns fire too close together in time
    %   OR  the last pattern fires before the middle pattern has ever fired
    %
    %
    %Finally, the function
    %classifies failure modes or successes and assigns a numeric code used to
    %classify the outcome of the network's output. These numeric codes can be
    %found in ./Helpers/FailureModeDictionary.m and the process of identifying
    %these failure modes is described in the comments written on the second 
    %chain of if else statements in this file.



    %Obtain test output of the network at given trial, number of patterns,
    %length of each trial and prototype input, 
    %which is an unnoised version of the input fed to the network

    prototypes  = variables.input_prototypes;
    if parameters.toggle_record_z_test == true
        test_mat    = data.z_test(:,:,trial); 
    else
        test_mat    = data.z_test_current_trial; %this is faster.
    end
    n_pat       = parameters.n_patterns;
    len_trial   = parameters.length_of_each_trial;


    %boxcar adjustments: The function needs to recognise recent firings, but as
    %the boxcar gets larger, the timescale becomes finer, which makes looking
    %at individual timesteps unreliable- for example, at boxcar 4, we need to
    %recognise an action potential and the 3 timesteps that follow 
    %that action potential as being equivalent to a an action potential and
    %the single timestep that follows it in boxcar 2, or simply with one
    %action potential in boxcar 1.

    timescale = numel(parameters.boxcar);

    unique_proto = flip(unique(prototypes','rows'))';
    cosine_matrix = GetCosineComparisonMatrix(unique_proto,test_mat);


    %We want to filter out noisy outputs, and therefore set a threshold for the
    %strength of a specific pattern being recognised as a function of the
    %weakest pattern strength throughout the trial.
    filter_threshold=min(max(cosine_matrix,[],2))/2;

    %denote threshold indicator matrix as filter
    filter = cosine_matrix> filter_threshold;

    %start with a state_vect that is 0 everywhere except for the first entry,
    %which is set to timescale+1.
    %if pattern i fires at timestep t and the state_vect is nonzero at entry i
    %or (i-1), then set entry i to timescale+1. This way, the only way that
    %condition (2) stated in the beginning of the file can be met is if the
    %last entry of the state_vect is nonzero, since the only way it can be so
    %is if pattern(n_pat) fires after the preceding pattern has already fired,
    %and so on recursively.

    %If it doesn't fire afterwards, subtract until it reaches 1. (in other
    %words we want to indicate that this neuron has not fired for some time
    %while simultaneously indicating that it has fired at some point in the
    %past.
    state_vect          = zeros(n_pat,1);
    decay_vect          = state_vect;
    disp("size of state vec")
    disp(size(state_vect))
    state_vect(1) = timescale+1;


    for t = 1:len_trial
        %state_update_vect(2:end) = filter(1:end-1,t) .* (state_vect(1:end-1)>0);
        disp("determine trial succ")
        disp(state_vect+[0;state_vect(1:end-1)])
        state_update_vect = (filter(:,t) .* (state_vect+[0;state_vect(1:end-1)]))>0;
        decay_vect(state_vect>1) = state_vect(state_vect>1)-1;
        state_vect = (timescale+1)*state_update_vect+(state_update_vect==0).*decay_vect;

        if debug_mode == true
            %uncomment this block if there is a problem with the decoding and you
            %would like to figure out what is going on timestep by timestep in the
            %decoding process
            subplot(2,1,1)
            MatImshow((filter.*((ones(n_pat,len_trial))+4*[zeros(n_pat,t-1),ones(n_pat,1),zeros(n_pat,len_trial-t)]))./5)
            subplot(2,1,2)
            MatImshow(repmat(state_vect/5,[1,10]))
            waitforbuttonpress
        end


        %check premature end of sequence
        %{
        if filter(end,t) == 1 && state_vect(ceil(n_pat/2)) == 0
            result_description = 'premature end of sequence';
            break
        end
        %}
        %the following if statement is a simplification of the statement
        %{filter(end,t)=1        AND       state_vect(first entry)>1} ...(*)
        %       OR 
        %{filter(end,t)=1        AND       state_vect(middle entry)==0) ...(**)
        %where statement (*) states that the first and last pattern fired at
        %the same time, and statement (**) states that the last pattern fired
        %before the network was able to get to the middle of the pattern
        %sequence. Both conditions are used to judge the existence of a
        %'premature end of sequence' which is in almost all cases 
        %(AS EMPIRICALLY, BUT NOT LOGICALLY OBSERVED) due to large amounts of
        %noise in the network.
        if (t<parameters.stutter || state_vect(ceil(n_pat/2)) == 0) && filter(end,t) == 1
            break
        end
    end


    %success = state_vect(end)>0;


    %%%%% IDENTIFY the failure mode:
    %we start by finding the pattern whose patterns fired the most often, which
    %will eventually tell us whether our network output has an attractor or is
    %noisy
    cos_mat_sum = sum(cosine_matrix,2);
    attractor_idx = cos_mat_sum == max(cos_mat_sum);

    if sum(test_mat(:,end)) == 0 
        %if the network output is 0 at the end, it must have
        %become zero some time before the end, since the 0 output is a
        %stopping state of the Markov chain.
        if state_vect(end)>0 
            result_description = 'success';
        else
            result_description = 'activity died out';
        end
    elseif attractor_idx(1) == 1 && state_vect(end)==0
        %If there is too much noise in the network, then the pattern
        %that fired most often should be the first one, since it was driven in
        %the first few timesteps and all subsequent firings should roughly be
        %random and equally likely
        result_description = 'noise';
    elseif t<len_trial %if premature end of seq caused for loop to break mid run
        %if it was the last pattern that fired the most often then we have a
        %last pattern attractor and therefore a premature end of sequence due
        %to overcompression. 
        %Otherwise, we have a failure mode in which the
        %network output is not noisy, the last
        %output was not an attractor, yet activity was sustained which is a
        %situation never before encountered - yet.


        if attractor_idx(end)==1 %if last pat fired most often
            result_description = 'overcompression';
        else
            result_description = 'unknown failure mode';
        end
    elseif state_vect(end)>0
        %The condition for success described in the beginning of this file can
        %be met if and only if state_vect(end) is nonzero.
        result_description = 'success';
    else
        %if the network's activity did not die out, and the output is not
        %noisy, then the network is most likely tracking the sequences in the
        %correct order (this is a statement based on empirical
        %observations, without proof). Therefore, if it wasn't able to get to
        %the end, the network's state must have been caught up in the
        %intermediate steps of the sequence of patterns. In other words, if
        %the mouse is properly following the maze but was not able to get to the
        %end, it was probably stuck somewhere in the middle. In other words,
        %the network developed an attractor that is holding it back.
        if sum(state_vect(:,end)>1) == 0
            %if no external neurons are firing then the attractor is in the
            %context neurons
            result_description = 'context attractor';
        else
            result_description = 'attractor';
        end
    end


    %%%%% RETRIEVE the failure mode code.
    %some multiple of 10, where further identification of the error is
    %described in the decimals
    result_identifier = FailureModeDictionary(result_description);
    result_code = result_identifier;
    
    switch result_description
        case {'success','noise','overcompression'}
        case 'attractor'
            %result in [-11,-10)
            %there was an attractor
            %therefore look for pattern that was recognised the most often
            %
            %we would like to track which pattern was the strongest attractor,
            %and how many patterns were learned by the sequence. Therefore,
            %the decimal identifier has two components. The first indicates the
            %number of patterns learned, placed in the 10^{-1}to 10^{-3}
            %decimal places, and the second indicates which pattern was the 
            %strongest attractor. If, for example, the network learned as far
            %as pattern 9 and had an attractor at pattern 8, and the failure
            %mode code for the attractor is listed in the Failure Mode
            %Dictionary as -40, then the result code reads -40.009008


            %if a pattern has the greatest proportion of action potentials
            %among its group of neurons compared to any other timestep, 
            %the cos_mat_sum should be higher
            attractor_pattern_loc = mean(attractor_idx);
            decimal_code = DualDecimalCode(state_vect, attractor_pattern_loc);
            result_code = result_identifier - decimal_code; 
        case 'context attractor'
            %the same decimal code is used here as that used for 'attractor'
            %this code requires computations on a pretty big matrix which means
            %it would take a lot of time, but luckily for us it is very rare
            %that a context attractor would ever develop.
            if parameters.toggle_record_z_train == true
                train_mat = data.z_train(:,:,trial);
            else
                train_mat = data.z_train_current_trial;
            end
            ctx_mask = sum(unique_proto,2)==0; %logical index that selects context neurons only
            context_cosmat = GetCosineComparisonMatrix(test_mat(ctx_mask,:),train_mat(ctx_mask,:));
            proto_train_cosmat = context_cosmat * GetCosineComparisonMatrix(unique_proto,train_mat)';
            pt_cosmat_sum = sum(proto_train_cosmat);
            attractor_pattern_loc = mean(find(pt_cosmat_sum == max(pt_cosmat_sum)));

            decimal_code = DualDecimalCode(state_vect, attractor_pattern_loc);
            result_code = result_identifier - decimal_code;
        case 'activity died out'
            %The activity must have died out by the end
            %the decimal identifier has two components. The first indicates the
            %number of patterns learned, placed in the 10^{-1}to 10^{-3}
            %decimal places, and the second indicates the timestep 
            %in which activity died out. 
            %if there was an end of sequence pattern that fired due to noise,
            %the first component is set to 0.
            %For example, if the result code is 30, the 
            %length of the trial was 150 timesteps and activity
            %died out at timestep 15, pattern 3, the result code is -30.00301
            %where 003 indicates pattern 3, 01 comes from 15/150
            timestep_last_firing = find(sum(test_mat,1), 1, 'last' );
            normalised_tlfiring  = double(timestep_last_firing)/double(len_trial);
            if t<len_trial
                state_vect_copy = 0;
            else
                state_vect_copy = state_vect;
            end
            decimal_code = DualDecimalCode(state_vect_copy, 100*normalised_tlfiring);
            result_code = result_identifier - decimal_code;
%         otherwise
%             warning(['exception occured at trial ',num2str(trial)])
    end
end


%{
displaying_failure_mode = true;
if displaying_failure_mode
    disp([result_description,num2str(result_code)])
    %waitforbuttonpress
end
%}



function dual_decimal_code = DualDecimalCode(state_vect, second_code)
    last_pat = find(state_vect>0,1,'last');
    if isempty(last_pat)
        %if the state_vect fed into the function was set to all 0, then set
        %the last pattern learned to being 0,i.e. no pattern learned.
        last_pat = 0;
    end
    dual_decimal_code = 1e-3 * last_pat            +...
                        1e-6 * second_code;
end
