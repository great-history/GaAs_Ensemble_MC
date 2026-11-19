%% GaAs_GValley_CLS
% electric field along the z direction
% for different electric field, GAMMA may take different values
% E field ( V/nm )  0.5    1     2     5       8      10
% eneMax ( 1/s )    0.5    0.8   1     1.25    1.5    2
Ez = 4 * 10^3 * 10^(-7); % unit : V/nm    values : [ 0.5 / 1 / 2 / 5 / 8 / 10 ] * 10^3 * 10^(-7)

% temperature
TE = 300;
TL = 300;

totSteps = 1001;
deltaEne = 0.001; % unit : eV
eneList = (0:totSteps-1)*deltaEne; % to avoid the zero energy because it will induce infinty

if ~exist('currentDateTime', 'var')
    currentDateTime = datestr(now, 'yyyymmdd_HHMMSS');
end

%% GaAs class for Gamma valley
GaAsGv = GaAs_GValley_CLS(TE, TL, currentDateTime);

GaAsGv = GaAsGv.get_all_scattering_rates(eneList);
GaAsGv = GaAsGv.get_all_accumulated_Wns();

% GaAsGv.plot_scattering_rates_one_valley()
% GaAsGv.plot_Wns_one_valley()

%% GaAs class for L valley
GaAsLv = GaAs_LValley_CLS(TE, TL, currentDateTime);

GaAsLv = GaAsLv.get_all_scattering_rates(eneList);
GaAsLv = GaAsLv.get_all_accumulated_Wns();

% GaAsLv.plot_scattering_rates_one_valley()
% GaAsLv.plot_Wns_one_valley()

%% GaAs class for X valley
GaAsXv = GaAs_XValley_CLS(TE, TL, currentDateTime);

GaAsXv = GaAsXv.get_all_scattering_rates(eneList);
GaAsXv = GaAsXv.get_all_accumulated_Wns();

% GaAsXv.plot_scattering_rates_one_valley()
% GaAsXv.plot_Wns_one_valley()

%%
GaAsValleyPack = {GaAsGv, GaAsLv, GaAsXv};

%% some coefficients
% to-do : energy window
% enewin1 = 0.3;
% enewin2 = 0.6;
% enewin3 = 0.9;
% enewin4 = 1.2;
% enewin5 = 1.5;

% \sqrt{2mE/hbar^2} = k
kGFactor = sqrt(2 * GaAsGv.eMass * GaAsGv.meff / GaAsGv.hbar^2 * GaAsGv.eCharge) * 10^(-9); % unit : 1 / (sqrt{eV} * nm)     0.5147
kLFactor = sqrt(2 * GaAsGv.eMass * GaAsLv.meff / GaAsLv.hbar^2 * GaAsLv.eCharge) * 10^(-9);
kXFactor = sqrt(2 * GaAsGv.eMass * GaAsXv.meff / GaAsXv.hbar^2 * GaAsXv.eCharge) * 10^(-9);
kFacList = [kGFactor, kLFactor, kXFactor];

% (hbar^2 / 2M)
EGFactor = GaAsGv.hbar^2 / (2 * GaAsGv.eMass * GaAsGv.meff) * (10^(9))^2 / GaAsGv.eCharge; % eV * (nm)^2
ELFactor = GaAsLv.hbar^2 / (2 * GaAsLv.eMass * GaAsLv.meff) * (10^(9))^2 / GaAsLv.eCharge;
EXFactor = GaAsXv.hbar^2 / (2 * GaAsXv.eMass * GaAsXv.meff) * (10^(9))^2 / GaAsXv.eCharge;
EkFacList = [EGFactor, ELFactor, EXFactor];

%% simple test : to get a sense of the order
disp(["average kinetic energy is : ", 3 / 2 * GaAsGv.thermalEne, " eV "])

kLength = sqrt(2 * GaAsGv.meff * GaAsGv.eMass * GaAsGv.thermalEne * GaAsGv.eCharge) / GaAsGv.hbar;
kLength = kLength * 10^(-9);
disp(["momentum magnitude is : ", kLength, " 1/nm "])

tauFlight = (1 / GaAsGv.GAMMA);
disp(["the life time of electron is : ", tauFlight, " s "])

deltaK = tauFlight * (Ez * GaAsGv.eCharge) / GaAsGv.hbar;
disp(["the estimated momentum change is (1/nm)", deltaK])
disp(["to increase the same momentum, the minimum time required is ", kLength / deltaK * tauFlight])
disp(["the estimated number of flights is ", round(kLength / deltaK)])

dETravel = 1 / deltaK * Ez;
disp(["the estimated energy change during a travel is (eV)", dETravel])
disp(["thermal energy is : ", GaAsGv.thermalEne, " eV "])
