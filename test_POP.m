%% test POP angle distribution
if ~exist('currentDateTime', 'var')
    currentDateTime = datestr(now, 'yyyymmdd_HHMMSS');
end

% temperature
TE = 300;
TL = 300;

%% GaAs class for Gamma valley
GaAsGv = GaAs_GValley_CLS(TE, TL, currentDateTime);
% [initE, initK, initKVec, initVel, rotMatOld] = GaAsGv.initialize_state();
initE = 3 / 2 * GaAsGv.thermalEne; % average thermal energy 3/2k_BT, unit : eV
% initE = initE * 0.55;
initK = GaAsGv.kFactor * sqrt(initE); % unit : 1 / nm

numTest = 10000000;
thetaList = zeros(1,numTest);
scatMech = 1;
switch scatMech
    %% POP ABS
    case 1
        for ii = 1:numTest
            % the first thing is to update energy
            Ef = initE + GaAsGv.dEList(2);
            
            % the second thing is to update momentum : since the energy is update, we only need to determine the direction
            % direction
            phi = 2 * pi * rand(1);
            
            % rp = rand(1);
            % s = GaAsGv.omega0 / initE;
            % x1 = sqrt(1 + s) + 1;
            % x2 = sqrt(1 + s) - 1;
            % cosTheta = 1 / 2 * (x1^(1 - rp) * x2^(rp) - x1^(rp) * x2^(1 - rp));
            % theta = acos(cosTheta);
            % thetaList(ii) = theta;

            rp = rand(1);
            s = 2 * sqrt(initE * (initE + GaAsGv.omega0)) / (sqrt(initE) - sqrt(initE + GaAsGv.omega0))^2;
            cosTheta = ((1 + s) - (1 + 2 * s)^rp) / s;
            theta = acos(cosTheta);
            thetaList(ii) = theta;
        end
    %% POP EMS
    case 2
        for ii = 1:numTest
            % the first thing is to update energy
            Ef = initE + GaAsGv.dEList(3);
            
            % the second thing is to update momentum : since the energy is update, we only need to determine the direction
            % direction
            phi = 2 * pi * rand(1);
            
            rp = rand(1);
            s = 2 * sqrt(initE * (initE - GaAsGv.omega0)) / (sqrt(initE) - sqrt(initE - GaAsGv.omega0))^2;
            cosTheta = ((1 + s) - (1 + 2 * s)^rp) / s;
            theta = acos(cosTheta);
            thetaList(ii) = theta;
        end
    %% Coulomb
    case 3
        LDebye = 5; % unit : nm
        for ii = 1:numTest
            % the first thing is to update energy
            Ef = initE + GaAsGv.dEList(2);
            
            % the second thing is to update momentum : since the energy is update, we only need to determine the direction
            % direction
            phi = 2 * pi * rand(1);
            
            rp = rand(1);
            cosTheta = 1 - 2 * rp / (1 + 4 * initK^2 * LDebye^2 * (1 - rp));
            theta = acos(cosTheta);
            thetaList(ii) = theta;
        end
end

%% plot histgram to-do
% initial energy histogram
figure
set(gcf, 'unit', 'inch', 'position', [3, 3, 8, 5]) % figure
set(gca, 'Position', [0.2, 0.12, 0.70, 0.75]) % axess
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

xlabel('$\theta$(rad)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('# of bins', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')

switch scatMech
    case 1
        axis([0 pi 0, numTest / 15])
        hold on
        histogram(thetaList, 50)
        title('histogram of the polar angle for POP ABS', 'Interpreter', 'latex', 'FontSize', 13);
    case 2
        axis([0 pi 0, numTest / 17.5])
        hold on
        histogram(thetaList, 60)
        title('histogram of the polar angle for POP EMS', 'Interpreter', 'latex', 'FontSize', 13);
    case 3
        axis([0 pi 0, numTest / 20])
        hold on
        histogram(thetaList, 60)
        title('histogram of the polar angle for Coulomb', 'Interpreter', 'latex', 'FontSize', 13);
end


% folderPath = '.\figures_saved_for_problem1';
% fileName = [GaAsGv.currentDateTime '_POP_angle_histogram.pdf'];
% % 构建完整的文件路径
% fullFilePath = fullfile(folderPath, fileName);
% exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');
