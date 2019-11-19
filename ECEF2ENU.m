%Jake Vendl
%ASEN 5090
%hw3prob2

%define a function to convert ECEF to ENU
%note that this transformation is R1(90-lat)*R3(90+long)

function transMat = ECEF2ENU(lat_deg,lon_deg)
    R1 = [1 0 0;
          0 cosd(90-lat_deg) sind(90-lat_deg);
          0 -sind(90-lat_deg) cosd(90-lat_deg)];
      
    R3 = [cosd(90+lon_deg) sind(90+lon_deg) 0;
          -sind(90+lon_deg) cosd(90+lon_deg) 0;
          0 0 1];
      
    transMat = R1*R3;
end

