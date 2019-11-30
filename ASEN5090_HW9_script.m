%==========================================================================
% Jake Vendl | Jack Toland
% ASEN 5090
% Homework 9
% 12/6/2019
%==========================================================================

clear all; close all; clc

addpath('GPS Functions');

fn = 6.625e6;
fIF = -60e3;

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

for i=1:size(gps_ephem,1)
    PRN(i) = gps_ephem(i,1);
    [~, pos] = broadcast2pos(gps_ephem, tow, PRN(i));
    satECEF(i,1:3) = pos';
    clear pos
end

% Find az el of all sats at 16:29
count=1;
for i=1:size(satECEF,1)
    [az,el,~] = compute_azelrange(GPS_ECEF,satECEF(i,:));
    if el > 0
        azimuth(count) = az;
        elevation(count) = el;
        svs(count) = PRN(i);
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
tstep_sam = 1/fn;
tdur = 0.001; % 1ms
t_vec = 0 : tstep_sam : tdur;

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

% Example 1
tau=9;
fD = 0;
carrier_phase = 2*pi*(fIF + fD)*t_vec;

S=0;
for i=1:length(t_vec)
    ind = round(i+tau);
    S = S + data(ind)*sig_CA_2(i)*exp(-(1i)*carrier_phase(i));
end
fprintf('DOP = %0.0f kHz  DELAY = %0.0f samples  S = %0.4f+%0.4fi \n',fD,tau,real(S),imag(S));


% Example 2
tau=2943;
fD = 1000;
carrier_phase = 2*pi*(fIF + fD)*t_vec;

S=0;
for i=1:length(t_vec)
    ind = round(i+tau);
    S = S + data(ind)*sig_CA_2(i)*exp(-(1i)*carrier_phase(i));
end
fprintf('DOP = %0.0f kHz  DELAY = %0.0f samples  S = %0.4f+%0.4fi \n',fD,tau,real(S),imag(S));

%% ========================================================================
% Problem 3 - Create a search grid
%==========================================================================
% Setup the delay axis

show_plot = true;

% Compute and display a 3D mesh
complex_correlator(2,data,t_vec,show_plot);





%% ========================================================================
% Problem 4 - Find more satellites
%==========================================================================

for s = 1:size(gps_ephem,1) % Look for all satellites
    
    
    
end % s = 1:size(gps_ephem,1)

%% ========================================================================
% Problem 5 - Increase the integration time
%==========================================================================

function [delay, doppler, S_max] = complex_correlator(PRN,data,t_vec,show_plot)

fn = 6.625e6;
fIF = -60e3;

PRN_set = [3,7];

% Create a vector of PRN2 C/A code values
CA = generate_CA_code(PRN_set);

% Match C/A code to time vector
tstep = 0.001/length(CA);
sig_CA = zeros(1,length(t_vec));
for n = 1:length(t_vec)
    tval = t_vec(n);
    partial_index = tval/tstep;
    index = floor(partial_index)+1;
    if index > length(CA)
        index = index - length(CA);
    end
    sig_CA(n) = CA(index); 
end


delay_vec = 0:length(t_vec);

int_time = 2; % ms
dstep = 1000/int_time;
doppler_vec = -5e3:dstep:5e3;

S = zeros(length(delay_vec),length(doppler_vec));
for i = 1:length(delay_vec)
    for j = 1:length(doppler_vec)
        tau = delay_vec(i);
        fD = doppler_vec(j);
        carrier_phase = 2*pi*(fIF + fD)*t_vec;

        sumS=0;
        for k=1:length(t_vec)
            ind = round(k+tau);
            sumS = sumS + data(ind)*sig_CA(k)*exp(-(1i)*carrier_phase(k));
        end
        S(i,j) = norm(sumS);
    end % j = 1:length(doppler_vec)
end % i = 1:length(delay_vec)

[vec_max,idx] = max(S);
[S_max,doppler_idx] = max(vec_max);
delay_idx = idx(doppler_idx);

delay = delay_vec(delay_idx);
doppler = doppler_vec(doppler_idx);

peak_doppler = S(:,doppler_idx);
peak_delay = S(delay_idx,:);

if show_plot == true
    % Plot 3D mesh
    fig = figure; hold on; grid on; grid minor;
    title(sprintf('Complex Correlator of PRN %0.0f',PRN));
    ylabel('Delay [samples]');
    xlabel('Doppler Frequency [Hz]');
    xlim([doppler_vec(1),doppler_vec(end)]);
    ylim([delay_vec(1),delay_vec(end)]);
    zlabel('Magnitude');
    surf(doppler_vec,delay_vec,S);
    view(35,40)
    saveas(fig,sprintf('ASEN5090_HW9_PRN%0.0f_CC.png',PRN),'png');
    
    % Plot Peak Doppler Bin
    fig = figure; hold on; grid on; grid minor;
    title(sprintf('Peak Doppler Bin of PRN %0.0f',PRN));
    xlabel('Delay [samples]');
    ylabel('Complex Correlator Magnitude');
    xlim([delay_vec(1),delay_vec(end)]);
    plot(delay_vec,peak_doppler);
    saveas(fig,sprintf('ASEN5090_HW9_PRN%0.0f_PeakDoppler.png',PRN),'png');
    
    % Plot Peak Delay Bin
    fig = figure; hold on; grid on; grid minor;
    title(sprintf('Peak Delay Bin of PRN %0.0f',PRN));
    xlabel('Doppler [Hz]');
    ylabel('Complex Correlator Magnitude');
    plot(doppler_vec,peak_delay);
    saveas(fig,sprintf('ASEN5090_HW9_PRN%0.0f_PeakDelay.png',PRN),'png');
    
end


end

