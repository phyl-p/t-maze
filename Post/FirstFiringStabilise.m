
[n_nrns,len_trial,n_trials] = size(data.z_train);


%% plot Manhattan distance of first firings between each trial
figure;
ctx_idx = sum(variables.input_prototypes,2)==0;
ext_idx = ctx_idx==0;

man_dist_ctx = GetManDist(parameters,data,ctx_idx)/(sum(ctx_idx));%*len_trial);
man_dist_ext = GetManDist(parameters,data,ext_idx)/(sum(ext_idx));%*len_trial);
plot(man_dist_ctx)
hold on
plot(man_dist_ext)

%% get array of first firings for each neuron over every trial
figure;
ctx_ff_array = GetFirstFiringArray(data.z_train(ctx_idx,:,:));

brownianlike = ctx_ff_array - ctx_ff_array(:,end);

plot(std(brownianlike))




%%
function man_dist_vect = GetManDist(parameters,data,nrn_idx)
if ~exist('nrn_idx','var')
    nrn_idx = ones(parameters.number_of_neurons,1,'logical');
end
n_trials = parameters.number_of_trials;
%look for how the context neuron first firings evolve over time by
%finding the manhattan distance of the first firing vector between each trial
man_dist_vect= zeros(n_trials,1);

for trial = 2:n_trials
    
    %z_train      = data.z_train(:,:,trial);
    %z_train_prev = data.z_train(:,:,trial-1);
    z_train      = data.z_train(nrn_idx,:,trial);
    z_train_prev = data.z_train(nrn_idx,:,trial-1);
    first_firing = GetFirstFirings(z_train);
    ff_prev      = GetFirstFirings(z_train_prev);
    man_dist_vect(trial) = sum(abs(first_firing-ff_prev));
end





end


function firstfiringvect = GetFirstFirings(z_trial)
    [n_nrns,len_trial] = size(z_trial);
    
    firstfiringvect  = zeros(n_nrns,1);
    never_fired_mask = ones(n_nrns,1,'logical');
    for t = 1:len_trial
        z = z_trial(:,t);
        firstfiringvect(logical(z.*never_fired_mask)) = t;
        never_fired_mask = never_fired_mask.*(z==0);
        if sum(never_fired_mask) == 0
            break
        end
    end
    
end


function firstfiringarray = GetFirstFiringArray(z_data)
    [n_nrns,~,n_trials] = size(z_data);
    firstfiringarray = zeros(n_nrns,n_trials);
    
    for trial = 1:n_trials
        firstfiringarray(:,trial) = GetFirstFirings(z_data(:,:,trial));
    end

end









