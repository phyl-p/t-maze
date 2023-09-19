param = parameters;
vars =variables;
%seed = 164
%z_train_new = SameWeightsTrial(param,vars,data,seed);
vars.k_0 = 0.19;
test_trial = TestNetwork(param,vars,data);

%{
%block commented out is used to see if different randomisations result in
%different w_tilde s for the same network
trial = 140
param = parameters;
vars =variables;
vars.weights_excite = data.w_excite_trial(:,:,trial);
vars.k_0=data.k0_history(trial);

w_tilde_vect = W_tilde(:);


n_seeds=10;
mean_vect = zeros(n_seeds,1);
var_vect  = zeros(n_seeds,1);
figure;
for seed = 1:n_seeds
    z_train_new = SameWeightsTrial(param,vars,data,seed);
    %get w_convergence from new randomisation
    w_conv_rand = GetWeightConvergence(parameters, z_train_new);
    w_cr_vect = w_conv_rand(:);
    comparable_synapses = ~isnan(w_tilde_vect) & ~isnan(w_cr_vect) & w_tilde_vect.*w_cr_vect>0;
    ratio_vect = w_cr_vect(comparable_synapses)./w_tilde_vect(comparable_synapses);
    histogram(ratio_vect,'Normalization','probability')
    waitforbuttonpress
    mean_vect(seed) = mean(log(ratio_vect));
    var_vect(seed) = var(log(ratio_vect));
end
%}


function z_train_new = SameWeightsTrial(param,vars,data,seed)
len_trial   = param.length_of_each_trial;
n_nrns      = param.number_of_neurons;
rng(seed);

z_train_new = zeros(n_nrns,len_trial);

[vars,data] = InitialiseTrial(param,vars,data);

for timestep = 1:len_trial

    %update variables for the current timestep
    vars = UpdateSpike(vars,timestep);
    z_train_new(:,timestep) = vars.z;

end

%vars = UpdateK0(param,vars);

%Record variables of interest into the 'data' struct.






end


function [vars,data] = InitialiseTrial(param,vars,data)
%1. introduces noise to the prototype input sequence;
%2. sets z to a random vector with a mean z that is roughly equal to
%the desired average spike probability (i.e. equal to vars.desired_mean_z). 
    %The entries of the random vector are chosen by
    %generating a number on the uniform distribution between 0 and 1,
    %then checking whether that number is less than the 
    %desired_mean_z, which is also a number between 0 and 1.
    %This event has a probability equal to the desired mean z
%3. reset the decay variables back to zero
    %Note: there are scenarios in which the network might not stop at the
    %last pattern, going back to the first and cycling through the sequence
    %again during a test run. This happens when the decay variables or 
    %the z_prev variable are not reset to zero at the beginning of each
    %training trial, in which case the network will believe that the first
    %pattern of a sequence comes immediately after the last pattern of the
    %preceding trial and create an association between the two.
vars.z_prev     = zeros(size(vars.z_prev));
vars.boxcar_exc = zeros(size(vars.boxcar_exc));
vars.boxcar_inh = zeros(size(vars.boxcar_inh));
vars.input_current_trial = genNoise(vars.input_prototypes,param.on_noise,param.off_noise);
vars.z=rand(param.number_of_neurons,1)<param.desired_mean_z;
vars.z_nmda_decay = zeros(param.number_of_neurons,1);
vars.z_spiketiming_decay = zeros(param.number_of_neurons,1);

%use if testing the network's ability to control its activity;
%this turns off external inputs and lets the network run on its own.
if param.toggle_external_input == 0
    vars.input_current_trial=zeros(1000,25);
end
end



function vars = UpdateSpike(vars,timestep)
%if error indicates 'index in position 2 is invalid', check if t is -1.
%if it is, then there is a problem with the function triggers. Refer to
%ControlFxnTriggerIdx


%% Get Inputs:
%assign variables from the cv struct into variables accessed directly
%by this function

x               = vars.input_current_trial(:,timestep);
z               = vars.z;
connection_mat  = vars.connections_fanin;
k_0             = vars.k_0;
k_fb            = vars.k_fb;
k_ff            = vars.k_ff;
w_fbinhib       = vars.weights_feedback_inhib;
w_excite        = vars.weights_excite;
boxcar_exc      = vars.boxcar_exc;
boxcar_inh      = vars.boxcar_inh;
boxcar_pmf      = vars.boxcar_pmf;
refractory  = vars.boxcar_refractory_period;


%% update Spike at timestep t

%as the output vector z hasn't been updated yet for the current timestep, 
%it still corresponds to the activation of the previous timestep.
z_prev = z;


