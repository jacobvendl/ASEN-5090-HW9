function [health, pos, bsv, relsv] = broadcast_eph2pos_etc(alm, t_input, prn)
%==========================================================================
%==========================================================================
% [health, pos] = broadcast_eph2pos(alm,t_input,prn)
%
% Modified from broadcast2pos.m by Jack Toland 09/25/2019
%
% INPUT:               Description                                  Units
%
%  alm    - matrix of gps satellite orbit parameters           (nx25)
%  
%                  col1: prn, PRN number of satellite
%                  col2: M0, mean anomaly at reference time, rad
%                  col3: delta_n, mean motion difference from computed value, rad/s
%                  col4: ecc, eccentricity of orbit
%                  col5: sqrt_a, square root of semi-major axis, m^0.5
%                  col6: Loa, longitude of ascending node of orbit plane at weekly epoch, rad
%                  col7: incl, inclination angle at reference time, rad
%                  col8: perigee, argument of perigee, rad
%                  col9: ra_rate, rate of change of right ascension, rad/s
%                 col10: i_rate, rate of change of inclination angle, rad/s
%                 col11: Cuc, amplitude of the cosine harmonic correction term to the argument of latitude
%                 col12: Cus, amplitude of the sine harmonic correction term to the argument of latitude
%                 col13: Crc, amplitude of the cosine harmonic correction term to the orbit radius
%                 col14: Crs, amplitude of the sine harmonic correction term to the orbit radius
%                 col15: Cic, amplitude of the cosine harmonic correction term to the angle of inclination
%                 col16: Cis, amplitude of the cosine harmonic correction term to the angle of inclination
%                 col17: Toe, reference time ephemeris (seconds into GPS week)
%                 col18: IODE, issue of data (ephemeris) 
%                 col19: GPS_week, GPS Week Number (to go with Toe)
%                 col20: Toc, time of clock
%                 col21: Af0, satellite clock bias (sec)
%                 col22: Af1, satellite clock drift (sec/sec)
%                 col23: Af2, satellite clock drift rate (sec/sec/sec)
%                 col24: Timing Group Delay (TGD), seconds
%                 col25: health, satellite health (0=good and usable)
%
%  t_input      - GPS times to calculate values at                 [WN TOW] (nx2)
%  prn          - PRN to compute values for (one satellite only)                       
%
%
%
% OUTPUT:       
%    
%  health       - health of satellite (0=good)                              (nx1)
%  pos          - position of satellite (ECEF)                  [x y z]   m (nx3)
%  bsv          - satellite clock correction                              m (nx1)                                   
%
%
% Coupling:
%
%   mean2eccentric.m
%
% References:
% 
%   [1] Interface Control Document: IS-GPS-200D
%         < http://www.navcen.uscg.gov/gps/geninfo/IS-GPS-200D.pdf >
%
%   [2] Zhang, J., et.all. "GPS Satellite Velocity and Acceleration
%         Determination using the Broadcast Ephemeris". The Journal of
%         Navigation. (2006), 59, 293-305.
%            < http://journals.cambridge.org/action/displayAbstract;jsess ...
%                ionid=C6B8C16A69DD7C910989C661BAB15E07.tomcat1?fromPage=online&aid=425362 >
%
%   [3] skyplot.cpp by the National Geodetic Survey
%          < http://www.ngs.noaa.gov/gps-toolbox/skyplot/skyplot.cpp >
%
%==========================================================================
%==========================================================================


% NOTE: Numbered equations in the code (e.g., Eq. 21) correspond to 
%  equations in the [2] reference.

%==========================================================================
% Load GPS Accepted WGS-84 Constants 
%==========================================================================
muE = 3.986005e14;     % WGS-84 value, m^3/s^2
wE  = 7.2921151467e-5; % WGS-84 value, rad/s 
c   = 2.99792458e8;    % GPS acceptd speed of light, m/s

%==========================================================================
% Initialize Output Variables for Speed 
%==========================================================================
sz          = size(t_input,1);
pos         = ones(sz,3) * NaN;
health      = ones(sz,1) * NaN; 
bsv         = ones(sz,1) * NaN;
relsv       = ones(sz,1) * NaN;

%==========================================================================
% Pull Out Correct Ephemerides 
%==========================================================================

% Pull out ephemerides for PRN in question
kk  = find(alm(:,1) == prn);  % kk is vector containing row numbers of alm that are for sat.no. 'index' 
sat_ephem = alm(kk,:);        % sat_ephem is matrix of all ephem data for each entry of sat.no. 'index'


% No matching PRN found, returning data will be NaNs
if isempty(kk),return,end 




%==========================================================================
% Start Main Calculation Loop 
%==========================================================================

