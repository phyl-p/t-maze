function [right_firing, wrong_firing, right_goal_count, wrong_goal_count, choice_diff, goal_diff, r_start, r_end, w_start, w_end, t_start, t_end] = DetermineTMazeSuccess(trial_number, params, current_test, vars, final_testing)
if final_testing == 1
    if trial_number <=params.test_reps_for_each_pattern
        positions_r = vars.positions_1;
        positions_w = vars.positions_2;
    else
        positions_r = vars.positions_2;
        positions_w = vars.positions_1;
    end
end

if (params.toggle_I_Maze == true && final_testing == 0)
    if vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 1
        positions_r = vars.positions_1;
        positions_w = vars.positions_2;
    elseif vars.input_pattern(1, trial_number) == 1 && vars.input_attractor(1, trial_number) == 2
        positions_r = vars.positions_2;
        positions_w = vars.positions_1;
    else
        disp("ERROR: incorrect input pattern generated. Must be either 1 or 2. Check genIMazePatten.")
    end
end 

start = params.stutter*params.num_shared_block;
choice_point_duration = params.determine_choice_point_duration;
r_choicePointMask = zeros(params.number_of_neurons, params.length_of_each_trial);
w_choicePointMask = zeros(params.number_of_neurons, params.length_of_each_trial);

cp_blocks = params.choice_point_blocks;
stutter = params.stutter;
shift = params.shift;
ext = params.ext_activation;
block_start = 1 + params.num_shared_block;
block_end = cp_blocks + params.num_shared_block;
start_nrn = 2*(block_start-1)+1;
final_nrn = 2*(block_end-1) + 2;
r_choicePointMask(positions_r(start_nrn):positions_r(final_nrn), start:start+choice_point_duration-1) = ones((cp_blocks-1)*shift + ext, choice_point_duration);
w_choicePointMask(positions_w(start_nrn):positions_w(final_nrn), start:start+choice_point_duration-1) = ones((cp_blocks-1)*shift + ext, choice_point_duration);

r_start = positions_r(start_nrn);
w_start = positions_w(start_nrn);
t_start = start;
r_end = positions_r(final_nrn);
w_end = positions_w(final_nrn);
t_end = start+choice_point_duration-1;

    filtered_right_region = current_test.*r_choicePointMask;
    %count wrong choice number
    filtered_wrong_region = current_test.*w_choicePointMask;
    right_firing = sum(filtered_right_region, 'all');
    wrong_firing = sum(filtered_wrong_region, 'all');
    choice_diff = right_firing - wrong_firing;
    
%    goal_diff = right_goal_count- wrong_goal_count;
    right_goal_count = 0;
    wrong_goal_count = 0;
    goal_diff = 0;
end