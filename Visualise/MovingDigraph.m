n_nrns = parameters.number_of_neurons;
len_trial = parameters.length_of_each_trial;
n_ext_nrns = sum(sum(variables.input_prototypes,2)>1);

wmat = FaninWeight2SquareMat( ...
    n_nrns, ...
    variables.weights_excite, ...
    variables.connections_fanin ...
    );

sorted_weights = sort(variables.weights_excite(:),'descend');
n_synapses = length(sorted_weights(:));
threshold = sorted_weights(0.05*n_synapses);
disp(threshold)
G = digraph(wmat>threshold);


trial = 19;
subplot(1,4,2:4)
h=G.plot;
h.layout('force');

for timestep = 1:len_trial
    z = data.z_test(:,timestep,trial);
    subplot(1,4,1)
    spy(repmat(z,1,100),'r')
    
    subplot(1,4,2:4)
    h.MarkerSize = 0.5;
    h.NodeColor = 'b';
    h.EdgeAlpha = 0.1;
    highlight(h,1:n_ext_nrns,'NodeColor','g')
    highlight(h,z,'NodeColor','r','MarkerSize',2,'EdgeColor','r')
    xlim([0.5,15.5])
    ylim([1,16])
    title(['timestep ',num2str(timestep)])
    pause(0.01)
end


