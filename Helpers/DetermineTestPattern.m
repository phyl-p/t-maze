function patterns = DetermineTestPattern(vars, params, current_test)
positions_1 = vars.positions_1;
positions_2 = vars.positions_2;

part2 = 2*(params.num_shared_block-1) + 1;
combined_pos = [positions_1 positions_2(part2:end)];
mask = zeros(params.number_of_neurons);
patterns = zeros(1, params.length_of_each_trial);
    for t = params.stutter*params.test_num_stimuli+1: params.length_of_each_trial
        max_total = 0;
        pattern = 0;
        for i = 1:2*params.num_end_block + params.num_shared_block
            mask_t = mask;
            start_nrn = combined_pos(2*(i-1)+1);
            final_nrn = combined_pos(2*(i-1)+2);
%             disp(start_nrn)
%             disp(final_nrn)
            mask_t(start_nrn:final_nrn) = ones(1, final_nrn - start_nrn+1);
            cur_total = sum(current_test(:, t).*mask_t, 'all');
%             disp(cur_total)
            if max_total < cur_total
                pattern = i;
                max_total = cur_total;
            end
        end  
        patterns(1,t) = pattern;
    end
   %patterns(diff(patterns)==0) = [];
   patterns(patterns == 0) = [];
end