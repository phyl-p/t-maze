function data = InitialiseData(pm)
    n_nrns = pm.number_of_neurons;
    len_trial = pm.length_of_each_trial;
    n_trials = pm.number_of_trials;
    test_len_trial = pm.test_length_of_each_trial;
    
    data = struct(...
        'z_train_last_trial',           zeros(n_nrns,len_trial,'logical')   , ...
        'z_test_last_trial',            zeros(n_nrns,len_trial,'logical')   , ...
        'mean_z_train_last_trial' ,     zeros(len_trial,1               )   , ...
        'mean_z_train_all_trials' ,     zeros(len_trial,n_trials        )   , ...
        'mean_z_test_last_trial' ,      zeros(len_trial,1               )   , ...
        'k0_history'     ,              zeros(n_trials,1                )   , ...
        'kff_history'    ,              zeros(n_trials,1                )   , ...
        'success_vect'   ,              zeros(n_trials,1                )   , ...
        'max_consecutive_successes' ,   0                                   , ...
        'final_test',                   zeros(n_nrns,len_trial,16,'logical')     ...
        );
    if pm.record_choice_points == true
        data.choice_point_firing = zeros(6, pm.number_of_trials);
    end
    if pm.toggle_record_z_train == true
        data.z_train    =               zeros(n_nrns,len_trial,n_trials,'logical');
    end
    if pm.toggle_record_z_test == true
        data.z_test     =               zeros(n_nrns,test_len_trial,n_trials,'logical');
        data.z_final_tests = zeros(n_nrns,test_len_trial,2*pm.test_reps_for_each_pattern,'logical');
    end
    if pm.toggle_record_y == true
        data.y_train    =               zeros(n_nrns,len_trial,n_trials);
        data.y_train_last_trial =       zeros(n_nrns,len_trial,1);
    end
    if pm.toggle_record_weights_exc == true
        data.w_excite_trial     =       zeros(n_nrns,pm.n_fanin,n_trials);
    end
    if pm.toggle_record_weights_inh == true
        data.w_inhib_trial      =       zeros(n_nrns,n_trials);
    end
end