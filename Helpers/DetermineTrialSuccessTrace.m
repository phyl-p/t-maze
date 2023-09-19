% Katie Winn
% Purpose: DetermineTrialSuccessTrace is a success detector for the trace
% conditioning sequence.

function result = DetermineTrialSuccessTrace(parameters,data,trial)
global cs_nrns;
global us_nrns;
global total_success_neurons;
global distinct_success_neurons;
global required_number_of_firings_per_neuron;
global success_timestep_1;
global success_timestep_2;
global cs_duration;
global trace_duration;
      
    % current trial test matrix
    test_mat = data.z_test(:,:,trial);
    
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
    
    result = 'failure to predict';     
    
    % prediction too soon moving window variables
    success_window_length = success_timestep_2 - success_timestep_1 + 1; %8 timesteps
    start_of_pred_too_soon_window = cs_duration+1; %timestep 6    
    end_of_pred_too_soon_window = cs_duration + success_window_length; %5 + 8 = 13 (timestep 13)
    
    % moving window for prediction too soon
    while (success_timestep_1 > end_of_pred_too_soon_window) 
        predict_too_soon_mat = test_mat(cs_nrns+1 : cs_nrns+us_nrns, start_of_pred_too_soon_window:end_of_pred_too_soon_window);
        sum_of_rows_soon = sum(predict_too_soon_mat,2);
        distinct_rows_soon = sum(sum_of_rows_soon >= required_number_of_firings_per_neuron);  
        
        % return if prediction too soon criteria is met
        if distinct_rows_soon >= distinct_success_neurons %&&  sum(predict_too_soon_mat, 'all') >= total_success_neurons
            result = 'failure - prediction too soon'; 
            return
        end 
        
        % increment start and end timesteps
        start_of_pred_too_soon_window = start_of_pred_too_soon_window + 1;
        end_of_pred_too_soon_window = end_of_pred_too_soon_window + 1;
    end
       
    % window for successful prediction
    success_matrix = test_mat(cs_nrns+1:cs_nrns+us_nrns,success_timestep_1:success_timestep_2);   
    sum_of_rows = sum(success_matrix,2);
    number_distinct_rows = sum(sum_of_rows >= required_number_of_firings_per_neuron);
    
    % window for prediction too late
    predict_too_late_mat = test_mat(cs_nrns+1:cs_nrns+us_nrns, success_timestep_2+1:cs_duration+trace_duration);
    sum_of_rows_late = sum(predict_too_late_mat,2);
    distinct_rows_late = sum(sum_of_rows_late >= required_number_of_firings_per_neuron);
    
       
    % [option 1] SUCCESS - DISTINCT NEURONS
    if number_distinct_rows >= distinct_success_neurons
        result = 'success';
        return  
        
%    % [option 2] SUCCESS - TOTAL NEURONS    
%     if sum(success_matrix, 'all') >= total_success_neurons && number_distinct_rows < distinct_success_neurons
%         result = 'success';
%         return
        
%     % [option 3] SUCCESS - DISTINCT NEURONS & TOTAL NEURONS
%     if number_distinct_rows >= distinct_success_neurons && sum(success_matrix, 'all') >= total_success_neurons
%         result = 'success';
%         return
 
    
    % FAILURE - PREDICT TOO LATE   
    elseif distinct_rows_late >= distinct_success_neurons  % failure too late based on 'distinct' criterion
        result = 'failure - prediction too late'; 
        return
    end
    
end