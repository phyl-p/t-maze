function [num_unused, percent_unused ]= findNumUnused(data)
    final_trial = size(data.z_train, 3);
    matrix = data.z_train(:,:,final_trial);
    [~,i_reorder, ~] = reorder(matrix);
    size(i_reorder,1)
    num_unused = size(matrix, 1) - size(i_reorder,1);
    percent_unused = num_unused/ size(matrix, 1);
end