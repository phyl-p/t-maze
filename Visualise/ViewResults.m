if exist('data','var') && exist('variables','var')
    ViewZHistory(variables,data);
else
    disp('Need to have a variables and data struct available in the workspace. Either load the struct from a saved file, or run a new simulation')
end