%recall that connection_mat is a fanin connection matrix. Therefore,
%every ith row vector specifies the indices of the presynaptic neurons 
%that ennervate the ith neuron. 
%z(connection_mat) is a matrix the rearranges the output z into a matrix
%corresponding to connection_mat, such that every entry on the ith row 
%indicates which presynaptic neurons that ennervate the ith 
%neuron have fired.
%
%the excitatory weights (w_excite) are organised according to the same 
%fanin connection scheme, so an element by element multiplication '.*'
%of the rearranged output matrix and weights as done below should indicate
%(on every ith row) the individual presynaptic activations that take place
%before being summed up postsynaptically by the ith neuron.

Wz_exc = sum(    z(connection_mat) .* w_excite  ,   2);





%{
%push each boxcar by 1 column to the right and replace the first column 
%of the boxcar matrix with Wz_exc
boxcar_exc = PushBoxcar(boxcar_exc, Wz_exc); %matrix is in M_{n_nrns\times n_boxcars}
%sum boxcar terms according to the distribution specified in boxcar_pmf
excite = boxcar_exc*boxcar_pmf'; %boxcar_pmf is a vector in \mathbb{R}^n_boxcars
%}

%speeded up the code
[excite,boxcar_exc] = BoxcarStep(Wz_exc, boxcar_exc, boxcar_pmf, timestep);
%{
%function [excite,boxcar_exc] = BoxcarStep(Wz_exc, boxcar_exc, boxcar_pmf, timestep)
t_modulo = mod(timestep,numel(boxcar_pmf));
boxcar_exc(:,t_modulo) = Wz_exc;
excite = boxcar_exc * boxcar_pmf([t_modulo:end,1:t_modulo-1])';
%}




%the same boxcar algorithm is used to calculate inhibition
Wz_inh = sum(    w_fbinhib         .* z_prev);
%boxcar_inh = PushBoxcar(boxcar_inh, Wz_inh);
%fb_inh=boxcar_inh*boxcar_pmf';
[inhib_fb,boxcar_inh] = BoxcarStep(Wz_inh, boxcar_inh, boxcar_pmf, timestep);







%The following inhibition equation is based on Dave's rule. 
%k_0 ensures that the mean_z activity of the network equals the desired
%   mean_z specified. This is done at the end of each trial by 
%   increasing k_0, and therefore inhibition, whenever there is too much 
%   activity, and decreasing it when there is too little.
%w_fbinhib, which stands for feedback inhibitory weights, corresponds to 
%   the inhibition based on the activity of individual neurons;
%k_ff*sum(x), just as k_0, controls overall activity,
%   but is based on external inputs and is therefore set to 0 when testing
%   (as the external stimulus is turned on only when training)
inhib = k_0   +    k_fb*(inhib_fb)   +   k_ff*sum(x);

%the y postsynaptic activation vector is calculated based
%on the excitation and inhibition vectors
y = excite./(excite+inhib);

%each neuron spikes if its activation is greater than the spike_threshold
%(which is arbitrarily set to 0.5 in this model)
z = y>vars.spike_threshold | x == 1;


if refractory > 0 ...    %if refractory period is nonzero
        && length(boxcar_pmf)>refractory       %and is well defined
    boxcar_exc = BoxcarRefractory(z,boxcar_exc,refractory,inhib,boxcar_pmf,timestep);
        %subtracts the appropriate amount from the parts of the boxcar
        %corresponding to the refractory value, thereby preventing
        %the neuron from firing during the refractory period
end

%% Output
%assign output to the struct
vars.boxcar_exc = boxcar_exc;
vars.boxcar_inh = boxcar_inh;
vars.z_prev = PushBoxcar(vars.z_prev,z_prev); %if vars.z_prev is a matrix of previous values, insert most recent z_prev in left column and push all other columns to the right (deleting the rightmost column)
vars.z = z;
end




function data = TestNetwork(params,vars,data,trial_number)
%make sure cv is not an output variable of the function
[vars,~] = InitialiseTrial(params,vars,000); %the 000 is just a stub


on_noise = double(params.on_noise);
first_stimulus = vars.input_current_trial(:,1:params.stutter);
vars.input_current_trial = zeros(size(vars.input_current_trial),'logical');
vars.input_current_trial(:,1:params.stutter) = first_stimulus;

len_trial = params.length_of_each_trial;
n_nrns    = params.number_of_neurons;
current_test = zeros(n_nrns,len_trial,'logical');

for timestep = 1:len_trial
    vars = UpdateSpike(vars,timestep);
    vars.z = AddNoise(vars.z,on_noise);
    current_test(:,timestep) = vars.z;
end

subplot(1,2,2)
%spy(current_test)
if params.toggle_figures ==  true
    SpySelected(current_test,params.nrn_viewing_range)
end


if exist('trial_number','var')
    title({['test using weights from trial ',num2str(trial_number)],...
            ['mean',num2str(mean(mean(current_test)))]})
    data.z_test_current_trial = current_test;
    if params.toggle_record_z_test==true
        data.z_test(:,:,trial_number) = current_test;
    end
else
    data = current_test;
end
pause(0.00000000000001)
end
