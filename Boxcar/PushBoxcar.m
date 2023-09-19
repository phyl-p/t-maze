function boxcar = PushBoxcar(boxcar,Wz)
%assume columns index time, and the current timestep is stored in col 1
%n_boxcars = size(boxcar,2);
%the jordan0block code could be optimised by instead calculating the block
%in InitialiseCoreVars so that the calculation does not need to be repeated
%each timestep

%jb0mat = GetJordan0Block(n_boxcars);
%boxcar = boxcar*jb0mat;
%boxcar(:,1) = Wz;

boxcar = [Wz,boxcar(:,1:end-1)]; %modification Jul 21 2019; might be faster