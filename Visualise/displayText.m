function displayText(text_display)
    n_lines = length(text_display);
    n_col = ceil(n_lines/12);
    if n_col>1
        for i = 1:n_col
            line_index=12*(i-1)+1:(i~=n_col)*12*(i)+(i==n_col)*n_lines;
            text_display_by_col = text_display(line_index);
            x_coord = (i-1)/(n_col);
            text(x_coord,0.5,text_display_by_col,'Interpreter','none')
        end
    else
        text(0.5,0.5,text_display,'Interpreter','none')
    end
    ax = gca;
    ax.Visible='off';
end