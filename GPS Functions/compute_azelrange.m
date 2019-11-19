function [ AZ, EL, RANGE ] = compute_azelrange(userECEF, satECEF)
    for n = 1:size(satECEF,1)

        diff_ECEF = satECEF(n,:) - userECEF;
        
        RANGE(n) = norm(diff_ECEF);

        LOS_ENU = compute_LOS_ENU(userECEF, satECEF(n,:));

        AZ(n) = atan2d(LOS_ENU(1),LOS_ENU(2));
        EL(n) = asind(LOS_ENU(3)/norm(LOS_ENU));

    end
end