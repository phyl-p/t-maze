function cosine_matrix = GetCosineComparisonMatrix(prototypes,test_mat)
toggle_testtime_as_yaxis = false;
prototypes = double(prototypes);
test_mat   = double(test_mat);
%inner product of columns of each mat
innerproduct_mat =  prototypes' * test_mat;
%calculate magnitudes
%suppose we represent mat in terms of its column vects, i.e.
%mat = [v_1,v_2,...,v_N] then dot(mat,mat) should return
%[  ||v_1||,    ||v_2||,    ...,    ||v_N||  ]
prototype_magnitudes = sqrt(dot(prototypes,prototypes))';
test_magnitudes      = sqrt(dot(test_mat,test_mat))';
%cosine comparisons on vectors of magitude 0 are undefined; this will be
%marked as 0 but to prevent division by 0, the magnitudes are set to 1
prototype_magnitudes = (prototype_magnitudes==0)+prototype_magnitudes;
test_magnitudes = (test_magnitudes == 0) + test_magnitudes;

products_of_magnitudes = prototype_magnitudes * test_magnitudes';
cosine_matrix = innerproduct_mat./products_of_magnitudes;

if toggle_testtime_as_yaxis
    cosine_matrix = cosine_matrix';
end