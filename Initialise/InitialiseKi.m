%called by MainSingleTask to adjust K0 and Kff accroding to the desired
%mean z, externally activated neuron and total number of neurons
function [k_0,k_fb, k_ff] = InitialiseKi(pm)   
    N = double(pm.number_of_neurons);
    m_e = 0;
    n_c = N*pm.connectivity; %number of desired, non-externally activated neurons
    p = n_c/N;
    w = double(pm.weight_start);
    theta = 0.5;
    gamma = double(pm.k_ff_start)/w;
    a = double(N*pm.desired_mean_z);    
    g = double(pm.gradient);
    %a = (N - m_e)*r_a + m_e; %absolute activity, desired number of firing neurons    
    %g = (N - m_e)* ((p - alpha)*a + beta + gamma*m_e)/(2*a*(2*pi*a*p*(1-p))^0.5)*;
    i_tanh = atanh(1 - 2*(a - m_e)/(N - m_e));
    % Y = atanh( X ) returns the inverse hyperbolic tangent of the elements of X .
    A = double((pi/2)).^(0.5) * double((a*p*(1-p))).^(0.5) * i_tanh;
    B = double((pi/2)).^0.5 * double((a*p*(1-p)))^0.5 * g*a * (m_e - N)/((a- m_e)*(a - N));
    
    k_fb = (w*(1 - theta)/theta) * ((A-B)/(2*a) + p);
    k_0_pre = (w*(1 - theta)/theta) * ((A+B)/2 - gamma * m_e);
    
    %new m_e where it is the total external activation per timestep
    m_e = double(pm.ext_activation);
    i_tanh = atanh(1 - 2*(a - m_e)/(N - m_e));
    A = double((pi/2)).^(0.5) * double((a*p*(1-p))).^(0.5) * i_tanh;
    B = double((pi/2)).^0.5 * double((a*p*(1-p)))^0.5 * g*a * (m_e - N)/((a- m_e)*(a - N));
    
    syms k_0 c k_ff
    eqn1 = k_0_pre == (1 + c)*k_0;
    eqn2 = k_0 == (w*(1 - theta)/theta) * ((A+B)/2 - c * m_e);
    eqn3 = k_ff == c*w;
    sol = solve([eqn1, eqn2 eqn3], [k_0 k_ff c]);
    k_0 = sol.k_0;
    k_ff = sol.k_ff;
    disp(k_0_pre)
    return
end