function displayValues(fields,values)
    fontsize = 9;
    text_display = [fields;values];
    n_lines = length(text_display);
    n_col = 2;
    xfield=0.4; y=0.5;
    text(xfield,y,fields,'Interpreter','none',...
                 'horizontalAlignment', 'right',...
                 'FontSize',fontsize)
    xvalues=0.5;
    text(xvalues,y,values,...
                 'FontSize',fontsize)
    ax = gca;
    ax.Visible='off';
end