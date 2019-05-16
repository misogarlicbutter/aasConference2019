% Simulation parameters 
sim_rate = 0.01;			% sim rate = 100 Hz 
sim_duration = 60*60;  			% sim duration = 60 minutes = 3600 seconds 
t =  0:sim_rate:sim_duration; 		% defining time vector  

% Non-changing parameters 
Pi = [1 0 0; 0 1 0; 0 0 1]; 					% Pi = unit vector of initial point in the G frame 
Pf = [sqrt(3/4) 0 -0.5; ... 
    -0.5, 0, -sqrt(3/4); ... 
    0 1 0];  					% Pf = Unit vector of the final point in the G frame 
ep = pi/12; 					% payload half-cone angle. pi/12 rad = 15 deg  
e = (Pi x Pf) / (Pi x Pf) 			% eigenaxis of PiPf plane 


% each iteration of i represents simulation running at sim rate 
for i = 1:max(size(t))
	
%Check angular separation between sun vector, S, and the plane of P
S = ... 			% unit vector of Sun in the N frame 
alpha = pi/2 ... acos(dot(S, e)) 		% angular separation between Sun vector and PiPf plane 

% If angular separation is less than payload half-cone angle
if alpha < ep 	

		% Determine projection of sun vector onto  PiPf plane 
		S_PiPf = S*cos(alpha) 

		% Slew around the Sun vector 
		if alpha = 0 
			phi_2 = pi; 
		else 
			phi_2 = 2*atan(ep/sin(alpha)); 
		end 

	% Else, if angular separation greater than payload half-cone angle 
	else 
		% Slew around the eigenaxis. If before sun slew: 
		if before sun slew: 
			phi_1 =  
		if after sun slew: 
			phi_3 =  
	end 

	% Perform slew around phi at sim_rate 
	slew ... 

end 
