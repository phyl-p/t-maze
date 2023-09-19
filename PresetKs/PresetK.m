function [k0,kff,wfbinhib] = PresetK(parameters,variables,data)

    parameters.toggle_figures = true;
    parameters.toggle_record_success = false;
    parameters.toggle_record_k0 = true;
    %parameters.toggle_testing           = false;
    %parameters.toggle_record_training   = false;
    %parameters.toggle_figures           = false;
    parameters.number_of_trials         = ceil(parameters.number_of_trials/2);
    parameters.toggle_post_then_pre     = false;
    parameters.toggle_nmda              = false;
    parameters.toggle_k0_training_mod = true;
    %parameters.epsilon_k_0  = 1;
    parameters.epsilon_weight_feedback = 0;
    %parameters.epsilon_k_ff = 0.01;
    %parameters.stutter = 0; %somehow controls the duration of external input firings during test trials
    if parameters.epsilon_k_ff == 0
        disp('kff modification turned off')
    end
    [variables,~] = RunModel(parameters,variables,data);

    k0 = variables.k_0;
    kff = variables.k_ff;
    wfbinhib = variables.weights_feedback_inhib;

end
