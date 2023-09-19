function ret = WriteToExcel(n_simulations)
% Katie Winn 
% helper for data collection for trace
% At the start of InitiliaseParameters.m add:
 global trace_seed_1;
 global trace_seed_2;

% If you want to automate the 1st vs 1st and 3rd quadrant rules add:
% global pre_post;
% global post_pre;
% global memory_fraction;

% adjust lines: 
%   'network_construction_seed',    trace_seed_1,... %randi(100,1),... 
%   'z_0_seed',                     trace_seed_2,... %randi(100,1),... 
global trace_duration;

    tStart = tic;

    set_seeds = true; % true: uses seeds from seed_mat (for comparing data)
                      % false: don't use seed_mat; generate random seeds
               
    seed_mat  = [
         24, 65;
         25, 25;
         73, 61;
         2, 14;
         62, 62;
         74, 70;
         56, 60;
         100,38;
         86, 92;
         2, 73;
        ];
    
        
    x = strings(140, n_simulations); %(number of training/testing trials, 
                                     %   number of simulations)
    success_learning_counter = 0;
    
    % pre post vs post pre
    %global pre_post;
    %global post_pre;
    % rates
    %global memory_fraction;
    
    %for n = 1:4
        for i = 1:n_simulations

            % seeds
            if set_seeds
                global trace_seed_1;
                global trace_seed_2;

                trace_seed_1 = seed_mat(i, 1);
                trace_seed_2 = seed_mat(i, 2);
            end
            
%             if n == 1 || n == 2
%                 pre_post = true;
%                 post_pre = false;
%             elseif n == 3 || n == 4
%                 pre_post = true;
%                 post_pre = true;       
%             end
%             
%             if n == 1 || n == 3
%                 memory_fraction = 0.74;        
%             elseif n == 2 || n == 4
%                 memory_fraction = 0.82;    
%             end
           
            [data,~,params] = MainSingleTask;
            res = (data.list_of_results);
            x(:,i) = res;
            if data.successful_learning
               success_learning_counter = success_learning_counter + 1;
            end

            pre_then_post = params.toggle_pre_then_post;
            post_then_pre = params.toggle_post_then_pre;
            fractional_mem_pre = params.fractional_mem_pre;
            trace_interval_in_ms = trace_duration * 20;
        end
    file_name = 'trace_sim.xls';
    writematrix(x, file_name, 'Sheet',1);
    
    if pre_then_post == true && post_then_pre == false
        disp('1st quadrant');
    elseif pre_then_post && post_then_pre
        disp('1st and 3rd quadrant');
    end
    disp(['trace interval (ms): ', num2str(trace_interval_in_ms)]); 
    disp(['memory fraction: ', num2str(fractional_mem_pre)]);
    
    %end
    
    % display information at the end 
    tTotal = toc(tStart);
    disp(['Total elapsed time is ', num2str(tTotal/60), ' minutes.'])
 
    ret = ['See file ' file_name ' for results.']; %, newline, ...
        %'Number of successful learnings in ' num2str(n_simulations) ' simulations: ' num2str(success_learning_counter)];
end
