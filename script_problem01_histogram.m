%% GaAs single electron at single valley ( Gamma Valley )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% this part is on the initialization of particles : problem 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numParticle = 10000; % start with 1000, once code works, go to 10000, 100000, etc

%% initial state : assume all electrons start in the Gamma valley
% energy sampling
eneAvg = 3 / 2 * GaAsGv.thermalEne; % average thermal energy, unit : eV

randEList = rand(1, numParticle);
initEneList = - eneAvg * log(randEList); % unit : eV

% three kinds of valleys for electrons : Gamma, L, X
initKList = kGFactor * sqrt(initEneList); %

% angle sampling ( isotropic case )
phiList = 2 * pi * rand(1, numParticle);
cosThetaList = 1 - 2 * rand(1, numParticle);
sinThetaList = sqrt(1 - cosThetaList.^2);

% momentum
initKzList = initKList .* cosThetaList; % along z direction
initKxList = initKList .* sinThetaList .* cos(phiList); % in-plane
initKyList = initKList .* sinThetaList .* sin(phiList); % in-plane

% rotation matrix
% rotPhi = [cos(phi), -sin(phi), 0; sin(phi), cos(phi), 0; 0, 0, 1];
% rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
% rotMat = rotPhi * rotTheta;
% 
% % scattering rates
% GAMMA = GaAsGv.GAMMA;

%% plot histgram to-do
% initial energy histogram
figure
set(gcf, 'unit', 'inch', 'position', [3, 3, 8, 5]) % figure
set(gca, 'Position', [0.2, 0.12, 0.70, 0.75]) % axess
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

subplot(1,2,1)
xlabel('kz(1/nm)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('# of particles', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
axis([min(initKzList) max(initKzList) 0, numParticle / 10])
hold on
histogram(initKzList, 50)
title('histogram of initial $k_z$', 'Interpreter', 'latex', 'FontSize', 13);

% initial energy histogram
subplot(1,2,2)
xlabel('E(eV)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('# of particles', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
axis([min(initEneList) max(initEneList) 0, numParticle / 5])
hold on
histogram(initEneList, 50)
title('histogram of initial E', 'Interpreter', 'latex', 'FontSize', 13);

folderPath = '.\figures_saved_for_problem1';
fileName = [GaAsGv.currentDateTime '_histogram.pdf'];
% 构建完整的文件路径
fullFilePath = fullfile(folderPath, fileName);
exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');
