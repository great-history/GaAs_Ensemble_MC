function [initE, initK, initKVec, rotMat] = initialize_one_particle(thermalEne, kFactor)
    % energy sampling
    eneAvg = 3 / 2 * thermalEne; % average thermal energy 3/2k_BT, unit : eV
    initE = - eneAvg * log(rand(1)); % unit : eV
    
    % angle sampling ( isotropic )
    phi = 2 * pi * rand(1);
    cosTheta = 1 - 2 * rand(1);
    sinTheta = sqrt(1 - cosTheta^2);
    
    % momentum
    initK = kFactor * sqrt(initE); % assume the electron starts from Gamma valley
    initKVec = initK * [sinTheta * [cos(phi); sin(phi)]; cosTheta];
    
    % rotation matrix
    rotPhi = [cos(phi), -sin(phi), 0; sin(phi), cos(phi), 0; 0, 0, 1];
    rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
    rotMat = rotPhi * rotTheta;
end