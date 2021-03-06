% MAIN Example 
% Junette Hsin 
% Mohammad Ayoubi 

clear; 
close all; 
main_inputs             % Creates all inputs and variables in workspace 

% optional plotting routine to check things 
plot_option = 0; 
phi1_check_vectors 

%% Determine Phi 1 slew times

w0 = 0; 
t0 = 0; 
wf = 0; 

t1 = t0 + (wMax-w0)/aMax; 

% Mohammad's equation 
t2 = t1 - (1/wMax) * ... 
    ( phi1 - w0*(t1 - t0) - 0.5*aMax*(t1 - t0)^2 ... 
    - wMax*(wMax - wf)/aMax + (wMax - wf)^2/(2*aMax) );  

% % Phi1 times 
% t1_Phi1 = wMax/aMax; 
% t2_Phi1 = Phi1/wMax; 
% t3_Phi1 = t1_Phi1 + t2_Phi1; 

t3 = t2 - (wf - wMax)/aMax; 


%% Solve for attitude determination - first slew 
        
% t0 --> t1 
tEnd = t1 - t0; 
w0 = [    0;    0;      0]; 
q0 = [    0;    0;      0;      1];               % wrt G frame 
a = [ aMax;  0;  0];  
torque = inertia*a;                                 % wrt G frame 

[t1_phi1, y1_phi1] = ode45(@(t,Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w0; q0]); 

% t1 --> t2 
tEnd = t2 - t1; 
w0 = y1_phi1(end, 1:3)'; 
q0 = y1_phi1(end, 4:7)'; 
a = [0; 0; 0]; 
torque = inertia*a; 

[t2_phi1, y2_phi2] = ode45(@(t,Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w0; q0]); 

% t2 --> t3 
tEnd = t3 - t2; 
w0 = y2_phi2(end, 1:3)'; 
q0 = y2_phi2(end, 4:7)'; 
a = [ -aMax; 0; 0]; 
torque = inertia*a; 

[t3_phi1, y3_phi1] = ode45(@(t, Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w0; q0]); 

y_phi1 = [y1_phi1; y2_phi2(2:end, :); y3_phi1(2:end, :)]; 
w_phi1 = y_phi1(:, 1:3); 
q_phi1 = y_phi1(:, 4:7); 

ypr_phi1 = zeros(length(q_phi1), 3); 
for i = 1:max(size(q_phi1))
    ypr_phi1(i, :) = SpinCalc('QtoEA321', q_phi1(i, :), eps, 0); 
end 

t_phi1 = [t1_phi1; t1_phi1(end)+t2_phi1(2:end); t1_phi1(end)+t2_phi1(end)+t3_phi1(2:end)]; 

%% Plot phi1
% ylimits = get_ylimits(q); 
% ylimits = get_ylimits(w); 

% Plot 

if plot_option == 1
figure()
    plot(t_phi1, w_phi1) 
%     ylim(ylimits)
    legend('w1', 'w2', 'w3'); 
    ylabel('w (rad/s)') 
    xlabel('time (s)') 
    title('Angular Velocity Phi 1') 

figure()
    plot(t_phi1, q_phi1)
    legend('q1', 'q2', 'q3', 'q4'); 
%     ylim(ylimits)
    ylabel('quats') 
    xlabel('time (s)') 
    title('Quaternion Phi 1') 
    
figure()
    plot(t_phi1, ypr_phi1)
    legend('Yaw', 'Pitch', 'Roll'); 
    xlabel('time (s)') 
    ylabel('degrees') 
    title('Euler Angles Phi 1') 
end 
    
%% Determine Phi 2 slew times 

w0 = 0; 
t0 = 0; 
wf = 0; 

t1 = t0 + (wMax-w0)/aMax; 

% Mohammad's equation 
t2 = t1 - (1/wMax) * ... 
    ( phi2 - w0*(t1 - t0) - 0.5*aMax*(t1 - t0)^2 ... 
    - wMax*(wMax - wf)/aMax + (wMax - wf)^2/(2*aMax) );  

% % Phi1 times 
% t1_Phi1 = wMax/aMax; 
% t2_Phi1 = Phi1/wMax; 
% t3_Phi1 = t1_Phi1 + t2_Phi1; 

t3 = t2 - (wf - wMax)/aMax; 
    
%% Solve for attitude determination - second slew 

% G --> N frame 
% N_Q_G = SpinCalc('DCMtoQ', N_DCM_G, eps, 1); 
% w_in = N_DCM_G*w_in; 
% q_in = N_Q_G*q_in; 
% torque_N = N_DCM_G*torque; 

%%

a = aMax*S_G; 
torque = inertia*a; 
[t1_phi2, y1_phi2] = ode45(@(t,Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w_in; q_in]);

tEnd = t2 - t1; 
w_in = y1_phi2(end, 1:3)'; 
q_in = y1_phi2(end, 4:7)'; 
a = [0; 0; 0]; 
torque = inertia*a; 

[t2_phi2, y2_phi2] = ode45(@(t,Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w_in; q_in]);

tEnd = t3 - t1; 
w_in = y2_phi2(end, 1:3)'; 
q_in = y2_phi2(end ,4:7)'; 
a = -aMax*S_G; 
torque = inertia*a; 
torque_N = N_DCM_G*torque; 

[t3_phi2, y3_phi2] = ode45(@(t,Z) gyrostat_cont(inertia, torque_N, Z), [0, tEnd], [w_in; q_in]);

y_phi2 = [y1_phi2; y2_phi2(2:end, :); y3_phi2(2:end, :)]; 
w_phi2 = y_phi2(:, 1:3); 
q_phi2 = y_phi2(:, 4:7); 

