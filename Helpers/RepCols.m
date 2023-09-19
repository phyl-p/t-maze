function new_mat = RepCols(mat,scale)
%interlace columns with matrices of 0s

new_mat = InterlaceZeros(mat,scale);
len_trial = size(new_mat,2);

%scaled_mat = zeros(n_nrns,scale*len_trial);

Jordan0Block = GetJordan0Block(len_trial);
transfer_mat = zeros(len_trial);
for k = 0:scale-1
    transfer_mat = transfer_mat+Jordan0Block^k;
end
new_mat = new_mat*transfer_mat;