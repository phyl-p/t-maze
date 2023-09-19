function forward_over_backwards_ratio = TrialWeightHeatmap(vars, params, data, trial)
    externals = params.ext_activation;
    shift = params.shift;
    num_start_blocks = params.num_start_block;
    num_shared_blocks = params.num_shared_block;
    num_end_blocks = params.num_end_block;
    total_external_nrns = shift*(num_start_blocks*2+num_shared_blocks+num_end_blocks*2);
    
    if num_start_blocks>0
        total_external_nrns = total_external_nrns + (externals-shift);
    end
    if num_shared_blocks > 0
        total_external_nrns = total_external_nrns + (externals-shift);
    end
    if num_end_blocks > 0
        total_external_nrns = total_external_nrns + (externals-shift);
    end
    
    if params.toggle_pre_then_post == true && params.toggle_post_then_pre == false
        rule = "Single Quadrant Rule ";
    else
        rule = "Dual Quadrant Rule ";
    end
%     disp(total_external_nrns)
    
    %reorder
    z_train = data.z_train(:,:,trial);
    [z_train_context_reordered,i_reorder,~] = reorder(z_train_context);
    
    if trial > size(data.w_excite_trial, 3)
        error("Trial number exceeds total number of trials in the simulation.")
    else 
        n_nrns = params.number_of_neurons;
        wfanin = data.w_excite_trial(:,:, trial);
        cfanin = vars.connections_fanin;

        w_mat = FaninWeight2SquareMat(n_nrns,wfanin,cfanin);
%         disp(w_mat(1:10, 1:10))
        figure;
        
        %method 1: figure
        
%        subplot(2, 6, 1)
%        histogram(w_mat(:))
        
%        subplot(2, 6, [2 3 8 9])
%         w_mat(w_mat < 0.2) = 0;
        
        %NO-REODRING
        w_mat_compressed = blockproc(w_mat, [30 30], @(x) mean(x.data(x.data > 0), 'all'));

%         h = heatmap(w_mat(1:nrn_of_interest,1:nrn_of_interest),'Colormap', parula)

        h = heatmap(w_mat_compressed);
        h.GridVisible = 'off';
        title({"Weight Heatmap of " rule "at trial " num2str(trial)})
        
        %EVERYTHING REORDERED
        z_train = data.z_train(:,:,trial_num);
        [reordered_matrix,i_reorder] = reorder(w_mat);
        w_mat_compressed_reordered = blockproc(reordered_matrix, [30 30], @(x) mean(x.data(x.data > 0), 'all'));
        figure;
        h2 = heatmap(w_mat_compressed_reordered);
        h2.GridVisible = 'off';
        title({"Weight Heatmap of " rule "at trial " num2str(trial)})
        
%         %ONLY REORDER CONTEXT NEURONS
%         figure;
%         w_mat_context_reordered(total_external_nrns:end, total_external_nrns:end) = w_mat(i_reorder, :); 
%         
%         h2 = heatmap(w_mat_context_reordered);
%         h2.GridVisible = 'off';
%         title({"Weight Heatmap of " rule "at trial " num2str(trial)})
        
        %calculate ratio
        forward_over_backwards_ratio = zeros(1, total_external_nrns/30-1);
        for ext_nrn = 2:total_external_nrns/30
            if w_mat_compressed(ext_nrn-1, ext_nrn) >0
                forward_over_backwards_ratio(1, ext_nrn) = w_mat_compressed(ext_nrn+1, ext_nrn)/w_mat_compressed(ext_nrn-1, ext_nrn);
            else
                forward_over_backwards_ratio(1, ext_nrn) = 1;
            end
        end
    end
end