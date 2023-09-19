function ViewInhibWeights(data, timestep)
    figure
    h = histogram(data.w_inhib_trial(:, timestep));
    h.Normalization = 'probability';

    title(["Histogram of Inhibitory Weights at Trial", num2str(timestep)])
    xlabel("")
    ylabel("relative frequency weight")
end