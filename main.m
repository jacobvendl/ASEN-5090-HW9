%Jake Vendl
%ASEN 5090

clear all; close all; clc

fn = 6.625e6;
IF = -60e3;

lat=40.0; long = 105.15; alt = 1629;
GPS_LLA = [lat; long; alt];
GPS_ECEF = lla2ecef(GPS_LLA);

%data collected on August 28th, 2018 at 16:29 UTC
[gps_ephem,gps_ephem_cell] = read_GPSyuma(yumafilename);

