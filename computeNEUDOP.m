function [xyztDOP, neuDOP] = computeNEUDOP(posXYZ, mH)

    posLLH  =   xyz_2_lla_PVT(posXYZ);
    lat = posLLH(1);
    lon = posLLH(2);

    % Transformation matrix of ENU to XYZ
    mR  =   [   -sin(lon),  -sin(lat)*cos(lon),     cos(lat)*cos(lon);      ...
                cos(lon),   -sin(lat)*sin(lon),     cos(lat)*sin(lon);      ...
                0,          cos(lat),               sin(lat)        ];      ...
            
    mP      =   inv(mH'*mH);
    % DOP values for x, y, z, t
    xyztDOP =   sqrt(diag(mP));
    
    mPxyz   =   mP(1:3, 1:3);
    
    neuDOP  =   sqrt(diag(mR' * mPxyz * mR));
end