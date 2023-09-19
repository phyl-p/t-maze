function w_convergence = GetWeightConvergence(parameters, input_sequence)
%descended from 2nrn model; modified input arguments

%Check convergence
addpath Helpers

lambda = parameters.epsilon_weight_nmda/parameters.epsilon_weight_spiketiming * parameters.toggle_spiketiming;
decay_z_bar = parameters.decay_nmda;
decay_z_tilde = parameters.decay_spiketiming;

%figure
%spy(variables.input_prototypes)
%n_trials  = parameters.number_of_trials;
[n_nrns, len_trial] = size(input_sequence);
z_prev = zeros(n_nrns,1);

z_bar = zeros(n_nrns,1);  %z_bar is a col vect
z_bar_history = zeros(n_nrns,len_trial); %col vects, columns indexed by time

z_tilde = zeros(size(z_bar));
z_tilde_history = zeros(size(z_bar_history));


for t = 1:len_trial
    z = input_sequence(:,t);
    
    
    z_bar = ZDecay(z_bar,decay_z_bar,z_prev);
    z_bar_history(:,t) = z_bar;
    
    
    z_tilde = ZDecay(z_tilde,decay_z_tilde,z);
    z_tilde_history(:,t) = z_tilde;
    
    
    z_prev = z;
end

%figure; plot(z_tilde_history(2,:))

%figure; plot(z_bar_history(2,:))



%E[\bar{z_i} | z_j=1]
E_zibar_zj_mat = input_sequence * z_bar_history';
E_zjtilde_zi_mat = z_tilde_history * input_sequence' ;

w_convergence = E_zibar_zj_mat ./ (sum(input_sequence,2)+lambda*E_zjtilde_zi_mat);













