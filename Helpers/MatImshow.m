function MatImshow(mat)
    imshow(mat,'InitialMagnification','fit')
    h = gca;
        h.Visible = 'On'; %this shows the axis labels
        h.Colormap = [1-h.Colormap(:,1:2),ones(256,1)]; %This inverts the colormap from b-w to w-b
 
