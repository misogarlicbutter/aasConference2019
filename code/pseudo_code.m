% MAIN Example 
% Junette Hsin 
% Mohammad Ayoubi 

close all; 

%% Inputs 

% Non-changing parameters; should be function inputs 
inertia = [ 408     0       0; 
            0       427     0; 
            0       0       305]; 
Pi_G = [0; 1; 0];                           % Pi = unit vector of initial point in the G frame 
Pf_G = [1; 0; 0];                           % Pf = unit vector of the final point in the G frame 
S_N = [cosd(45); cosd(45); cosd(45)];       % S = unit vector of sun vector in the N frame 
S_N = S_N/norm(S_N);                        % normalizing sun vector 
G_DCM_N = eye(3);                           % DCM from the N to the G frame 
N_DCM_G = G_DCM_N';                         % G to N frame 
S_G = G_DCM_N*S_N;                          % Sun vector in G frame 
ep = pi/12;                                 % payload half-cone angle. pi/12 rad = 15 deg  
aMax = 1;                                  % Maximum acceleration, rad/s^2
wMax = 1;                                  % Maximum angular velocity, rad/s

%% Calculate slew angles 

% Calculate normal vector of slew plane 
e_G = cross(Pf_G, Pi_G) / norm(cross(Pf_G, Pi_G));  % eigenaxis of PiPf plane, in G frame 
Pperp_G = cross(Pi_G, e_G);              % perpendicular vector to e and Pi, slew plane, G frame 
P_DCM_G = [Pi_G'; Pperp_G'; e_G'];     % DCM from G frame to P (slew plane) frame 
G_DCM_P = P_DCM_G';                         % P to G frame 

% Check angular separation between sun vector S and slew plane 
alpha = pi/2 - acos(dot(S_G, e_G));         % coming out to 0 - check
% alpha = pi/4; 

%%%%%%
% IF angular separation is less than payload half-cone angle --> find phi2
% and phi3. Otherwise, slew is just phi1. 
%%%%%%

% unit_S = S_G/norm(S_G); 
S_PiPf_G = -cross(cross(S_G, e_G), e_G);    % sun projection vector G frame
S_PiPf_G = S_PiPf_G/norm(S_PiPf_G);         % sun projection --> unit vector 

% First slew around eigenaxis
phi1 = acos(dot(Pi_G, S_PiPf_G)) - ep;      % dot product of unit vectors 
if phi1 > pi/2 
    phi1_rem = phi1 - pi/2; 
end 

% Find P1 vector 
P1_P = [cos(phi1); sin(phi1); 0];           % P1 in P frame 
P1_G = G_DCM_P*P1_P;                        % P1 in G frame 

% Find P2 vector 
phiS = acos(dot(S_PiPf_G, Pi_G));           % angle btwn sun projection and Pi 
phiP2 = phiS + ep;                          % angle btwn P2 and Pi 
P2_P = [cos(phiP2); sin(phiP2); 0];         % P2 in P frame 
P2_G = G_DCM_P*P2_P;                        % P2 in G frame 

% Slew around sun vector via phi2 
if alpha == 0
    phi2 = pi; 
else 
    % Not sure how to get the one below: 
    theta = acos(dot(P1_G, S_G)); 
    phi2_M = 2*asin(sin(ep/2)/sin(theta/2)); 
    phi2_M2 = 2*asin(sin(ep)/(2*sin(theta/2)));     % REVISED FORMULA 

    % Junette's derived: 
    theta = acos(dot(S_G, P1_G));           % angle btwn sun and P1 vectors 
    P3_G = S_G*norm(P1_G)*cos(theta);       % P3 vector in G frame (S and P1 already unit vectors)
    P3P1_G = P1_G - P3_G;                   % vector from P3 to P1 
    P3P2_G = P2_G - P3_G;                   % vector from P3 to P2 
    phi2_P3 = acos(dot(P3P1_G/norm(P3P1_G), P3P2_G/norm(P3P2_G)));       % slew around sun vector 

    SP1_G = P1_G - S_G; 
    SP2_G = P2_G - S_G; 
    phi2_S = acos(dot(SP1_G/norm(SP1_G), SP2_G/norm(SP2_G))); 
end 

%% optional plotting routine to check things 

close all; 

plot_option = 1; 
if plot_option == 1
    figure()
        plot3([0 P1_G(1)], [0 P1_G(2)], [0 P1_G(3)], 'b'); 
        grid on; hold on; 
        plot3([0 P2_G(1)], [0 P2_G(2)], [0 P2_G(3)], 'b'); 
        plot3([0 S_G(1)], [0 S_G(2)], [0 S_G(3)], 'r'); 
        plot3([0 S_PiPf_G(1)], [0 S_PiPf_G(2)], [0 S_PiPf_G(3)], 'r'); 
        plot3([0 P3_G(1)], [0 P3_G(2)], [0 P3_G(3)], 'g'); 
        plot3([P3_G(1) P1_G(1)], [P3_G(2) P1_G(2)], [P3_G(3) P1_G(3)], 'g'); 
        plot3([P3_G(1) P2_G(1)], [P3_G(2) P2_G(2)], [P3_G(3) P2_G(3)], 'g'); 
        text(P3_G(1), P3_G(2), P3_G(3), ... 
            sprintf('    phi2 = %0.2f deg', phi2_P3*180/pi))
        title('Dot Product, Phi around P3') 
        xlabel('P perp_G') 
        ylabel('Pi_G')
        zlabel('e_G') 
        
    figure()
        plot3([0 P1_G(1)], [0 P1_G(2)], [0 P1_G(3)], 'b'); 
        grid on; hold on; 
        plot3([0 P2_G(1)], [0 P2_G(2)], [0 P2_G(3)], 'b'); 
        plot3([0 S_G(1)], [0 S_G(2)], [0 S_G(3)], 'g'); 
        plot3([0 S_PiPf_G(1)], [0 S_PiPf_G(2)], [0 S_PiPf_G(3)], 'r'); 
        plot3([S_G(1) P1_G(1)], [S_G(2) P1_G(2)], [S_G(3) P1_G(3)], 'g'); 
        plot3([S_G(1) P2_G(1)], [S_G(2) P2_G(2)], [S_G(3) P2_G(3)], 'g');
        plot3([P1_G(1) P2_G(1)], [P1_G(2) P2_G(2)], [P1_G(3) P2_G(3)], 'g');  
        text(S_G(1), S_G(2), S_G(3), ... 
            sprintf('    phi2_M = %0.2f deg \n     phi2_{M2} = %0.2f deg \n     phi2_S = %0.2f deg', ... 
            phi2_M*180/pi, phi2_M2*180/pi, phi2_S*180/pi))
        title('Chord Trigonometry, Phi around S') 
        xlabel('P perp_G') 
        ylabel('Pi_G')
        zlabel('e_G') 
end 

%%

% Slew around eigenvector via phi3 
% What if Pi and Pf overlap with P2 and P2? Need to ask Mohammad this ... 
phi3 = acos(dot(Pf_G, P2_G)); 
if phi3 > pi/2 
    phi3_rem = phi3 - pi/2; 
end 

%% Determine slew times 

t0 = 0; 
tPhi1 = t0 + wMax/aMax; 

% Mohammad's equation 
tPhi2 = tPhi1 + (1/wMax) * ... 
    ( phi1 - 0.5*aMax(tPhi1)^2 - ... 
    (wMax*wMax)/aMax + (wMax)^2/(2*aMax) ); 

tPhi3 = tPhi2 + tPhi1; 

%% Solve for attitue determination 
        
tEnd = 100; 

phi_1_accel = [ 2*(phi1/2)/tEnd^2;  0;  0];  
torque = inertia*phi_1_accel; 

w_in = [    0.5;    0;      0]; 
q_in = [    0;      0;      0;      1]; 

[t1, y1] = ode45(@(t,Z) gyrostat_cont(inertia, torque, Z), [0, tEnd], [w_in; q_in]);

w_in = y1(end, 1:3)'; 
q_in = y1(end, 4:7)'; 

[t2, y2] = ode45(@(t,Z) gyrostat_cont(inertia, -torque, Z), [0, tEnd], [w_in; q_in]); 

y = [y1; y2]; 
t = [t1; t2]; 

%% Plot 

w = y(:, 1:3); 
ylimits = get_ylimits(w); 

% Plot 
figure()
    plot(t, w) 
    ylim(ylimits)
    legend('w1', 'w2', 'w3'); 
    ylabel('w (rad/s)') 
    xlabel('time (s)') 
    title('Angular Velocity') 

q = y(:, 4:7); 
ylimits = get_ylimits(q); 

figure()
    plot(t, q)
    legend('q1', 'q2', 'q3', 'q4'); 
    ylim(ylimits)
    ylabel('quats') 
    xlabel('time (s)') 
    title('Quaternions') 

%% 
function ylimits = get_ylimits(data) 
% Set y limits of axis 

rng = range(data(:)); 
midp = min(data(:)) + rng/2; 
ylimits = [ midp - 1.2*rng/2, midp + 1.2*rng/2 ]; 

end 