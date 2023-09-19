function scaled_mat = InterlaceZeros(mat,scale)
%interlace columns with matrices of 0s

[n_nrns,len_trial] = size(mat);

scaled_mat = zeros(n_nrns,scale*len_trial);

for t = 1:len_trial
    scaled_mat(:,1+(t-1)*scale) = mat(:,t);
end
