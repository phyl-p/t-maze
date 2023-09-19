function success_table = CountSuccessesInFolder(scorethreshold,foldername,metavarname)
if exist('metavarname','var')
    data = load(foldername);
    folder_meta = data.(metavarname);
else
    folder_meta = dir(foldername);
end
file_names = {folder_meta(3:end).name}'; %start index from 3 because index 1 is '.' and 2 is '..' 
                                         %(indicating current and parent
                                         %folders)

                                         
%index of score indicator in the filename (in our case the maximum number of consecutive successes)
loc_score       = 28:30;
%indices that are self explanatory
loc_boxcar      = 7;
loc_n_patterns  = 10:11;
loc_seed	    = 15:17;


n_files = length(file_names);

varnames = {'success','n_boxcars','n_patterns','seed'};
rs_table = table(  'Size',             [n_files,4],...
                   'VariableTypes',    {'uint16','uint16','uint16','uint16'},...
                   'VariableNames',    varnames...
         );

for idx = 1:n_files
    fname = file_names{idx}(1:end-4);   %end-4 used to eliminate the .mat extension at the end of the filename
    rs_table{idx,'success'}     = str2double(fname(loc_score));
    rs_table{idx,'n_boxcars'}   = str2double(fname(loc_boxcar));
    rs_table{idx,'n_patterns'}  = str2double(fname(loc_n_patterns));
    rs_table{idx,'seed'}        = str2double(fname(loc_seed));
end


n_pat_list    = SortUniqueTableVect(rs_table,'n_patterns');
boxcar_list   = SortUniqueTableVect(rs_table,'n_boxcars');
[boxcar_grid,n_pat_grid] = meshgrid(boxcar_list,n_pat_list);
boxcar_col = boxcar_grid(:);
n_pat_col  = n_pat_grid(:);

success_table = table(boxcar_col,n_pat_col,zeros(size(n_pat_col)),...
                    'VariableNames', {'n_boxcars','n_patterns','success_rate'});

%vect_seeds_completed = zeros(size(n_pat_list));
for n_boxcars = boxcar_list
    for n_pat = n_pat_list'
        idx_rs  =   rs_table.n_patterns == n_pat &...
                    rs_table.n_boxcars  == n_boxcars;
        idx_target = success_table.n_patterns == n_pat &...
                     success_table.n_boxcars  == n_boxcars;
        success_table{idx_target,'success_rate'} = mean( rs_table{idx_rs,'success'}>scorethreshold);
        %vect_seeds_completed(n_pat_list==n_pat) = length(rs_table{idx_rs,'success'});
    end
end


%% plot results
plot(success_table.n_patterns,success_table.success_rate)
ylim([0,1.05])








