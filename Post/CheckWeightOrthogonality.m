
n_nrns = parameters.number_of_neurons;
wfanin = variables.weights_excite;
cfanin = variables.connections_fanin;


w_mat = FaninWeight2SquareMat(n_nrns,wfanin,cfanin);

%dendritic connections are row vectors of w_mat

inner_product_matrix = w_mat * w_mat';

magnitudes = sqrt(diag(inner_product_matrix));
mag_mat = magnitudes*magnitudes';

cosine_mat = inner_product_matrix./mag_mat;


figure;
imshow(cosine_mat)

disp('mean angle between dentritic weight vectors')
disp((sum(sum(cosine_mat))-double(n_nrns))/(double(n_nrns)^2-double(n_nrns)))
