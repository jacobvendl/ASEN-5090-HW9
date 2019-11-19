function [ wn,tow ] = cal2gps(ymd )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
jd = cal2jd(ymd(:,1),ymd(:,2),ymd(:,3));
[wn,tow]=jd2gps(jd);
end

