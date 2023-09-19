function PlotTestPatterns(vars, params, patterns, trial_number,final_testing)
    if (params.toggle_I_Maze == true && final_testing == 0)
        if vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 1
            cp_start_r = params.num_shared_block+1;
            cp_start_w = params.num_shared_block + params.num_end_block + 1;
            correct_goal = params.num_shared_block + params.num_end_block;
            wrong_goal = params.num_shared_block + params.num_end_block*2;
        elseif vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 2
            cp_start_r = params.num_shared_block + params.num_end_block + 1;
            cp_start_w = params.num_shared_block+1;
            correct_goal = params.num_shared_block + params.num_end_block*2; 
            wrong_goal = params.num_shared_block + params.num_end_block;
        else
            disp("ERROR: incorrect input pattern generated. Must be either 1 or 2. Check genIMazePatten.")
        end
    end 

    
    t = params.stutter*params.num_shared_block+1:params.length_of_each_trial;
    disp(t)
    disp(length(t))
    disp(length(patterns))
    figure
    plot(t,patterns, ":o","LineWidth", 3)

    yline(cp_start_r ,  '--',...
        'correct choice point start',...
        'FontSize', 20, 'LabelVerticalAlignment', 'bottom',...
        "LineWidth", 2,...
        "Color", "#0d6e25", 'fontweight','bold');
    yline(cp_start_w,'--','wrong choice point start','FontSize',  20, 'LabelVerticalAlignment', 'top',"LineWidth", 2,"Color", "#bd1708",'fontweight','bold');
    yline(correct_goal,'--','correct goal','FontSize', 20, 'LabelVerticalAlignment', 'bottom',"LineWidth", 2, "Color", "#0d6e25",'fontweight','bold');
    yline(wrong_goal,'--','wrong goal','FontSize', 20, 'LabelVerticalAlignment', 'top',"LineWidth", 2, "Color", "#bd1708", 'fontweight','bold');        
    title(["Network Recalled Position over Timestep Starting at the End of Shared Branch", newline + "Trial " + num2str(trial_number)],'FontSize', 25)
    
    ax = gca;
    ax.FontSize = 20;
    
    xlabel('Time Step Starting After the End of Shared Branch');
    ylabel('Imagined Position in the T-Maze');
end