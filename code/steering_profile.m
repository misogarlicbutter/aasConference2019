% STEERING PROFILE
% Junette Hsin

dt = 1/100;                 % gyrostat attitude solver discretization 

%% Determine Phi 1 slew times

% Initial conditions 
w0 = 0; 
t0 = 0; 
wf = 0; 

[t1, t2, t3] = find_slew_times(t0, w0, wf, wMax, aMax, phi1, phi_t); 

% Discretize slew times to 2 decimal places 
t1 = round(t1, 2); 
t2 = round(t2, 2); 
t3 = round(t3, 3); 

%% Solve for attitude determination - first slew 

% t0 --> t1 
w0 = [    0;    0;      0];                         % wrt initial frame 
q0 = [    0;    0;      0;      1];                 % wrt initial frame 

[t1_phi1, q1_phi1, w1_phi1, torque1_phi1, phi1_phi1] = propagate_attitude(dt, t0, t1, ... 
    e_N, aMax, inertia_SC, w0, q0, wMax); 

% t1 --> t2 
w0 = w1_phi1(end, :)'; 
q0 = q1_phi1(end, :)'; 

[t2_phi1, q2_phi1, w2_phi1, torque2_phi1, phi2_phi1] = propagate_attitude(dt, t1, t2, ... 
    e_N, 0, inertia_SC, w0, q0, wMax); 

% t2 --> t3 
w0 = w2_phi1(end, :)'; 
q0 = q2_phi1(end, :)'; 

[t3_phi1, q3_phi1, w3_phi1, torque3_phi1, phi3_phi1] = propagate_attitude(dt, t2, t3, ... 
    e_N, -aMax, inertia_SC, w0, q0, wMax); 

% Putting it all together 
t_phi1 = [t1_phi1; t2_phi1(2:end); t3_phi1(2:end)]; 
w_phi1 = [w1_phi1; w2_phi1(2:end ,:); w3_phi1(2:end, :)]; 
q_phi1 = [q1_phi1; q2_phi1(2:end ,:); q3_phi1(2:end, :)]; 
torque_phi1 = [torque1_phi1; torque2_phi1(2:end ,:); torque3_phi1(2:end, :)]; 

% acceleration stuff 
a_phi1 = zeros(length(w_phi1) - 1, 3); 
for i = 1:length(w_phi1) - 1 
    a_phi1(i, :) = (1/dt)*(w_phi1(i + 1, :) - w_phi1(i, :)); 
end 
    
%% Determine Phi 2 slew times 

% Starting from rest, ending at rest 
w0 = 0; 
t0 = 0; 
wf = 0; 

[t1, t2, t3] = find_slew_times(t0, w0, wf, wMax, aMax, phi2, phi_t); 

%% Direction of phi2

% depends on angle between sun and eigenaxis 
if acos(dot(e_N, S_N)) < pi/2
    sign = 1; 
else 
    sign = -1; 
end 
    
%% Solve for attitude determination - second slew 

% This is the quaternion of current G in initial G0 frame. G0_q_G
q0 = q_phi1(end, :)';               % G0_q_G
w0 = w_phi1(end, :)'; 
phi_w0 = 0; 

[t1_phi2, q1_phi2, w1_phi2, torque1_phi2, phi1_phi2] = propagate_attitude(dt, t0, t1, ... 
    S_N, sign*aMax, inertia_SC, w0, q0, wMax); 

% t1 --> t2 
w0 = w1_phi2(end, :)'; 
q0 = q1_phi2(end, :)'; 

[t2_phi2, q2_phi2, w2_phi2, torque2_phi2, phi2_phi2] = propagate_attitude(dt, t1, t2, ... 
    S_N, 0, inertia_SC, w0, q0, wMax); 

% t2 --> t3 
w0 = w2_phi2(end, :)'; 
q0 = q2_phi2(end, :)';  

[t3_phi2, q3_phi2, w3_phi2, torque3_phi2, phi3_phi2] = propagate_attitude(dt, t2, t3, ... 
    S_N, -sign*aMax, inertia_SC, w0, q0, wMax); 

% Putting it all together 
t_phi2 = [t1_phi2; t2_phi2(2:end); t3_phi2(2:end)]; 
w_phi2 = [w1_phi2; w2_phi2(2:end ,:); w3_phi2(2:end, :)]; 
q_phi2 = [q1_phi2; q2_phi2(2:end ,:); q3_phi2(2:end, :)]; 
torque_phi2 = [torque1_phi2; torque2_phi2(2:end, :); torque3_phi2(2:end, :)]; 

% acceleration stuff 
a_phi2 = zeros(length(w_phi2) - 1, 3); 
for i = 1:length(w_phi2) - 1 
    a_phi2(i, :) = (1/dt)*(w_phi2(i + 1, :) - w_phi2(i, :)); 
end 

%% Determine Phi 3 slew times

w0 = 0; 
t0 = 0; 
wf = 0; 

[t1, t2, t3] = find_slew_times(t0, w0, wf, wMax, aMax, phi3, phi_t); 

%% Solve for attitue determination - third slew 

