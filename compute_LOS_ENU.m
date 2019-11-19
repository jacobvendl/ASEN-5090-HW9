%Jake Vendl
%ASEN 5090 
%hw3prob3

function LOS_ENU = compute_LOS_ENU(userECEF, satECEF)
    %find vector from user location to satellite
    userToSat = satECEF - userECEF;
    
    %normalize the vector
    LOS_ECEF = userToSat/norm(userToSat);
    
    %find lat and long of user based on userECEF
    stationAngles = ecef2lla(userECEF);
    
    %transform from ECEF to ENU
    transMat = ECEF2ENU(stationAngles(1),stationAngles(2));
    
    LOS_ENU = transMat*LOS_ECEF';
end

