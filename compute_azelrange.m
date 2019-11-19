%Jake Vendl
%ASEN 5090
%hw3prob4

function [az,el,range] = compute_azelrange(userECEF,satECEF)
    LOS_ENU = compute_LOS_ENU(userECEF,satECEF);
    
    %range is just the norm of the rho vector
    range = norm(satECEF-userECEF);
    
    %elevation is the angle between z and the norm of the LOS vector
    el = asind(LOS_ENU(3)/norm(LOS_ENU));
    
    %azimuth is the angle between y and x components of ENU vector,
    %subtracted from 90 because it's measured from North
    az = atan2d(LOS_ENU(1),LOS_ENU(2));
    if az<0
        az=az+360;
    end
end

