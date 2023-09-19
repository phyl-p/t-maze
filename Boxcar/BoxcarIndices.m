function [t_modulo,col_permutation] = BoxcarIndices(timestep,boxcar_pmf)
t_modulo = mod(timestep-1,numel(boxcar_pmf))+1;
%e.g. for boxcar_pmf that is uniformly 1/3 on 3 possibilities,
%timestep -> t_modulo;
%1+3k |-> 1
%2+3k |-> 2
%3k   |-> 3 %this is the part where the above computation differs from the
            %usual mod operation
intseq = 1:numel(boxcar_pmf);
col_permutation = intseq([t_modulo:-1:1,end:-1:t_modulo+1]);

%set the permutation such that boxcar(:,col_permutation) would be the same
%as the original pushed boxcar we have been using, where the most recent 
%entry is in the first column, and the entry that is about to be deleted
%is in the end column.
end