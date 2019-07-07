function dZdt = gyrostat_cont(inertia, torque, Z)
% Attitude determination function for finding w and q from inertia, torque,
% and initial w and q 
% 
% Inputs: 
% inertia = [3x3] 
% torque = [3x1] 
% Z(1 - 3) = w
% Z(4 - 7) = q

% Ensure torque is column [3x1]
if isrow(torque) == 1
    torque = torque'; 
end 

w_skew =  [ 0      -Z(3)   Z(2); 
            Z(3)    0     -Z(1); 
           -Z(2)    Z(1)   0]; 
        
q_skew = [  0       Z(3)   -Z(2)    Z(1); 
           -Z(3)    0      -Z(1)    Z(2); 
            Z(2)   -Z(1)    0       Z(3); 
           -Z(1)    Z(2)   -Z(3)    0]; 
       
% w dot [3x1] = ... 
% q dot [4x1] = ... 

dZdt = [    inv(inertia)*(-w_skew * inertia * [Z(1); Z(2); Z(3)] + torque) ; 
            0.5 * q_skew * [Z(4); Z(5); Z(6); Z(7)] ]; 

        