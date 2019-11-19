function [ C_ECEF2ENU ] = ecef2enu_transformation(lla_pos)

lat_deg = lla_pos(1);
lon_deg = lla_pos(2);
    
C_ECEF2ENU = [-sind(lon_deg), cosd(lon_deg), 0;
              -sind(lat_deg)*cosd(lon_deg), -sind(lat_deg)*sind(lon_deg), cosd(lat_deg);
              cosd(lat_deg)*cosd(lon_deg), cosd(lat_deg)*sind(lon_deg), sind(lat_deg)];

end