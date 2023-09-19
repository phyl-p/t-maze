function [reordered_matrix,i_reorder, unfired_nrns] = reorder(matrix)
    if sum(sum((matrix~=0) & (matrix~=1)))>0
        error('arg to reorder must be a logical matrix. You had one job.')
    end
    n_nrns_that_fired_at_some_pt = sum(sum(matrix,2)>0);
    %n_used_nrns = sum(bool_rows);
    i_reorder = zeros(n_nrns_that_fired_at_some_pt,1);
    stop = 0;
    t=0;
    unfired_nrns = ones(size(matrix,1),1);
    while sum(i_reorder==0)>0
        t=t+1;
        start = stop+1;
        z = matrix(:,t);
        first_firing_z = z.*unfired_nrns;
        unfired_nrns = unfired_nrns .* (z==0); % doesn't change across timesteps.
        stop = stop+sum(first_firing_z); % how many nrns fired at this time step.
        i_reorder(start:stop) = find(first_firing_z);
    end
    
    
    reordered_matrix = matrix(i_reorder,:);

    %{
    %no longer used code
    reordered_matrix = zeros(size(mat_thin));
    
    i_reorder = zeros(size(mat_thin,1),1);
    t=0;
    %start = 0;
    stop = 0;
    while sum(i_reorder==0)>0
        t=t+1;
        col = mat_thin(:,t);
        bool_select = (i_reorder==0).*col;
        %row_select = find(bool_select);
        start = stop+1;
        stop = stop+sum(bool_select);
        i_reorder(bool_select>0) = start:stop;
    end
    
    reordered_matrix(i_reorder,:) = mat_thin;
    %}
    

    
    %{
    %no longer used code
    boolean_row_indices = prod(matrix==0,2)==0;
    thin_matrix = matrix(boolean_row_indices,:);
    n_rows = size(thin_matrix,1);
    
    
    nrn_order = zeros(n_rows,1);
    col_i=0;
    while prod(nrn_order) == 0
        col_i=col_i+1;
        col_vect=thin_matrix(:,col_i);
        nrn_order = nrn_order+(nrn_order==0).*(col_vect)*col_i;
    end
    %assert (no 0s in the vect nrn_order)
    
    
    row_idx = zeros(n_rows,1);
    increasing_vect = 1:n_rows;
    col_j=0;
    stop_idx = 0;
    while sum(row_idx==0) > 0
        col_j = col_j + 1;
        bool_selection = (nrn_order == col_j);
        selection = increasing_vect(bool_selection); 
        n_selected = sum(bool_selection);
        start_idx = stop_idx+1;
        stop_idx = stop_idx+n_selected;
        starttostop = start_idx:stop_idx;
        row_idx(selection) = starttostop;
    end
    reordered_matrix = thin_matrix(row_idx,:);
    %}
    %figure % take this out later
    %spy(reordered_matrix)
    
    
    
end
