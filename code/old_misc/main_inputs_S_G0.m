

%% Inputs 

% Non-changing parameters; should be function inputs 
% inertia_SC = [ 408     0       0; 
%                0       427     0; 
%                0       0       305]; 
inertia_SC = [ 100     0       0; 
               0       100     0; 
               0       0       100]; 
inertia_w = [  20   0    0; 
               0    20   0; 
               0    0    20  ]; 
ep = pi/12;                                 % payload half-cone angle. pi/12 rad = 15 deg  

% % Initial points / vectors 
% Pi_G0 = [rand*(-1)^round(rand); rand*(-1)^round(rand); rand*(-1)^round(rand)]; Pi_G0 = Pi_G0 / norm(Pi_G0);          
% Pf_G0 = [rand*(-1)^round(rand); rand*(-1)^round(rand); rand*(-1)^round(rand)]; Pf_G0 = Pf_G0 / norm(Pf_G0);  
% while acos(dot(Pi_G0, Pf_G0)) < pi/3
%     Pf_G0 = [rand*(-1)^round(rand); rand*(-1)^round(rand); rand*(-1)^round(rand)]; 
%     Pf_G0 = Pf_G0 / norm(Pf_G0); 
% end 
% 
% Pi_G0 = [rand; rand; rand]; Pi_G0 = Pi_G0 / norm(Pi_G0);          
% Pf_G0 = [rand; rand; rand]; Pf_G0 = Pf_G0 / norm(Pf_G0);  
% while acos(dot(Pi_G0, Pf_G0)) < ep*2
%     Pf_G0 = [rand; rand; rand]; 
%     Pf_G0 = Pf_G0 / norm(Pf_G0); 
% end 
% 
% % Calculate normal vector of slew plane 
% e_G0 = cross(Pf_G0, Pi_G0) / norm(cross(Pf_G0, Pi_G0));  % eigenaxis of PiPf plane, in G frame 
% Pperp_G0 = cross(Pi_G0, e_G0);              % perpendicular vector to e and Pi, slew plane, G frame 
% P_DCM_G0 = [Pi_G0'; Pperp_G0'; e_G0'];     % DCM from G frame to P (slew plane) frame 
% G0_DCM_P = P_DCM_G0';                         % P to G frame 
% % Defining inertial frames 
% % G0_DCM_N = angle2dcm(1, 1, 1);         % DCM from the N to the G frame 
% G0_DCM_N = eye(3); 
% N_DCM_G0 = G0_DCM_N';                         % G to N frame - initial!!! G frame will change throughout sim 
% 
% % Sun vector stuff 
% [alpha, theta_Pi_Sproj, theta_Sproj_Pf, theta_Pi_Pf, S_N, S_PiPf_G0, S_G0] = ... 
%     sun_vector(G0_DCM_N, e_G0, Pi_G0, Pf_G0); 
% 
% % IF angular separation is less than payload half-cone angle --> while loop
% % until alpha < ep. for simulation!!! 
% while abs(alpha) > ep  || theta_Sproj_Pf < ep || theta_Pi_Sproj < ep || ... 
%         theta_Pi_Sproj > theta_Pi_Pf || theta_Sproj_Pf > theta_Pi_Pf 
%     [alpha, theta_Pi_Sproj, theta_Sproj_Pf, theta_Pi_Pf, S_N, S_PiPf_G0, S_G0] = ... 
%         sun_vector(G0_DCM_N, e_G0, Pi_G0, Pf_G0); 
% end 

aMax = 1;                                  % Maximum acceleration, rad/s^2
wMax = 1;                                  % Maximum angular velocity, rad/s

%% Calculate slew angles 

% Calculate the threshold triangle 
% phi_tt = 2*wMax*sqrt(aMax^2 + wMax^2);      % Threshold triangle!!! 
phi_tt = wMax^2/aMax; 

% First slew around eigenaxis
phi1 = acos(dot(Pi_G0, S_PiPf_G0)) - ep;      % dot product of unit vectors 
if phi1 > pi/2 
    phi1_rem = phi1 - pi/2; 
end 

% Find P1 vector in G0 frame 
P1_P = [ cos(phi1); sin(phi1); 0 ];           % P1 in P frame 
P1_G0 = G0_DCM_P*P1_P;                        % P1 in G frame 

% Find P2 vector 
phiS = acos(dot(S_PiPf_G0, Pi_G0));           % angle btwn sun projection and Pi 
phiP2 = phiS + ep;                          % angle btwn P2 and Pi 
P2_P = [cos(phiP2); sin(phiP2); 0];         % P2 in P frame 
P2_G0 = G0_DCM_P*P2_P;                        % P2 in G frame 

%% EVERYTHING THERE IS TO FIND PHI2

% Slew around sun vector via phi2 
if alpha == 0
    phi2 = pi; 
else 
    % Not sure how to get the one below: 
    theta = acos(dot(P1_G0, S_G0)); 
    phi2_M = 2*asin(sin(ep/2)/sin(theta/2)); 
    phi2_M2 = 2*asin(sin(ep)/(2*sin(theta/2)));     % REVISED FORMULA 

    % Junette's derived: 
    theta = acos(dot(S_G0, P1_G0));           % angle btwn sun and P1 vectors 
    P3_G0 = S_G0*norm(P1_G0)*cos(theta);       % P3 vector in G frame (S and P1 already unit vectors)
    P3P1_G0 = P1_G0 - P3_G0;                   % vector from P3 to P1 
    P3P2_G0 = P2_G0 - P3_G0;                   % vector from P3 to P2 
    phi2_P3 = acos(dot(P3P1_G0/norm(P3P1_G0), P3P2_G0/norm(P3P2_G0)));       % slew around sun vector 

    SP1_G0 = P1_G0 - S_G0; 
    SP2_G0 = P2_G0 - S_G0; 
    phi2_S = acos(dot(SP1_G0/norm(SP1_G0), SP2_G0/norm(SP2_G0))); 
    phi2 = phi2_P3; 
end 

%%%
top = dot(S_G0, cross(P1_G0, P2_G0)); 
bot = dot(P1_G0, P2_G0) - dot(S_G0, P1_G0)*dot(S_G0, P2_G0);
phi2_M3 = abs( atan2 ( top, bot ) ); 
%%%
theta = acos(dot(P1_G0, S_G0)); 
top = (pi/2 - alpha)*sin(ep); 
bot = cos(ep) - cos(theta)*cos(alpha); 
phi2_M4 = 2*abs(atan2(top, bot)); 

%%%

%%

% FINDING PHI2

    SPa_G0 = P2_G0 - S_G0; 
    SPb_G0 = P1_G0 - S_G0; 
    SPe_G0 = cross(SPa_G0, SPb_G0); 

    SP1_G0 = SPb_G0; 
        SP1_G0 = SP1_G0 / norm(SP1_G0); 
    SP3_G0 = SPe_G0; 
        SP3_G0 = SP3_G0 / norm(SP3_G0); 
    SP2_G0 = cross(SP1_G0, SP3_G0); 
        
    SP_DCM_G0 = [SP1_G0'; SP2_G0'; SP3_G0']; 
    G0_DCM_SP = SP_DCM_G0'; 
    
    S_SP = SP_DCM_G0*S_G0; 

    dphi = 0.001;        % radians 

    v_length = norm(P1_G0 - S_G0); 
    V_SP(1, :) = [1 0 0]*v_length;
    P_SP(1, :) = SP_DCM_G0*P1_G0; 
    V_G0(1, :) = G0_DCM_SP * V_SP(1, :)'; 
    P_G0(1, :) = P1_G0; 
    
    i = 1; 
    P_G0(i, :) = P1_G0'; 
    while dot(P_G0(i, :), P2_G0') < 0.9999
        
        i = i + 1; 
        V_SP(i, :) = [cos(i*dphi), sin(i*dphi), 0 ] * v_length; 
        P_SP(i, :) = S_SP' + V_SP(i, :); 
        
        V_G0(i, :) = G0_DCM_SP * V_SP(i, :)'; 
        P_G0(i, :) = S_G0' + V_G0(i, :); 
        P_G0(i, :) = P_G0(i, :) / norm(P_G0(i, :)); 

        a = P_G0(i, :); 
        b = P_G0(i - 1, :); 
        phi2_P(i) = acos(dot(a, b)/(norm(a)*norm(b)));  
        
    end 

    phi2_P_sum = sum(phi2_P); 
    
    %%

    plot_option = 1; 
    if plot_option == 1
        figure()
            plot3([0 SP1_G0(1)], [0 SP1_G0(2)], [0 SP1_G0(3)], 'r')
            hold on; grid on 
            plot3([0 SP2_G0(1)], [0 SP2_G0(2)], [0 SP2_G0(3)], 'r')
            plot3([0 SP3_G0(1)], [0 SP3_G0(2)], [0 SP3_G0(3)], 'r')
            
            plot3([0 S_G0(1)], [0 S_G0(2)], [0 S_G0(3)], 'r'); 
            plot3([0 S_PiPf_G0(1)], [0 S_PiPf_G0(2)], [0 S_PiPf_G0(3)], 'r'); 

            plot3([0 Pi_G0(1)], [0 Pi_G0(2)], [0 Pi_G0(3)], 'b'); 
            plot3([0 Pf_G0(1)], [0 Pf_G0(2)], [0 Pf_G0(3)], 'b'); 
            plot3([0 P1_G0(1)], [0 P1_G0(2)], [0 P1_G0(3)], 'b'); 
            plot3([0 P2_G0(1)], [0 P2_G0(2)], [0 P2_G0(3)], 'b'); 
            plot3([0 e_G0(1)], [0 e_G0(2)], [0 e_G0(3)], 'b'); 

%             plot3(S_G0 + V_G0(:, 1), S_G0 + V_G0(:, 2), S_G0 + V_G0(:, 3), '-.')
            plot3(P_G0(:, 1), P_G0(:, 2), P_G0(:, 3), '-.')
        %     plot3(GP_G0(:, 1), GP_G0(:, 2), GP_G0(:, 3)) 
        
        
            text(Pi_G0(1), Pi_G0(2), Pi_G0(3), sprintf(' Pi')) 
            text(Pf_G0(1), Pf_G0(2), Pf_G0(3), sprintf(' Pf')) 
            text(e_G0(1), e_G0(2), e_G0(3), sprintf(' e')) 
            text(P1_G0(1), P1_G0(2), P1_G0(3), sprintf(' P1')) 
            text(P2_G0(1), P2_G0(2), P2_G0(3), sprintf(' P2')) 
            text(S_G0(1), S_G0(2), S_G0(3), sprintf(' sun')) 
            text(S_PiPf_G0(1), S_PiPf_G0(2), S_PiPf_G0(3), sprintf(' sun proj')) 
        
    %%
        
    end 

%%%
phi2 = phi2_M4; 
%%%




%%

% Slew around eigenvector via phi3 
% What if Pi and Pf overlap with P2 and P2? Need to ask Mohammad this ... 
phi3 = acos(dot(Pf_G0, P2_G0)); 
if phi3 > pi/2 
    phi3_rem = phi3 - pi/2; 
end 
