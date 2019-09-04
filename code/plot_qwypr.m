function plot_qwypr(t, q, w, torque, a, phi_num, a_max, w_max)
% Plot q, w, torque, ypr 

fsize = 20; 
phi_num = num2str(phi_num); 

% constraints time 
n = 10; 
t_dt = max(t)/n; 
t_lim = 0:t_dt:max(t); 

ylimits_q = get_ylimits(q); 
ylimits_w = get_ylimits(w); 
% ylimits_ypr = get_ylimits(ypr); 
ylimits_torque = get_ylimits(torque); 
ylimits_a = get_ylimits(a); 

figure()
    plot(t, w(:, 1), 'LineWidth', 1.1)
    hold on; 
    plot(t, w(:, 2), 'k--', 'LineWidth', 1.1)
    plot(t, w(:, 3), 'm-.', 'LineWidth', 1.1)
    plot(t_lim, linspace(w_max, w_max, n+1), 'r:x', t_lim, linspace(-w_max, -w_max,n+1), 'k:x')
%     ylim(ylimits_w)
    ylim([-1.1*w_max, 1.1*w_max]) 
    grid on 
    leg = legend('$\dot{\phi}_1$', '$\dot{\phi}_2$', '$\dot{\phi}_3$', '$\dot{\phi}_c$'); 
        set(leg, 'Interpreter', 'latex', 'FontSize', fsize); 
    ylabel('rad/s', 'Interpreter', 'latex', 'FontSize', fsize) 
    xlabel('time (s)', 'Interpreter', 'latex', 'FontSize', fsize)  
    ax = gca;
    ax.FontSize = fsize - 2;  
%     title(strcat('Angular Velocity: $\dot{\phi}_{', phi_num, '}$'), 'Interpreter', 'latex', 'FontSize', fsize)

figure()
    plot(t, q(:, 1), 'b', 'LineWidth', 1.1)
    hold on; 
    plot(t, q(:, 2), 'r--', 'LineWidth', 1.1)
    plot(t, q(:, 3), 'm-.', 'LineWidth', 1.1)
    plot(t, q(:, 4), 'k:', 'LineWidth', 1.2)
%     plot(t_lim, linspace(1,1,n+1), 'k:x', t_lim, linspace(-1,-1,n+1), 'k:x')
    leg = legend('$q_1$', '$q_2$', '$q_3$', '$q_4$'); 
        set(leg, 'Interpreter', 'latex', 'FontSize', fsize); 
    grid on 
    ylim(ylimits_q)
    ylabel('quats', 'Interpreter', 'latex', 'FontSize', fsize)
    xlabel('time (s)', 'Interpreter', 'latex', 'FontSize', fsize) 
    ax = gca;
    ax.FontSize = fsize - 2;  
%     title(strcat('Quaternion: $q_{', phi_num, '}$'), 'Interpreter', 'latex', 'FontSize', fsize)
    
% figure()
%     plot(t, ypr(:, 1), 'LineWidth', 1.1)
%     hold on; 
%     plot(t, ypr(:, 2), 'r--', 'LineWidth', 1.1)
%     plot(t, ypr(:, 3), 'g-.', 'LineWidth', 1.1)
%     legend('Yaw', 'Pitch', 'Roll'); 
%     grid on 
%     ylim(ylimits_ypr)
%     xlabel('time (s)') 
%     ylabel('degrees') 
%     title(strcat('Euler Angles: \phi_{', phi_num, '}'))
    
figure()
    plot(t, torque(:, 1), 'LineWidth', 1.1)
    hold on; 
    plot(t, torque(:, 2), 'r--', 'LineWidth', 1.1) 
    plot(t, torque(:, 3), 'm-.', 'LineWidth', 1.1)
    leg = legend('$\tau_x$', '$\tau_y$', '$\tau_z$'); 
        set(leg, 'Interpreter', 'latex', 'FontSize', fsize); 
    grid on 
    ylim(ylimits_torque)
    xlabel('time (s)', 'Interpreter', 'latex', 'FontSize', fsize)
    ylabel('Nm', 'Interpreter', 'latex', 'FontSize', fsize) 
    ax = gca;
    ax.FontSize = fsize - 2;  
%     title(strcat('Torque: $\tau_{', phi_num, '}$'), 'Interpreter', 'latex', 'FontSize', fsize)
    
figure()
    plot(t(1:end - 1), a(:,1), 'LineWidth', 1.1)
    hold on; 
    plot(t(1:end - 1), a(:, 2), 'k--', 'LineWidth', 1.1)
    plot(t(1:end - 1), a(:, 3), 'm-.', 'LineWidth', 1.1) 
    plot(t_lim, linspace(a_max, a_max, n+1), 'r:x', t_lim, linspace(-a_max, -a_max,n+1), 'k:x')
    leg = legend('$\ddot{\phi}_x$', '$\ddot{\phi}_y$', '$\ddot{\phi_z}$', '$\ddot{\phi_c}$');
        set(leg, 'Interpreter', 'latex', 'FontSize', fsize); 
    grid on 
%     ylim(ylimits_a)
    ylim([-1.1*a_max, 1.1*a_max]) 
    xlabel('time (s)', 'Interpreter', 'latex', 'FontSize', fsize)
    ylabel('rad/s$^2$', 'Interpreter', 'latex', 'FontSize', fsize) 
    ax = gca;
    ax.FontSize = fsize - 2;  
%     str = strcat('$\omega_{', phi_num, '}$', 'Interpreter', 'latex'); 
%     title(strcat('Angular Acceleration: $\ddot{\phi}_{', phi_num, '}$'), 'Interpreter', 'latex', 'FontSize', fsize)
end 