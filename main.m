%==========================================================================
% Jake Vendl | Jack Toland
% ASEN 5090
% Homework 9
% 12/6/2019
%==========================================================================

clear all; close all; clc

fn = 6.625e6;
IF = -60e3;

lat=40.0; long = 105.15; alt = 1629;
GPS_LLA = [lat; long; alt]';
GPS_ECEF = lla2ecef(GPS_LLA);

%% ========================================================================
% Problem 1 - Visiblity Prediction
%==========================================================================
%data collected on August 28th, 2018 at 16:29 UTC
yumafilename = 'YUMA240.ALM';
[gps_ephem,gps_ephem_cell] = read_GPSyuma(yumafilename);
week = cal2gps([2018, 08, 28]);
tow = [week, 2*86400+(16*60+29)*60]; %(16 hours times 60 min/hr + 29min)*60sec/min

for i=1:length(gps_ephem)
    [~, pos] = broadcast2pos(gps_ephem(i,:), tow, gps_ephem(i,1));
    satECEF(i,1:3) = pos';
    clear pos
end

%now go through and find az el of all sats at 16:29
count=1;
for i=1:length(satECEF)
    [az,el,~] = compute_azelrange(GPS_ECEF,satECEF(i,:));
    if el > 0
        azimuth(count) = az;
        elevation(count) = el;
        svs(count) = i;
        count=count+1;
    end
end
plotAzEl(azimuth,elevation,svs)

%% ========================================================================
% Problem 2 - Carrier Wipeoff
%==========================================================================

% Delay axis
delay = 0;

%% ========================================================================
% Problem 3 - Create a search grid
%==========================================================================


%% ========================================================================
% Problem 4 - Find more satellites
%==========================================================================


%% ========================================================================
% Problem 5 - Increase the integration time
%==========================================================================





