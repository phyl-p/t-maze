function ActivityPlots(parameters,data,trial)
if exist('trial','var')
    Display(parameters,data,trial)
else
    for trial = 1:parameters.number_of_trials
        Display(parameters,data,trial)
    end
end

function Display(parameters,data,trial)
ymax = 2*parameters.desired_mean_z;
subplot(1,5,1); spy(data.z_train(:,:,trial));title(['training trial ',num2str(trial)]);
subplot(1,5,2); spy(data.z_test(:,:,trial));title('test trial');
subplot(1,5,3); plot(mean(data.z_train(:,:,trial),1))
ylim([0,ymax])
title('mean z during training')
subplot(1,5,4); plot(mean(data.z_test(:,:,trial),1))
ylim([0,ymax])
title('mean z during testing')

subplot(1,5,5); DisplayStruct(parameters)