% Compute elapsed times of each ephemeris epoch wrt first entry, seconds
dt_ephem = (sat_ephem(:,19) - sat_ephem(1,19))*604800 + (sat_ephem(:,17) - sat_ephem(1,17));


% Compute elapsed times of each input time wrt first ephemeris entry, seconds
dt_input = (t_input(:,1) - sat_ephem(1,19))*604800 + (t_input(:,2) - sat_ephem(1,17));



for tt = 1:sz % loop through all input times


    % Pull out most recent ephemeris values
%     jj = max( find(dt_input(tt) >= dt_ephem) ); % sat_ephem(:,17) = toe (sec into GPS week) of each entry
                                                % jj = row of specific sat. ephem. data with epoch closest to input time
    
    % Pull out nearest ephemeris values                                                                                        
    [mn,jj] = min(abs( dt_input(tt) - dt_ephem ));
        
    
                                                      
    if isempty(jj),continue,end  % no matching ephemeris time found. continue to next input time 


    % Pull out common variables from the ephemeris matrix
    %======================================================================
    %toe = sat_ephem(jj,17);           % time of ephemeris
    dt  = dt_input(tt) - dt_ephem(jj); % seconds difference from epoch
    
    a   = sat_ephem(jj,5)^2;           % semimajor axis, sqrt(a) = gps_alm(:,5) (meters)
    ecc = sat_ephem(jj,4);             % eccentricity
    n0  = sqrt(muE/a^3);               % nominal mean motion (rad/s)
    n   = n0 + sat_ephem(jj,3);        % corrected mean motion, delta_n = gps_alm(:,3)
    M   = sat_ephem(jj,2) + n*dt;      % mean anomaly, M0 = gps_alm(:,2)


    % Compute perigee, true and eccentric anomaly...
    %======================================================================

    % Load argument of perigee to a local variable and add perigee rate, rad
    perigee  = sat_ephem(jj,8); % + perigee_rate * dt;  

    % Compute Eccentric Anomaly, rad
    E    = mean2eccentric(M,ecc);
    cosE = cos(E);  
    sinE = sin(E);

    % Compute true anomaly, rad
    nu    = atan2( sqrt(1 - ecc*ecc).*sinE,  cosE-ecc ); 

    % Compute the argument of latitude, rad 
    p = nu + perigee;  % true anomaly + argument of perigee

    
    % Correct the arguement of latitude, rad
    C_uc = sat_ephem(jj,11);
    C_us = sat_ephem(jj,12);
    
    du = C_us*sin(2*p) + C_uc*cos(2*p);
    u = p + du;
        
    
    % Compute radius and inclination
    %======================================================================
    % radius with correction
    C_rc = sat_ephem(jj,13);
    C_rs = sat_ephem(jj,14);
    
    r   = a * (1 - ecc*cosE);
    dr = C_rs*sin(2*p) + C_rc*cos(2*p);
    r = r + dr;
      
    % inclination with correction
    C_ic = sat_ephem(jj,15);
    C_is = sat_ephem(jj,16);
    i_dot = sat_ephem(jj,10);
      
    inc = sat_ephem(jj,7);
    dinc = C_is*sin(2*p) + C_ic*cos(2*p);
    inc = inc + dinc + i_dot*dt;

    cosu = cos(u);    
    sinu = sin(u);  

    % Compute satellite position in orbital plane (Eq. 13)
    %======================================================================
    xo = r * cosu;    % satellite x-position in orbital plane
    yo = r * sinu;    % satellite y-position in orbital plane

    % Corrected longitude of ascending node for node rate and Earth rotation
    %======================================================================
    % Ascending node = alm(jj,6)
    node = sat_ephem(jj,6) + (sat_ephem(jj,9) - wE)*dt -  (wE * sat_ephem(jj,17)); % Toe = gps_alm(jj,17)

    % Calculate GPS Satellite Position in ECEF (m)
    %======================================================================
    cosi = cos(inc);    sini = sin(inc);
    coso = cos(node);   sino = sin(node);


    % Satellite position in ECEF (m)
    pos(tt,1) = xo*coso - yo*cosi*sino;  %x-position  

    pos(tt,2) = xo*sino + yo*cosi*coso;  %y-position 

    pos(tt,3) = yo*sini;                 %z-position
    

    % Keep track of health of each satellite
    %======================================================================      
    health(tt,1) = sat_ephem(jj,25); % satellite health (0.00 is useable)
        
    % Calculate the satellite clock correction of each satellite
    %======================================================================
    a0 = sat_ephem(jj,21);
    a1 = sat_ephem(jj,22);
    bsv(tt,1) = c*(a0 + a1*dt);
    
    % Calculate the satellite relativity correction
    %======================================================================
    relsv(tt,1) = -c*(-2/c^2 * sqrt(a*muE) * ecc * sinE);

end