ypr_phi2 = zeros(length(q_phi2), 3); 

for i = 1:max(size(q_phi2))
    ypr_phi2(i, :) = SpinCalc('QtoEA321', q_phi2(i, :), eps, 0); 
end 

t_phi2 = [t1_phi2; t1_phi2(end) + t2_phi2(2:end); t1_phi2(end) + t2_phi2(end) + t3_phi2(2:end)]; 

%% Plot phi2

w = y_phi2(:, 1:3); 
q = y_phi2(:, 4:7); 

if plot_option == 1
figure()
    plot(t_phi2, w)
    ylim(ylimits)
    legend('w1', 'w2', 'w3'); 
    ylabel('w (rad/s)') 
    xlabel('time (s)') 
    title('Angular Velocity Phi 2') 

figure()
    plot(t_phi2, q)
    legend('q1', 'q2', 'q3', 'q4'); 
    ylim(ylimits)
    ylabel('quats') 
    xlabel('time (s)') 
    title('Quaternion Phi 2') 
    
figure()
    plot(t_phi2, ypr_phi2)
    legend('Yaw', 'Pitch', 'Roll'); 
    xlabel('time (s)') 
    ylabel('degrees') 
    title('Euler Angles Phi 2') 
end 


%% Determine Phi 3 slew times

w0 = 0; 
t0 = 0; 
wf = 0; 

t1 = t0 + (wMax-w0)/aMax; 

% Mohammad's equation 
t2 = t1 - (1/wMax) * ... 
    ( phi1 - w0*(t1 - t0) - 0.5*aMax*(t1 - t0)^2 ... 
    - wMax*(wMax - wf)/aMax + (wMax - wf)^2/(2*aMax) );  

% % Phi1 times 
% t1_Phi1 = wMax/aMax; 
% t2_Phi1 = Phi1/wMax; 
% t3_Phi1 = t1_Phi1 + t2_Phi1; 

t3 = t2 - (wf - wMax)/aMax; 

%% Solve for attitue determination - third slew 
        
% t0 --> t1 
tEnd = t1 - t0; 
w0 = w_phi2(end, :)'; 
q0 = q_phi2(end, :)'; 
a = [ aMax;  0;  0];  
torque = inertia*a; 

[t1_phi3, y1_phi3] = ode45(@(t,Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w0; q0]);

% t1 --> t2 
tEnd = t2 - t1; 
w0 = y1_phi3(end, 1:3)'; 
q0 = y1_phi3(end, 4:7)'; 
a = [0; 0; 0]; 
torque = inertia*a; 

[t2_phi3, y2_phi3] = ode45(@(t,Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w0; q0]); 

% t2 --> t3 
tEnd = t3 - t2; 
w0 = y2_phi3(end, 1:3)'; 
q0 = y2_phi3(end, 4:7)'; 
a = [ -aMax; 0; 0]; 
torque = inertia*a; 

[t3_phi3, y3_phi3] = ode45(@(t, Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w0; q0]); 

y_phi3 = [y1_phi3; y2_phi3(2:end, :); y3_phi3(2:end, :)]; 
w_phi3 = y_phi3(:, 1:3); 
q_phi3 = y_phi3(:, 4:7); 

ypr_phi3 = zeros(length(q_phi3), 3); 
for i = 1:max(size(q_phi3))
    ypr_phi3(i, :) = SpinCalc('QtoEA321', q_phi3(i, :), eps, 0); 
end 

t_phi3 = [t1_phi3; t1_phi3(end)+t2_phi3(2:end); t1_phi3(end)+t2_phi3(end)+t3_phi3(2:end)]; 

%% Plot phi3
ylimits = get_ylimits(q); 
ylimits = get_ylimits(w); 

% Plot 
if plot_option == 1
figure()
    plot(t_phi3, w_phi3) 
    ylim(ylimits)
    legend('w1', 'w2', 'w3'); 
    ylabel('w (rad/s)') 
    xlabel('time (s)') 
    title('Angular Velocity Phi 3') 

figure()
    plot(t_phi3, q_phi3)
    legend('q1', 'q2', 'q3', 'q4'); 
    ylim(ylimits)
    ylabel('quats') 
    xlabel('time (s)') 
    title('Quaternion Phi 3') 
    
figure()
    plot(t_phi3, ypr_phi3)
    legend('Yaw', 'Pitch', 'Roll'); 
    xlabel('time (s)') 
    ylabel('degrees') 
    title('Euler Angles Phi 3') 
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
        
ypr_total = zeros(length(q_total), 3); 
for i = 1:max(size(q_total))
    ypr_total(i, :) = SpinCalc('QtoEA321', q_total(i, :), eps, 0); 
end 
        
%% plot total stuff 
        
plot_total = 1; 
if plot_total == 1

figure()
plot(t_total, w_total) 
    ylim(ylimits)
    grid on
    legend('w1', 'w2', 'w3'); 
    ylabel('w (rad/s)') 
    xlabel('time (s)') 
    title('Angular Velocity Total') 

figure()
    plot(t_total, q_total)
    grid on 
    legend('q1', 'q2', 'q3', 'q4'); 
    ylim(ylimits)
    ylabel('quats') 
    xlabel('time (s)') 
    title('Quaternion Total') 
    
figure()
    plot(t_total, ypr_total)
    grid on 
    legend('Yaw', 'Pitch', 'Roll'); 
    xlabel('time (s)') 
    ylabel('degrees') 
    title('Euler Angles Total') 
    
end 

