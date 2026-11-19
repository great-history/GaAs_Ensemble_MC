%% GaAs single electron within three valley ( G, L, X )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% this part is to simulate one particle in three valley
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% simulation setup
numParticle = 100000; % take values of 1000, 10000, 100000, by comparison, take 100000 can lead to less fluctuations in G valley

% shared variables among workers
shared_GaAsValleyPack = parallel.pool.Constant(@() GaAsValleyPack);

%% time scales
totalTime = 5000; % × timeUnit  5000
intrTime = 5;
numINTR = round(totalTime / intrTime);

GAMMA = GaAsGv.GAMMA; % unit : 1/s
timeUnit = 1 / GAMMA * intrTime;

%% time-resolved quantities
trVelNpList = zeros(3, 3, numINTR, numParticle); % time resolved velocity, the first index is valley, the 2nd is x,y,z
trEneNpList = zeros(3, 1, numINTR, numParticle); % time resolved energy, the first index is valley
trValleyNpList = zeros(1, numINTR, numParticle, 'int8'); % time resolved valley index

tic
for pIndex = 1:1
    %% random number seed for each particle
    rng(1, 'twister');
    
    %% Monte Carlo Simulation for each particle
    deltaTime = 0;
    sumTime = 0;
    numFlag = 0;
    
    %% time-resolved quantities
    trVelList = zeros(3, 3, numINTR); % time resolved velocity, the first index is valley, the 2nd is x,y,z
    trEneList = zeros(3, 1, numINTR); % time resolved energy, the first index is valley
    trValleyList = zeros(1, numINTR, 'int8'); % time resolved valley index

    %% initial state
    valleyIdx = 1; % at Gamma valley
    GaAsValley = shared_GaAsValleyPack.Value{valleyIdx};
    
    [initE, initK, initKVec, initVel, rotMat] = GaAsValley.initialize_state();
    
    %% final state
    finalE = NaN;
    finalK = NaN;
    finalKVec = [NaN; NaN; NaN];
    while numFlag <= numINTR
        
        %% drift process % picosecond : 10^(-12)
        randTau = rand(1);
        tauFlight = - log(randTau) / GAMMA;
    
        n = floor(tauFlight / timeUnit);
        deltaTime = tauFlight - n * timeUnit; % Timer must be smaller than GAMMA
        
        if n >= 1 % 跨越了若干个栏 ( Hurdles )
            for ii = 1:n
                [midKVec, midK, midE, midVel] = GaAsValley.update_state_by_drift(Ez, initKVec, timeUnit);
                
                numFlag = numFlag + 1;
                trVelList(valleyIdx, :, numFlag) = midVel;
                trEneList(valleyIdx, :, numFlag) = midE;
                trValleyList(:, numFlag) = valleyIdx;
                
                initKVec = midKVec;
                initK = midK;
                initE = midE;
                initVel = midVel;
            end
            sumTime = 0; % reset to zero
        end
        
        if sumTime + deltaTime > timeUnit % 跨越了一个栏(Hurdle)
            % first update of middle state
            time1 = timeUnit - sumTime;
            [midKVec, midK, midE, midVel] = GaAsValley.update_state_by_drift(Ez, initKVec, time1);
            
            numFlag = numFlag + 1;
            trVelList(valleyIdx, :, numFlag) = midVel;
            trEneList(valleyIdx, :, numFlag) = midE;
            trValleyList(:, numFlag) = valleyIdx;
    
            initKVec = midKVec;
            initK = midK;
            initE = midE;
            initVel = midVel;
    
            sumTime = sumTime + deltaTime - timeUnit;
    
            % second update of middle state
            [midKVec, midK, midE, midVel] = GaAsValley.update_state_by_drift(Ez, initKVec, sumTime);
            
        else
            %% update middle state
            [midKVec, midK, midE, midVel] = GaAsValley.update_state_by_drift(Ez, initKVec, deltaTime);
            sumTime = sumTime + deltaTime;
        end
        
        %% scattering process
        % determine which scattering event to-do : put it into GaAs_GValley_CLS
        eneIndex = find(eneList >= midE, 1, 'first');
        eneIndex = eneIndex - 1; % to avoid energy becomes larger, we would rather let it smaller rather than bigger
        weightList = squeeze(GaAsValley.wnMatrix(:, eneIndex)); 
    
        % if index > totSteps : to-do
        randEvent = rand(1);
        eventIndex = find(randEvent <= weightList, 1, 'first');
        
        if isempty(eventIndex) % self-scattering : continue to flight
            % update initial state
            initKVec = midKVec; % unit : 1 / nm
            initK = midK;
            initE = midE;
            
            continue
        end
        
        %% other scattering events
        switch eventIndex
            case 1 % ADP ( isotropic )
                [finalE, finalK, finalKVec, rotMat] = GaAsValley.sampling_ADP(midE, midK);
               
                if ~(imag(finalKVec) == 0)
                    fprintf("ADP : %d\n", pIndex);
                    fprintf("complex velocity unphysical");
                    break
                end
            case 2 % POP ABS ( anisotropic )
                % [finalE, finalK, finalKVec, rotMat] = GaAsValley.sampling_POP_ABS_old(midE, midK, rotMat);
                [finalE, finalK, finalKVec, rotMat] = GaAsValley.sampling_POP_ABS(midE, rotMat);
                
                if ~(imag(finalKVec) == 0)
                    fprintf("POP ABS : %d\n", pIndex);
                    fprintf("complex velocity unphysical");
                    break
                end
            case 3 % POP EMS ( anisotropic )
                % [finalE, finalK, finalKVec, rotMat] = GaAsValley.sampling_POP_EMS_old(midE, midK, rotMat);
                [finalE, finalK, finalKVec, rotMat] = GaAsValley.sampling_POP_EMS(midE, rotMat);
                
                if ~(imag(finalKVec) == 0)
                    fprintf("POP EMS : %d\n", pIndex);
                    fprintf("complex velocity unphysical");
                    break
                end
            otherwise % IV (isotropic)
                % disp(["intervalley scattering, from ", valleyIdx, " to ", GaAsValley.nextValleyList(eventIndex)])
                % update energy and other quantities
                finalE = midE + GaAsValley.dEList(eventIndex);
                
                % update valley % this update must be after the energy update
                valleyIdx = GaAsValley.nextValleyList(eventIndex);
                GaAsValley = shared_GaAsValleyPack.Value{valleyIdx};
        
                % update momentum : since the energy is update, we only need to determine the direction
                phi = 2 * pi * rand(1);
                cosTheta = 1 - 2 * rand(1);
                sinTheta = sqrt(1 - cosTheta^2);
                
                finalK = GaAsValley.kFactor * sqrt(finalE); % unit : 1 / nm
                finalKVec = finalK * [sinTheta * [cos(phi); sin(phi)]; cosTheta];
                % momentum don't need to be rotated back to lab frame
                
                % update rotation matrix
                rotPhi = [cos(phi), -sin(phi), 0; sin(phi), cos(phi), 0; 0, 0, 1];
                rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
                rotMat = rotPhi * rotTheta;

                if ~(imag(finalKVec) == 0)
                    fprintf("intervalley : %d\n", pIndex);
                    fprintf("complex velocity unphysical");
                    break
                end
        end
    
        %% update initial state for next scattering event % don't need rotation
        initE = finalE;
        initK = finalK;
        initKVec = finalKVec;
        
        % if finalE > 1
        %     fprintf("energy too large : %d\n", pIndex);
        % end
    end
    
    trVelList = trVelList(:,:, 1:numINTR);
    trEneList = trEneList(:,:, 1:numINTR);
    trValleyList = trValleyList(:, 1:numINTR);

    %% post-processing
    % time-resolved
    trVelNpList(:,:,:,pIndex) = trVelList;
    trEneNpList(:,:,:,pIndex) = trEneList;
    trValleyNpList(:, :, pIndex) = trValleyList;

    fprintf("Particle ID : %d\n", pIndex);
end
toc