function boxcar = BoxcarRefractory(z,boxcar,refractory,inhib,boxcar_scales,timestep)
    %As the last boxcar indexed by 'end' is pushed out, we want to modify
    %   one boxcar more than what is specified by the refractory period in
    %   order to ensure that a refractory period of 1 and no refractory
    %   period are different.
    %why - z*inhib/refractory?
    %   note that the activation threshold of a neuron is at exc == inhib,
    %   i.e. when y = 1/2. Therefore, if we want the refractory period to
    %   ensure that a neuron firing in one timestep will not fire in the
    %   next, we can subtract the inhibition from the whole boxcar. As the
    %   boxcar in the next loop will have the 'end' boxcar pushed out, we
    %   can evenly divide the amount of inhibition by the amount of boxcars
    %   in the next loop, specified by 'refractory'.
    [~,col_permutation] = BoxcarIndices(timestep,boxcar_scales);
    col_idx = col_permutation(end-refractory+1:end);
    boxcar(:,col_idx) = boxcar(:,col_idx) - z*double(inhib)*numel(boxcar_scales)/double(refractory);
end
