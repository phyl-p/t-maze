function sequence = genNoise(prototypes,on_noise,off_noise)

    %Dana Schultz, 26 May 2020
    %takes a noiseless prototype sequence and introduces noise
    %-------------------------------
    % Preconditions
    %-------------------------------
    if prod(prod((prototypes==0)+(prototypes==1)))==0
        error('error in myfunc genNoise: all elements of prototype must be either 0 or 1')
    elseif on_noise > 1 ||on_noise < 0 || off_noise > 1 || off_noise < 0
        error('error in myfunc genNoise: on_noise and off_noise must be numbers between 0 and 1')
%     elseif floor(on_noise)~=on_noise || floor(off_noise)~=off_noise
%         error('error in myfunc genNoise: on_noise or off_noise must be integers')
    end
    %-------------------------------
    % Implementation
    %-------------------------------

    len_train=size(prototypes,2);   %length of training
    sequence=prototypes;
    %disp("size of prototypes in gen noise")
    %disp(size(prototypes))
  
    for t = 1:len_train
            %select firing pattern at time t
            current_prototype=prototypes(:,t);

            %% new implementation (probability values instead of ints)
            %if proportion of 0's is greater than the desired on_noise, use
            %probability distribution to turn on neurons at desired noise level
            off_indices = current_prototype == 0; %complements (every 1 turns to 0, all 0s turn to 1s)
            on_prob = off_indices .* rand(size(current_prototype));
            noise_indices =  on_prob < on_noise & on_prob ~= 0;
            sequence(noise_indices,t) = 1;


            %repeat same process as above, turning off neurons at desired level
            off_prob = current_prototype .* rand(size(current_prototype)); 
            noise_indices =  off_prob < off_noise & off_prob ~= 0;
            sequence(noise_indices,t) = 0;
    end
    %disp("sequence size in gen noise")
    %disp(size(sequence))
    
end