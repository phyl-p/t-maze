% Katie Winn
% genNoiseTrace: uses the same off-noise and on-noise implementation as
% genNoise, but has options to restrict noise to certain durations 

function sequence = genNoiseTrace(prototypes,on_noise,off_noise)
%takes a noiseless prototype sequence and introduces noise

global cs_duration;
global trace_duration;

global on_noise_during_cs;
global on_noise_during_trace;    
global on_noise_during_us;

global off_noise_during_cs;
global off_noise_during_us;

    %---------------------
    % Preconditions
    %---------------------
    if prod(prod((prototypes==0)+(prototypes==1)))==0
        error('error in myfunc genNoise: all elements of prototype must be either 0 or 1')
    elseif on_noise > 1 ||on_noise < 0 || off_noise > 1 || off_noise < 0
        error('error in myfunc genNoise: on_noise and off_noise must be numbers between 0 and 1')
    end
    
    %---------------------
    % Implementation
    %---------------------

    len_train=size(prototypes,2); %length of training
    sequence=prototypes; 
  
    all_on = (on_noise_during_cs && on_noise_during_trace && on_noise_during_us); %% on-noise during entire training trial
    
    
    for t=1:len_train        
         current_prototype=prototypes(:,t); 
         
         %%%% ON-NOISE %%%%
        
         % during conditioned stimulus
         if on_noise_during_cs == true && all_on == false 
            if t <= cs_duration
                off_indices = current_prototype == 0; %complements (every 1 turns to 0, all 0s turn to 1s)
                on_prob = off_indices .* rand(size(current_prototype));
                noise_indices =  on_prob < on_noise & on_prob ~= 0;
                sequence(noise_indices,t) = 1;
            end
         end
         
         % during trace interval
         if on_noise_during_trace == true && all_on == false
            if t > cs_duration && t <= cs_duration+trace_duration 
                off_indices = current_prototype == 0; %complements (every 1 turns to 0, all 0s turn to 1s)
                on_prob = off_indices .* rand(size(current_prototype));
                noise_indices =  on_prob < on_noise & on_prob ~= 0;
                sequence(noise_indices,t) = 1;
            end
         end    
         
         % during unconditioned stimulus 
         if on_noise_during_us == true && all_on == false
             if t > (cs_duration + trace_duration)
                off_indices = current_prototype == 0; %complements (every 1 turns to 0, all 0s turn to 1s)
                on_prob = off_indices .* rand(size(current_prototype));
                noise_indices =  on_prob < on_noise & on_prob ~= 0;
                sequence(noise_indices,t) = 1;
            end
         end    
      
         % during entire trial length
         if all_on == true
             off_indices = current_prototype == 0; %complements (every 1 turns to 0, all 0s turn to 1s)
             on_prob = off_indices .* rand(size(current_prototype));
             noise_indices =  on_prob < on_noise & on_prob ~= 0;
             sequence(noise_indices,t) = 1;
         end
         
        
         %%%% OFF-NOISE %%%%
         
         % during conditioned stimulus
         if off_noise_during_cs == true
            if t <= cs_duration
                off_prob = current_prototype .* rand(size(current_prototype)); 
                noise_indices =  off_prob < off_noise & off_prob ~= 0;
                sequence(noise_indices,t) = 0;  
            end
         end
         
         % during unconditioned stimulus
         if off_noise_during_us == true 
             if t > (cs_duration + trace_duration)
                off_prob = current_prototype .* rand(size(current_prototype)); 
                noise_indices =  off_prob < off_noise & off_prob ~= 0;
                sequence(noise_indices,t) = 0;  
             end
         end
                
     end
 end

 