% t0 --> t1 
w0 = w_phi2(end, :)'; 
q0 = q_phi2(end, :)';  

[t1_phi3, q1_phi3, w1_phi3, torque1_phi3, phi1_phi3] = propagate_attitude(dt, t0, t1, ... 
    e_N, aMax, inertia_SC, w0, q0, wMax); 

% t1 --> t2 
w0 = w1_phi3(end, :)'; 
q0 = q1_phi3(end, :)'; 

[t2_phi3, q2_phi3, w2_phi3, torque2_phi3, phi2_phi3] = propagate_attitude(dt, t1, t2, ... 
    e_N, 0, inertia_SC, w0, q0, wMax); 

% t2 --> t3 
w0 = w2_phi3(end, :)'; 
q0 = q2_phi3(end, :)'; 

[t3_phi3, q3_phi3, w3_phi3, torque3_phi3, phi3_phi3] = propagate_attitude(dt, t2, t3, ... 
    e_N, -aMax, inertia_SC, w0, q0, wMax); 

% Putting it all together 
t_phi3 = [t1_phi3; t2_phi3(2:end); t3_phi3(2:end)]; 
w_phi3 = [w1_phi3; w2_phi3(2:end ,:); w3_phi3(2:end, :)]; 
q_phi3 = [q1_phi3; q2_phi3(2:end ,:); q3_phi3(2:end, :)]; 
torque_phi3 = [torque1_phi3; torque2_phi3(2:end ,:); torque3_phi3(2:end, :)]; 

% acceleration stuff 
a_phi3 = zeros(length(w_phi3) - 1, 3); 
for i = 1:length(w_phi3) - 1 
    a_phi3(i, :) = (1/dt)*(w_phi3(i + 1, :) - w_phi3(i, :)); 
end 

%% total slew stuff 

t_total = [ t_phi1; ... 
            t_phi1(end) + t_phi2(2:end); ... 
            t_phi1(end) + t_phi2(end) + t_phi3(2:end)]; 
        
w_total = [ w_phi1; ... 
            w_phi2(2:end, :); ... 
            w_phi3(2:end, :)]; 
        
q_total = [ q_phi1; ... 
            q_phi2(2:end, :); ...  
            q_phi3(2:end, :)]; 
        
torque_total = [torque_phi1; ... 
            torque_phi2(2:end, :); ... 
            torque_phi3(2:end, :)]; 

% total acceleration stuff 
a_total = zeros(length(w_total) - 1, 3); 
for i = 1:length(w_total) - 1 
    a_total(i, :) = (1/dt)*(w_total(i + 1, :) - w_total(i, :)); 
end 

%% PHI NOMINAL - IF THERE WAS NO SUN INTRUSION 

% Determine Phi Nom slew times

% Initial conditions 
w0 = 0; 
t0 = 0; 
wf = 0; 

[t1, t2, t3] = find_slew_times(t0, w0, wf, wMax, aMax, theta_Pi_Pf, phi_t); 

% Discretize slew times to 2 decimal places 
t1 = round(t1, 2); 
t2 = round(t2, 2); 
t3 = round(t3, 3); 

%% Solve for attitue determination - phi nominal 

% t0 --> t1 
w0 = [    0;    0;      0];                         % wrt G0 frame 
q0 = [    0;    0;      0;      1];                 % wrt G0 frame  

[t1_phiNom, q1_phiNom, w1_phiNom, torque1_phiNom, phi1_phiNom] = propagate_attitude(dt, t0, t1, ... 
    e_N, aMax, inertia_SC, w0, q0, wMax); 

% t1 --> t2 
w0 = w1_phiNom(end, :)'; 
q0 = q1_phiNom(end, :)'; 

[t2_phiNom, q2_phiNom, w2_phiNom, torque2_phiNom, phi2_phiNom] = propagate_attitude(dt, t1, t2, ... 
    e_N, 0, inertia_SC, w0, q0, wMax); 

% t2 --> t3 
w0 = w2_phiNom(end, :)'; 
q0 = q2_phiNom(end, :)'; 

[t3_phiNom, q3_phiNom, w3_phiNom, torque3_phiNom, phiNom_phiNom] = propagate_attitude(dt, t2, t3, ... 
    e_N, -aMax, inertia_SC, w0, q0, wMax); 

% Putting it all together 
t_phiNom = [t1_phiNom; t2_phiNom(2:end); t3_phiNom(2:end)]; 
w_phiNom = [w1_phiNom; w2_phiNom(2:end ,:); w3_phiNom(2:end, :)]; 
q_phiNom = [q1_phiNom; q2_phiNom(2:end ,:); q3_phiNom(2:end, :)]; 
torque_phiNom = [torque1_phiNom; torque2_phiNom(2:end ,:); torque3_phiNom(2:end, :)]; 

% acceleration stuff 
a_phiNom = zeros(length(w_phiNom) - 1, 3); 
for i = 1:length(w_phiNom) - 1 
    a_phiNom(i, :) = (1/dt)*(w_phiNom(i + 1, :) - w_phiNom(i, :)); 
end 