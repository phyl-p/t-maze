function Save2Excel(yourstructure, filename)
    %this function saves a structure to excel
    filename = strcat(filename, ".xlsx");
    writetable(struct2table(yourstructure), filename)

end