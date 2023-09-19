function [excite,boxcar] = ...
    BoxcarStep(Wz, boxcar, boxcar_scales)
%old implementation
% [t_modulo,col_permutation] = BoxcarIndices(timestep,boxcar_scales);
% boxcar(:,t_modulo) = Wz;
% excite = boxcar(:,col_permutation) * boxcar_scales';

% new implementation
boxcar = PushBoxcar(boxcar,Wz);
excite = boxcar * boxcar_scales';
end
