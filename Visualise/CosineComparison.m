function varargout = CosineComparison(variables,data,trial)
%examples: 
%mat = CosineComparison(variables,data,20)
%   This returns a cosine comparison matrix at timestep 20
%CosineComparison(variables,data,10)
%   This returns a display of the CosineComparison at timestep 10

%if number of output arguments (i.e. nargout) is 0, then creates a cosine
%comparison diagram.
%if nargout is 1, returns the cosine matrix
%haven't written anything for other cases of nargout
prototypes = variables.input_prototypes;
%number of neurons that are at some point activated by an external input
%which is also the number of nrns that the network needs to represent the
%recreated version of the stimulus
ext_nrns   = sum(prototypes,2)>0;
test_mat   = data.z_test(ext_nrns,:,trial);
prototypes = variables.input_prototypes(ext_nrns,:);
len_trial  = size(prototypes,2);

cosine_matrix = GetCosineComparisonMatrix(prototypes,test_mat);


if nargout == 1
    varargout{1} = cosine_matrix;
else
    PlotCosineComparison(cosine_matrix,len_trial,trial)
end




