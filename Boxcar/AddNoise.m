function noisy_mat = AddNoise(raw_mat,on_noise_arg,off_noise_arg)
    %assume that column vectors represent network node state (e.g. vector of
    %neuron action potentials), all entries are boolean, and that 
    %noise is being added to the column vectors
    [n_nodes, n_timesteps] = size(raw_mat);
    on_noise  = NoiseAsProbability(n_nodes,on_noise_arg);
    off_noise = NoiseAsProbability(n_nodes,off_noise_arg);

    % on_noise_generator = rand(n_nodes,n_timesteps) < on_noise;
    % 
    % noisy_mat = raw_mat + on_noise_generator > 0;
    
end




function noise_probability = NoiseAsProbability(n_nodes, noise_arg)
    if noise_arg<1
        noise_probability = noise_arg;
    elseif noise_arg < n_nodes
        noise_probability = noise_arg/n_nodes;
    else
        error('noise is too high, or is not properly formatted')
    end
end