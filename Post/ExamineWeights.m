%to use this code, the 'parameters' and 'variables' structs must be
%available in the workspace; They can be obtained by running Main.m

n_nrns = parameters.number_of_neurons;
wfanin = variables.weights_excite;
cfanin = variables.connections_fanin;


w_mat = FaninWeight2SquareMat(n_nrns,wfanin,cfanin);

%the following displays the square weight matrix as if it were specifying
%the pixels of a square black and weight image. For example, the ith row,
%jth column of the weight matrix indicates the strength of the synaptic
%connection from the ith neuron to the jth neuron; this in turn is
%represented by the whiteness of the (i,j)th pixel.
%Because the difference in 
%weight values in the square matrix itself does not result in a clear
%image, the 'brightness' multiplier was used to increase the image contrast.
brightness = 2;
imshow(w_mat*brightness)
title(['square weight matrix, viewed at x',num2str(brightness),' brightness'])


