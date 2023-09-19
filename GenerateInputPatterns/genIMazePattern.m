function [input_start_across_trials, input_attractor_pattern, params] = genIMazePattern(I_Maze_toggle, paradigm_left, paradigm_right, extra_training_pattern_2, params)
    % GENPATTERN generates the sequence of two scenarios with which the network
    % is exposed to and there fore trained on. The two types of training
    % paradigm are staged and concurrent. 

    % PARAMETERS: paradigm is a list that specifies how many times each path
    % is trained on before switching to the other pattern. Each entry in the
    % list corresponds to how many times each path is trained.  
    input_start_across_trials = [];
    input_attractor_pattern = [];
    if I_Maze_toggle %training in I-Maze
        right_branch_toggle = 1;
        attractor_toggle = 2;
    else % training on T-Maze
        right_branch_toggle = 0;
        attractor_toggle = 1;
    end   
    len_paradigm = max(length(paradigm_left), length(paradigm_right));
    for i = 1:len_paradigm
        if i <= length(paradigm_left)
            input_start_across_trials = [input_start_across_trials ones(1, paradigm_left(i))];
            input_attractor_pattern = [input_attractor_pattern ones(1, paradigm_left(i))];
        end
        if i <= length(paradigm_right)
            input_start_across_trials = [input_start_across_trials ones(1, paradigm_right(i))];
            input_attractor_pattern = [input_attractor_pattern 2*ones(1, paradigm_right(i))];
        end
        %input_start_across_trials = [input_start_across_trials ones(1, *paradigm(i)+extra_training_pattern_2) 2*ones(1, right_branch_toggle*paradigm(i))]; % starting branch (vertical part)
        %input_attractor_pattern = [input_attractor_pattern ones(1, paradigm(i)) 2*ones(1, paradigm(i)+extra_training_pattern_2) ones(1, right_branch_toggle*paradigm(i)) 2*ones(1, right_branch_toggle*paradigm(i))]; % end goal branch
    end

     disp(["input_start_across_trials", input_start_across_trials])
     disp(["input_attractor_pattern", input_attractor_pattern])

    params.number_of_trials = size(input_start_across_trials,2); %reset number of trials in params struct, since we changed it. 
end