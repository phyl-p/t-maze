function FigureZHistory(handles)

disp_req = handles.display_request;


%retrieve the history matrices for the trial that we are interested in


n_plots = length(disp_req);
if sum(strcmp('CosComp',disp_req))>0
    n_plots = n_plots+1;
end


plot_idx = 0;
while plot_idx <n_plots
    plot_idx = plot_idx + 1;
    fxnh = str2func(disp_req{plot_idx});
    plot_idx = fxnh(handles,n_plots,plot_idx);
    
end



function plot_idx = Train(handles,n_plots,plot_idx)
plot_idx = SetSubPlot(n_plots,plot_idx,1);
nrn_min_view = handles.nrn_min_view;
nrn_max_view = handles.nrn_max_view;
viewingrange_arguments = {nrn_min_view,nrn_max_view};
trial = handles.trial_view;
data = handles.data;

z_training = data.z_history(:,:,trial);
SpyWrapper(z_training,viewingrange_arguments)
title(['Trial ',num2str(trial),', Training'])


function plot_idx = Test(handles,n_plots,plot_idx)
plot_idx = SetSubPlot(n_plots,plot_idx,1);

nrn_min_view = handles.nrn_min_view;
nrn_max_view = handles.nrn_max_view;
viewingrange_arguments = {nrn_min_view,nrn_max_view};
trial = handles.trial_view;
data = handles.data;
z_test     = data.z_test(:,:,trial);
SpyWrapper(z_test,viewingrange_arguments)
title(['Trial ',num2str(trial),', Training'])


function plot_idx = CosComp(handles,n_plots,plot_idx)
variables = handles.variables;
data = handles.data;
trial = handles.trial_view;

plot_idx = SetSubPlot(n_plots,plot_idx,2);
CosineComparison(variables,data,trial)
title(['Cos(inputs,test)(trial= ',num2str(trial),')'])


function plot_idx = K0History(handles,n_plots,plot_idx)
plot_idx = SetSubPlot(n_plots,plot_idx,1);

data = handles.data;
k0_history = data.k0_history;
plot(k0_history)
title('k0 between successive trials')


function plot_idx = MeanZ(handles,n_plots,plot_idx)
plot_idx = SetSubPlot(n_plots,plot_idx,1);
trial = handles.trial_view;
data = handles.data;
mean_z_history = data.mean_z_history;
plot(mean_z_history(:,trial))
ylim([0,max(max(mean_z_history))])
title(['activity (as mean z) in trial ',num2str(trial)])



function plot_idx = SetSubPlot(n_plots,plot_idx,size)
subplot(1,n_plots,plot_idx:plot_idx+size-1)
plot_idx = plot_idx+size-1;







function SpyWrapper(matrix,viewingrange_arguments)
if isempty(viewingrange_arguments)
    
    spy(matrix)
else
    SpySelected(matrix,viewingrange_arguments{:})
end





