%==========================================================================
% Jake Vendl | Jack Toland
% ASEN 5090
% Homework 9
% 12/6/2019
%==========================================================================

clear all; close all; clc

fn = 6.625e6;
IF = -60e3;

lat=40.0; long = -105.15; alt = 1629;
GPS_LLA = [lat; long; alt]';
GPS_ECEF = lla2ecef(GPS_LLA);

%% ========================================================================
% Problem 1 - Visiblity Prediction
%==========================================================================
% Data collected on August 28th, 2018 at 16:29 UTC
yumafilename = 'YUMA240.ALM';
[gps_ephem,gps_ephem_cell] = read_GPSyuma(yumafilename);
week = cal2gps([2018, 08, 28]);
tow = [week, 2*86400+(16*60+29)*60]; %(16 hrs times 60 m/hr + 29min)*60s/m

for i=1:length(gps_ephem)
    [~, pos] = broadcast2pos(gps_ephem, tow, gps_ephem(i,1));
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

% Load the datafile
load('ASEN5091data.mat');

% Create a time vector at intervals of deltaTs
tstep = 1/fn;
tdur = 0.001; % 1ms
t_vec = 0 : tstep : tdur;

% Create a vector of PRN2 C/A code values
PRN_2 = [3, 7]; % PRN 2
CA_2 = generate_CA_code(PRN_2);

% Match C/A code to time vector
tstep = tdur/length(CA_2);
sig_CA_2 = zeros(1,length(t_vec));
for n = 1:length(t_vec)
    tval = t_vec(n);
    partial_index = tval/tstep;
    index = floor(partial_index)+1;
    if index > length(CA_2)
        index = index - length(CA_2);
    end
    sig_CA_2(n) = CA_2(index); 
end

% Create a vector of IF carrier phase
fIF = -60e3;
fD = 0; %????????
carrier_phase = 2*pi*(fIF + fD).*t_vec;

delay = 9;
tau = delay*tstep;
S=0;
for n=1:6625
    S = S + data(n) * (n+delay)*sig_CA_2(n)*exp(-1i*carrier_phase(n));
end

%% ========================================================================
% Problem 3 - Create a search grid
%==========================================================================
% Setup the delay axis
sdur = length(data)/fn;
delay_vec = t_vec;


% Setup the Doppler axisf
Dstep = 1000; % Hz


% Compute and display a 3D mesh




% Peak Doppler, plot S as function of tau
fig = figure('visible','on'); hold on; grid on; grid minor; box on;
set(fig, 'Position', [100 100 900 600]); 
title('Peak Doppler - S as Function of tau');
xlabel('\tau');
ylabel('S');
%plot(el_store,dpr_pre_store,'.','LineWidth',1);
saveas(fig, 'ASEN5090_HW9_3_1.png','png');

% Peak delay, plot S as a function of Doppler


%% ========================================================================
% Problem 4 - Find more satellites
%==========================================================================


%% ========================================================================
% Problem 5 - Increase the integration time
%==========================================================================





