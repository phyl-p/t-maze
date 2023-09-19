function is_noisy = OutputIsNoisy(filter)
n_pat = size(filter,1);
pattern_spike_variance = zeros(n_pat,1);
spiketimes = zeros(sum(sum(filter)),1);

st_idx_acc = 0;
for pattern_row = 1:n_pat
    find_spike_timestep = find(filter(pattern_row,:));
    pattern_spike_variance(pattern_row) = var(find_spike_timestep);
    n_spikes = sum(filter(pattern_row,:));
    spiketimes(st_idx_acc+1:st_idx_acc+n_spikes) = find_spike_timestep;
    st_idx_acc = st_idx_acc + n_spikes;
end

pattern_noise_ratio = nanmean(pattern_spike_variance)/var(spiketimes);
disp(pattern_noise_ratio)
is_noisy = pattern_noise_ratio>1;