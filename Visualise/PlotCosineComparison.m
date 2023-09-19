function PlotCosineComparison(cosine_matrix,len_trial,trial)
%note that imshow on a matrix whose entries are between 0 and 1
    %interprets that matrix as a greyscale image, s.t. the indices of the
    %matrix specify a pixel and the corresponding pixel will be black if
    %the entry is 0, white if 1.
    %I used 1-cosine_matrix rather than the original cosinematrix as the
    %greyscale colormap. This is because the cosine comparison is
    %easier to view if the stronger values are brighter than the 
    %weaker values; otherwise the image gets too dark, as most of the
    %values on the cosine comparison matrix are closer to 0.
    imshow(cosine_matrix,'InitialMagnification','fit')
    %display a greyscale colorbar to the right hand side
    h = gca;
    h.Visible = 'On'; %this shows the axis labels
    h.Colormap = 1-h.Colormap; %This inverts the colormap from b-w to w-b
    %{
    c = colorbar(...
        'Direction','reverse',...
        'Ticks',0:0.1:1,...
        'TickLabels',1:-0.1:0 ...
        );%as we are looking at a color inverted version of the original 
          %cosine comparison image, the colorbar had to be adjusted 
          %accordingly.
    %}
    %h.YDir, which sets the direction of the y axis, is usually set to
    %reverse so that the first row of the matrix appears on the top and the
    %last on the bottom. As we are interested in viewing a plot of time, it
    %would make more sense that earlier timesteps are plotted near the
    %origin; this is achieved by settings h.YDir to 'normal'
    h.YDir = 'normal';
    c=colorbar;
    %label the colorbar
    c.Label.String = 'cos (\theta_{ij})';
    %if the following is not run, imshow will preserve the aspect ratio and
    %display each entry of the matrix only in 1 pixel. daspect auto allows
    %the aspect ratio to be stretched to fit the figure window.
    daspect auto
    if exist('trial','var')
        title({['cosine comparison, trial ',num2str(trial)]})
    end
    xaxislabel = 'inputs at time j = 1 to ';
    yaxislabel = 'test outputs at i = 1 to ';
    if exist('len_trial','var')
        xlabel([xaxislabel,num2str(len_trial)])
        ylabel([yaxislabel,num2str(len_trial)])
    end
    
    
    