addpath Post
addpath Helpers
trial = 150;
z_trial = data.z_train(:,:,150);
[n_nrns, len_trial] = size(z_trial);

[z_reordered,i_reorder] = reorder(z_trial);
figure;
while true
W_fanin = variables.weights_excite;
C_fanin = variables.connections_fanin;
W = FaninWeight2SquareMat(n_nrns,W_fanin,C_fanin);
W_reordered = W(i_reorder,i_reorder);
MatImshow(W_reordered')

title('actual')
waitforbuttonpress

C_square = zeros(n_nrns);
for nrn = 1:n_nrns
    C_square(nrn,C_fanin(nrn,:)) = 1;
end

W_tilde = GetWeightConvergence(parameters,z_trial).*C_square;
W_tilde_reordered = W_tilde(i_reorder,i_reorder);
MatImshow(W_tilde_reordered')

title('calculated')
waitforbuttonpress
end

figure;
MatImshow(W_tilde_reordered-W_reordered)




%%

%Compare calculated weights to actual weights


[n_nrns,len_trial,n_trials] = size(data.z_train);
n_fanin = size(variables.connections_fanin,2);
average_w_dist = zeros(n_trials,1);
W_tilde_data = zeros(size(data.w_excite_trial));
w_ratio = zeros(n_nrns*n_fanin,n_trials);

for trial = 1:n_trials
    z_train = data.z_train(:,:,trial);
    W=data.w_excite_trial(:,:,trial);
    W_tilde = GetWeightConvergence(parameters,z_train);
    c_fanin = variables.connections_fanin;
    W_tilde_c = zeros(size(c_fanin));
    n_nrns = size(c_fanin,1);
    for nrn = 1:n_nrns
        nrn_c_fanin = c_fanin(nrn,:);
        W_tilde_c(nrn,:)=W_tilde(nrn,nrn_c_fanin);
    end
    W_tilde_data(:,:,trial) = W_tilde_c;
    W_tilde_c(isnan(W_tilde_c)) = W(isnan(W_tilde_c));
    if floor(trial/10)==trial/10
        disp(trial)
    end
    average_w_dist(trial) = mean(abs(W(:)-W_tilde_c(:)));
    w_ratio(:,trial) = W_tilde_c(:)./W(:);
    
end

figure; plot(average_w_dist)
ylim([0,1])
%%
figure;
for trial = 1:150
    W_tilde_c=W_tilde_data(:,:,trial);
    w_ratio_trial=W_tilde_c(W_tilde_c>0)./W(W_tilde_c>0);
    h=histogram(log(w_ratio_trial),'Normalization','probability');
    ylim([0,1])
    xlim([-2,2])
    title(trial)
    xlabel(mean(log(w_ratio_trial)))
    pause(0.1)
end




