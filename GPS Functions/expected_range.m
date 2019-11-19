function [ exp_range ] = expected_range ( rx_ecef, gps_ephem, wt_rx_vec, prn )
%==========================================================================
% Set tolerance
%==========================================================================
tol = 10e-12; % m

%==========================================================================
% Load GPS Accepted WGS-84 Constants 
%==========================================================================
muE = 3.986005e14;     % WGS-84 value, m^3/s^2
wE  = 7.2921151467e-5; % WGS-84 value, rad/s 
c   = 2.99792458e8;    % GPS accepted speed of light, m/s

exp_range = zeros(size(wt_rx_vec,1),1);

rx_ecef = reshape(rx_ecef,1,3);
%==========================================================================
% Calculate R iteratively based on speed of light delay
%==========================================================================
for n = 1:size(wt_rx_vec,1)
    W = wt_rx_vec(n,1);
    t_rx = wt_rx_vec(n,2);
    
    [~, sat_ecef_rx] = broadcast_eph2pos(gps_ephem, [W t_rx], prn);

    R = abs(norm(sat_ecef_rx - rx_ecef));
    R_old = 0;

    while abs(R_old - R) > tol
        % Compute time of transmission
        t_tx = t_rx - R/c;

        % Compute transmit position
        [~, sat_ecef_tx] = broadcast_eph2pos(gps_ephem, [W t_tx], prn);

        % Compute receive new best estimated receive position 
        p = wE*(t_rx - t_tx);
        rot = [ cos(p), sin(p), 0;
                       -sin(p), cos(p), 0;
                        0     , 0     , 1];
        sat_ecef_rx = rot*sat_ecef_tx';

        % Save prior R, calculate new R
        R_old = R;
        R = abs(norm(sat_ecef_rx' - rx_ecef));
    end
    
    % Save the expected range once converged
    exp_range(n) = R; 
end

end