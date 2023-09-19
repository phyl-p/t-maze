function w_mat = FaninWeight2SquareMat(n_nrns,wfanin,cfanin)
%linear transform matrix W works as follows: y = Wx
%preallocation and var retrieval
w_mat = zeros(n_nrns);
connection_mat = cfanin;


for row_index = 1:n_nrns
    ith_presynaptic_connection_indices = connection_mat(row_index,:);
    w_row = wfanin(row_index,:);
    w_row_expanded = zeros(1,n_nrns);
    w_row_expanded(ith_presynaptic_connection_indices) = w_row;
    
    w_mat(row_index,:) = w_row_expanded;
    
    
    
end

