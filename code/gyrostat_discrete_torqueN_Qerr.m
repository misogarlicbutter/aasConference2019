function [time, q_out, w_out, torque_out] = gyrostat_discrete_torqueN_Qerr(dt, ... 
    t_start, t_end, inertia, torqueN, w0, q0, P_phi2_N, Pi_N)
% Junette Hsin 
% Discrete attitude determination for gyrostat 
% 
% Inputs: 
%   dt          = time step (s) 
%   t_start     = start time in slew 
%   t_end       = end time in slew 
%   inertia     = inertia in gyrostat frame 
%   torque      = torque in gyrostat frame 
%   w0          = initial angular velocity 
%   q0          = initial quaternions 
%   P_phi2_N    = phi2 desired slew profile 
%   Pi_N        = initial point to be rotated into current 
% 
% Outputs: 
%   time        = time vector at dt steps 
%   q_out       = output quaternions
%   w_out       = output angular velocity 
%   torque_out  = output torque (inertial, or G0) 

% w and Q need to be columns 
if isrow(w0) == 1
    w0 = w0'; 
end 
if isrow(q0) == 1
    q0 = q0'; 
end 
    
% Initialize 
w = w0; 
q = q0;                     % G0_q_G

N_DCM_G = quat2DCM(q);          % G0_DCM_G
torque = N_DCM_G'*torqueN; 

int = 1; 
w_out = [ w0'; zeros(length(dt : dt : (t_end - t_start)), 3 )]; 
q_out = [ q0'; zeros(length(dt : dt : (t_end - t_start)), 4 )];
torque_out = [torqueN'; zeros(length(dt : dt : (t_end - t_start)), 3)]; 
time = [t_start; zeros(length(dt : dt : (t_end - t_start)), 1)]; 

nsteps = 10; 

% Outer for loop, t_start + dt --> t_end 
for t = t_start+dt : dt : t_end 
    
    % First: use torque, propagate attitude 
        for i = 1:nsteps
            dw = inv(inertia)*(torque - cross(w, inertia*w));
            w_skew = [  0      -w(3)    w(2); 
                        w(3)    0      -w(1); 
                       -w(2)    w(1)    0 ] ; 
            dw = inv(inertia) * ( -w_skew * inertia * w + torque); 
            q_skew = [ q(4)     -q(3)       q(2);
                       q(3)      q(4)      -q(1);
                      -q(2)      q(1)       q(4);
                      -q(1)     -q(2)      -q(3)]; 
            dq = 1/2 * q_skew * w ;
            w = w + dw*dt/nsteps;
            q = q + dq*dt/nsteps;
        end
        
        % Find current position vector 
        N_DCM_G = quat2DCM(q);
        G_DCM_N = N_DCM_G'; 
        P_G = G_DCM_N*Pi_N; 
        
        % Compare with phi2 desired slew 
        angle = zeros(length(P_phi2_N), 1); 
        for k = 1:length(P_phi2_N) 
            a = P_G;                    a = a/norm(a); 
            b = P_phi2_N(k, :);         b = b/norm(b); 
            angle(k, 1) = acos(dot(a, b)); 
        end 
        
        % Find index of smallest error, set next desired target 
        index = find(angle == min(angle)); 
        if length(P_phi2_N) >= index + 1 
            P_des = P_phi2_N(index + 1, :); 
        else 
            P_des = P_phi2_N(index, :); 
        end 
        
        % Find rotation matrix between initial and desired vectors 
        % From: http://immersivemath.com/forum/question/rotation-matrix-from-one-vector-to-another/
        a = cross(Pi_N, P_des);        a = a/norm(a); 
        angle = acos( dot( Pi_N/norm(Pi_N), P_des/norm(P_des) ) ); 
        c = cos(angle); 
        s = sin(angle); 
        
        des_DCM_G0 = [  a(1)^2*(1 - c)+c,        a(1)*a(2)*(1-c)-s*a(3),  a(1)*a(3)*(1-c)+s*a(2); 
                        a(1)*a(2)*(1-c)+s*a(3),  a(2)^2*(1-c)+c,          a(2)*a(3)*(1-c)-s*a(1); 
                        a(1)*a(3)*(1-c)-s*a(2),  a(2)*a(3)*(1-c)+s*a(1),  a(3)^2*(1-c)+c        ]; 
        
        % Map torque onto desired direction 
        T_gain = 0.5;                   % i don't know ... let's just try 
        torque = T_gain*des_DCM_G0*torqueN; 
    
    int = int + 1; 
    q_out(int, :) = q'; 
    w_out(int, :) = w'; 
    torque_out(int, :) = torque; 
    time(int) = t; 
    
end 
end 

% inputs: dt, inertia, torque, w0, q0
% outputs: time, q, w 
