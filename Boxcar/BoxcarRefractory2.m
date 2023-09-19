function [boxcar] = BoxcarRefractory2(z,boxcar,refractory)
% Dana Schultz, 8 Jun 2020    
% divide excitation values by the given factor for neurons that fired
% lowers excitation total for next timestep, making it more difficult for the
% neuron to fire again
%     boxcar(z,end-refractory+1:end) = boxcar(z,end-refractory+1:end) ./ double(refractory);
    
    boxcar(z,:) = boxcar(z,:) ./ double(refractory);
  
end