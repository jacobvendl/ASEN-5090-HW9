function [ LOS_ENU ] = compute_LOS_ENU(userECEF, satECEF)

    LOS_ECEF = ((satECEF - userECEF) / norm(satECEF - userECEF))';

    userLLA = ecef2lla(userECEF);

    C_ECEF2ENU = ECEF2ENU(userLLA);

    LOS_ENU = C_ECEF2ENU*LOS_ECEF;

end