function [t1, t2, t3] = find_slew_times(t0, w0, wf, wMax, aMax, phi, phi_t)
% 
% Find slew times 
% 
% Inputs: 
%   t0      = initial time 
%   w0      = initial velocity boundary condition 
%   wf      = final velocity boundary condition 
%   wMax    = angular velocity constraint 
%   aMax    = angular acceleration constraint 
%   phi     = phi angle for slew 
%   phi_t   = phi threshold 
% 
% Outputs: 
%   t1      = time to reach max velocity constraint 
%   t2      = time to end coasting at max velocity (if phi < phi_t, t2 == t1) 
%   t3      = total duration of slew 

if phi > phi_t

%     t1 = t0 + (wMax-w0)/aMax;  
%     % Coast t2 --> angular velocity: trapezoid profile 
%     t2 = t1 - (1/wMax) * ... 
%         ( phi - w0*(t1 - t0) - 0.5*aMax*(t1 - t0)^2 ... 
%         - wMax*(wMax - wf)/aMax + (wMax - wf)^2/(2*aMax) );  
%     t3 = t2 - (wf - wMax)/aMax; 
    
    %% Determine Phi slew times - Mohammad's scratch derived equations 

    t1 = t0 + (wMax-w0)/aMax; 

    t2 = t1 + (1/wMax) * ... 
        ( phi + wMax*(wf - wMax)/aMax + 0.5*aMax*((wf - wMax)/aMax)^2 ... 
        - aMax/2*(t1 - t0)^2 - w0*(t1 - t0) ); 

    t3 = t2 - (wf - wMax)/aMax; 

else 
    
    % angular velocity: triangle profile 
    % ONLY works for rest-slew-rest portions of slew 
    
    t3 = sqrt(4*phi/aMax);
    t2 = t3/2; 
    t1 = t2; 
    
end 