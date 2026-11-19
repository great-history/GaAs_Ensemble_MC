classdef GaAs_GValley_CLS
    % a class for Gamma valley of GaAs
    
    properties
        %% temperature
        TE % electron temperature ( assume room temperature ), unit : K
        TL % lattice temperature ( assume the same as electron temperature ), unit : K
        thermalEne % thermal energy, unit : eV
        eneList
        totSteps
        
        kFactor
        EkFactor
        dos3Dunit % the prefactor before 3D DOS expression, m^{-3} * eV^{-3/2}

        %% intervalley phonon
        omegaifList
        dEfiList
        dEList
    end
    
    % scattering rates of Gamma valley
    properties
        % the time the cls created, for saving figures
        currentDateTime

        scatRateStruct
        scatNameList
        nextValleyList
        wnMatrix
        GAMMA
    end

    properties (Constant)
        % physics constants
        hbar = 1.05457182 * 10^(-34); % unit : m^2 kg / s
        eMass = 9.1093837 * 10^(-31); % unit : kg
        eCharge = 1.60217663 * 10^(-19); % unit : C
        epsilon0 = 8.854187187 * 10^(-12); % unit : F/m
        kB = 1.380649 * 10^(-23); % unit : m^2 kg s^{-2} K^{-1} = J * K^{-1}

        rho = 5.37 * 10^6 / 10^3; % unit : kg/m^3
        
        %% GaAs effective mass at Gamma valley ( isotropic & parabolic )
        mteff = 0.063; % unit : dimensionless
        mleff = 0.063; % unit : dimensionless
        meff = 0.063; % unit : dimensionless

        %% GaAs acoustic phonon properties for Gamma valley
        vs = 5.22 * 10^5 * 10^(-2); % longitudinal acoustic velocity, valid for G,L,X valleys, unit : m/s
        
        %% acoustic phonon
        DA = 7.01; % acoustic deformation potential for electron in Gamma Valley, unit : eV

        %% GaAs polar optical phonon properties
        kappa0 = 12.9; % unit : dimensionless
        kappaInf = 10.92; % unit : dimensionless
        omega0 = 0.03536; % optical deformation phonon energy for G valley, it actually is hbar * omega0, unit : eV
        
        %% intervalley optical phonon ( from G to L or X )
        % DifList = [10, 10] * 10^8 * 10^2; % unit : eV/m
        DifList = [1.8, 10] * 10^8 * 10^2; % unit : eV/m
        ZifList = [8 / 2, 6 / 2]; % unit : dimensionless 
        % effective mass at L valley and X valley
        mfList = [0.170, 0.58]; % unit : dimensionless
        
    end
    
    %% initialization
    methods
        % initialize
        function obj = GaAs_GValley_CLS(TempElectron, TempLattice, currentDateTime)
            obj.currentDateTime = currentDateTime;

            % temperature & thermal energy
            obj.TE = TempElectron;
            obj.TL = TempLattice;
            obj.thermalEne = obj.kB * obj.TL / obj.eCharge; % unit : eV
            
            obj.kFactor = sqrt(2 * obj.eMass * obj.meff / obj.hbar^2 * obj.eCharge) * 10^(-9); % unit : 1 / (sqrt{eV} * nm)
            obj.EkFactor = obj.hbar^2 / (2 * obj.eMass * obj.meff) * (10^(9))^2 / obj.eCharge; % eV * (nm)^2
            % density of states
            dos3Dfac = 1 / (2 * pi^2) * (2 * obj.eMass / obj.hbar^2)^(3/2); % unit : m^{-3} / J^{3/2}
            obj.dos3Dunit = dos3Dfac * (obj.eCharge)^(3/2); % unit : be m^{-3} * eV^{-3/2}
            
            % intervalley
            omegaGL = 0.0278; % from G to L, unit : eV   0.035
            omegaGX = 0.0299; % from G to X, unit : eV
            obj.omegaifList = [omegaGL, omegaGX]; % unit : eV

            dELG = 0.29; % diff between L and G, unit : eV
            dEXG = 0.48; % diff between X and G, unit : eV
            obj.dEfiList = [dELG, dEXG]; % unit : eV
            obj.dEList = [0, obj.omega0, - obj.omega0, omegaGL - dELG, - omegaGL - dELG, ...
                            omegaGX - dEXG, - omegaGX - dEXG]; % energy measured from the bottom of the final valley % unit : eV
            
            obj.nextValleyList = [1, 1, 1, 2, 2, 3, 3];
            % obj.scatNameList = ["ADPGv", "POPGvABS", "POPGvEMS", "IVGLABS", "IVGLEMS", "IVGXABS", "IVGXEMS"];
            
        end
        
        % the purpose is to get the order of momentum, energy
        function simple_test(obj)
            disp(["thermal energy is : ", obj.thermalEne, " eV "])
            disp(["average kinetic energy is : ", 3 / 2 * obj.thermalEne, " eV "])

            kLength = sqrt(2 * obj.meff * obj.eMass * obj.thermalEne * obj.eCharge) / obj.hbar;
            kLength = kLength * 10^(-9);
            disp(["momentum magnitude is : ", kLength, " 1/nm "])
        end

        % density of states for Gamma valley
        function dos3DList = get_dos(obj, eneList)            
            dos3DList = obj.meff^(3/2) * obj.dos3Dunit * sqrt(eneList); % unit is cm^{-3} * eV^{-1}
        end
    end
    
    %% scattering
    methods
        %% acoustic_phonon
        function ADPList = get_ADP_scattering_rate(obj, eneList)
            dos3DList = obj.get_dos(eneList);
            
            acousFactor = pi * (obj.DA * obj.eCharge)^2 * (obj.thermalEne * obj.eCharge) / ...
                                (obj.hbar * obj.rho * obj.vs^2);
            
            ADPList = acousFactor * (dos3DList / obj.eCharge); % unit : s^{-1}
        end
        
        %% polar_optical_phonon
        function [POPABSList, POPEMSList] = get_POP_scattering_rate(obj, eneList)
            No = (exp(obj.omega0 / obj.thermalEne) - 1)^(-1);
            
            popFactor = (obj.eCharge)^2 * (obj.omega0 * obj.eCharge) * (obj.kappa0/obj.kappaInf - 1) /...
                           (2 * pi * obj.kappa0 * obj.epsilon0 * obj.hbar^2 * sqrt(2 / (obj.eMass * obj.meff))); 
            
            % absorption
            POPABSList = popFactor * No ./ sqrt(obj.eCharge * eneList) .* asinh(sqrt(eneList / obj.omega0));
            if isnan(POPABSList(1)) % to avoid NaN for the zero energy
                POPABSList(1) = POPABSList(2);
            end

            % emission ( only for electron energy higher than polar optical phonon )
            POPEMSList = zeros(size(eneList));
            index1 = find(eneList > obj.omega0, 1, 'first');
            POPEMSList(index1:end) = popFactor * (No + 1) ./ sqrt(obj.eCharge * eneList(index1:end)) .* ...
                                            asinh(sqrt(eneList(index1:end) / obj.omega0 - 1));
        end
        
        %% intervalley_phonon
        % for Gamma valley, vfIndex = 1 : L valley, vfIndex = 2 : X valley
        function [scat_IVABS_List, scat_IVEMS_List] = get_IV_scattering_rate(obj, valley, eneList)
            if valley == "L"
                ii = 1;
                dEabs = obj.dEList(4);
                dEems = obj.dEList(5);
            elseif valley == "X"
                ii = 2;
                dEabs = obj.dEList(6);
                dEems = obj.dEList(7);
            else
                disp("no such a final valley")
            end

            % prepare parameters
            Dif = obj.DifList(ii);
            Zf = obj.ZifList(ii);
            omegaif = obj.omegaifList(ii);
            mf = obj.mfList(ii); % effective mass at final valley
            

            % number of phonons in the final valley
            Nif = (exp(omegaif / obj.thermalEne) - 1)^(-1);
            
            % IV ABS
            dos3D_IVABS_List = zeros(size(eneList));
            index1 = find(eneList > - dEabs, 1, 'first');
            dos3D_IVABS_List(index1:end) = 1 * (mf)^(3/2) * obj.dos3Dunit * sqrt(eneList(index1:end) + dEabs); % unit : m^{-3} * eV^{-1}
            scat_IVABS_List = pi * (Dif * obj.eCharge)^2 * Zf * obj.hbar / ...
                                (2 * (obj.rho) * (omegaif * obj.eCharge)) * Nif * (dos3D_IVABS_List / obj.eCharge);

            % IV EMS
            dos3D_IVEMS_List = zeros(size(eneList));
            index2 = find(eneList > -dEems, 1, 'first');
            dos3D_IVEMS_List(index2:end) = 1 * (mf)^(3/2) * obj.dos3Dunit * sqrt(eneList(index2:end) + dEems); % unit is m^{-3} * eV^{-1}
            scat_IVEMS_List = pi * (Dif * obj.eCharge)^2 * Zf * obj.hbar / ...
                            (2 * (obj.rho) * (omegaif * obj.eCharge)) * (Nif + 1) * (dos3D_IVEMS_List / obj.eCharge);
        end
    
        %% all scattering rates at Gamma valley
        function obj = get_all_scattering_rates(obj, eneList)
            obj.eneList = eneList;
            obj.totSteps = length(eneList);
            
            % acoustic phonon ( intravalley )
            ADP_List = obj.get_ADP_scattering_rate(eneList);

            % polar optical phonon ( intravalley )
            [POPABS_List, POPEMS_List] = obj.get_POP_scattering_rate(eneList);

            % intervalley optical phonon scattering
            [IVGLABS_List, IVGLEMS_List] = obj.get_IV_scattering_rate("L", eneList);
            [IVGXABS_List, IVGXEMS_List] = obj.get_IV_scattering_rate("X", eneList);

            % struct
            obj.scatRateStruct = struct('ADPGv', ADP_List, ...
                'POPGvABS', POPABS_List, 'POPGvEMS', POPEMS_List, ...
                'IVGLABS', IVGLABS_List, 'IVGLEMS', IVGLEMS_List, ...
                'IVGXABS', IVGXABS_List, 'IVGXEMS', IVGXEMS_List);
            
            obj.scatNameList = fieldnames(obj.scatRateStruct);
        end

        %% calculate the accumulated scattering rate W_n at Gamma valley
        function obj = get_all_accumulated_Wns(obj)
            numScat = length(obj.scatNameList);
            obj.wnMatrix = zeros(numScat, obj.totSteps);
            % I want to do a re-order
    
    
            obj.wnMatrix(1, :) = obj.scatRateStruct.(obj.scatNameList{1});
            for ii = 2:numScat
                scatName = obj.scatNameList{ii};
                obj.wnMatrix(ii, :) = obj.scatRateStruct.(scatName) + obj.wnMatrix(ii - 1, :);
            end
            
            obj.GAMMA = max(obj.wnMatrix(end,:)); % the scatGamma should be large enough but also small enough
            obj.wnMatrix = obj.wnMatrix / obj.GAMMA;
        end
    
        %% calculate Wn in second way
        function obj = get_all_Wns(obj)
            numScat = length(obj.scatNameList);
            obj.wnMatrix = zeros(numScat, obj.totSteps);
            % I want to do a re-order
    
    
            obj.wnMatrix(1, :) = obj.scatRateStruct.(obj.scatNameList{1});
            for ii = 2:numScat
                scatName = obj.scatNameList{ii};
                obj.wnMatrix(ii, :) = obj.scatRateStruct.(scatName) + obj.wnMatrix(ii - 1, :);
            end

            % 
            % for ii = 1:8
            %     index1 = find(obj.eneList > 0.25 * (ii - 1), 1, 'first');
            %     index2 = find(obj.eneList > 0.25 * ii, 1, 'first');
            %     if isempty(index2)
            %         index2 = obj.totSteps;
            %     end
            % 
            %     Gamma1 = max(max(obj.wnMatrix(:, index1:index2-1)));
            % 
            %     obj.wnMatrix(:, index1:index2-1) = obj.wnMatrix(:, index1:index2-1) / Gamma1;
            % end
            
            % divide the energy range into two : [0, 0.5] & [0.5, 2]
            index1 = find(obj.eneList >= 0.075, 1, 'first');
            Gamma1 = max(max(obj.wnMatrix(:, 1:index1)));
            Gamma2 = max(max(obj.wnMatrix(:, index1 + 1:end)));
            obj.wnMatrix(:, 1:index1) = obj.wnMatrix(:, 1:index1) / Gamma1;
            obj.wnMatrix(:, index1 + 1:end) = obj.wnMatrix(:, index1 + 1:end) / Gamma2;
        end
    end
    
    %% plot
    methods
        %% plot scattering rates
        function plot_scattering_rates_one_valley(obj)
            figure
            set(gcf, 'unit', 'inch', 'position', [3, 3, 7, 6]) % figure
            set(gca, 'Position', [0.12, 0.12, 0.85, 0.75]) % axess
            set(gca, 'XDir', 'normal')
            set(gca, 'YDir', 'normal')
            set(gca, 'YScale', 'log');   % change y axis to log10 scale
            
            xlabel('E(eV)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
            ylabel('Scattering Rates [1/s]', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
            set(gca, 'XColor', 'k')
            set(gca, 'YColor', 'k')
            
            axis([0 obj.eneList(end)*1.01 10^(10), 10^(15)])
            hold on
            line_width = 1;
            
            colorList = ['k','r','r','b','b','g','g','m','m'];
            linestyList = ["-","-","--","-","--","-","--","-","--"];

            numGvScat = length(obj.scatNameList);
            for ii = 1:numGvScat
                scatName = obj.scatNameList{ii};
                plot(obj.eneList, obj.scatRateStruct.(scatName), 'Color', colorList(ii), 'LineWidth', line_width, 'LineStyle', linestyList(ii), 'DisplayName', scatName);
                hold on
            end
            
            title('Scattering Rates for the G Valley ( Electron )', 'Interpreter', 'latex', 'FontSize', 16);
            legend('Location', 'southeast', 'NumColumns', 1);
            
            folderPath = '.\figures_saved_for_problem1';
            fileName = [obj.currentDateTime '_scattering_rate_G_valley.pdf'];
            % 构建完整的文件路径
            fullFilePath = fullfile(folderPath, fileName);
            exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');

        end
        
        %% plot Wn
        function plot_Wns_one_valley(obj)
            figure
            set(gcf, 'unit', 'inch', 'position', [3, 3, 7, 6]) % figure
            set(gca, 'Position', [0.12, 0.12, 0.85, 0.75]) % axess
            set(gca, 'XDir', 'normal')
            set(gca, 'YDir', 'normal')
            
            xlabel('E(eV)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
            ylabel('Wn', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
            set(gca, 'XColor', 'k')
            set(gca, 'YColor', 'k')
            
            axis([0 obj.eneList(end)*1.01 0, 1])
            hold on
            line_width = 1;
            colorList = ['k','r','r','b','b','g','g','m','m'];
            linestyList = ["-","-","--","-","--","-","--","-","--"];

            numScat = length(obj.scatNameList);
            for ii = 1:numScat
                plot(obj.eneList, obj.wnMatrix(ii, :), 'Color', colorList(ii), 'LineWidth', line_width, 'LineStyle', linestyList(ii));
                hold on
            end
            title('Wn for the G Valley ( Electron )', 'Interpreter', 'latex', 'FontSize', 16);
            
            folderPath = '.\figures_saved_for_problem1';
            fileName = [obj.currentDateTime '_Wns_G_valley.pdf'];
            % 构建完整的文件路径
            fullFilePath = fullfile(folderPath, fileName);
            exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');

        end
    end

    %% sampling
    methods
        function [Ef, kf, kfVec, rotMatNew] = sampling_POP_ABS_old(obj, Ei, ki, rotMatOld)
            % the first thing is to update energy
            Ef = Ei + obj.dEList(2);
            
            % the second thing is to update momentum : since the energy is update, we only need to determine the direction
            % direction
            phi = 2 * pi * rand(1);
            
            rp = rand(1);
            s = obj.omega0 / Ei;
            x1 = sqrt(1 + s) + 1;
            x2 = sqrt(1 + s) - 1;
            cosTheta = 1 / 2 * (x1^(1 - rp) * x2^(rp) - x1^(rp) * x2^(1 - rp));
            sinTheta = sqrt(1 - cosTheta^2);
            % Theta is the angle between \vec{k}_i and \vec{q}, not the angle between \vec{k}_i and \vec{k}_f
            
            % momentum ( under the relative frame )
            % we first determine the phonon momentum q and then the final k of the electron
            
            qOp = - ki * cosTheta + ki * sqrt((cosTheta)^2 + s); % unit : 1 / nm
            kf = sqrt(ki^2 + qOp^2 + 2 * ki * qOp * cosTheta); % unit : 1 / nm
            % kf = obj.kFactor * sqrt(Ef); % unit : 1 / nm
            
            kzf = ki + qOp * cosTheta;
            kxyf = qOp * sinTheta * [cos(phi); sin(phi)]; % in-plane % not kf * sinTheta !!!
            kfVec = [kxyf; kzf];

            %% transform from relative frame to lab frame
            kfVec = rotMatOld * kfVec;

            % update cosTheta, sinTheta, and phi
            cosTheta = kfVec(3) / kf;
            sinTheta = sqrt(1 - cosTheta^2);
            finalKxy = sqrt(kfVec(1)^2 + kfVec(2)^2);
            cosphi = kfVec(1) / finalKxy;
            sinphi = kfVec(2) / finalKxy;
    
            % update rotation matrix
            rotPhi = [cosphi, -sinphi, 0; sinphi, cosphi, 0; 0, 0, 1];
            rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
            rotMatNew = rotPhi * rotTheta;
        end

        function [Ef, kf, kfVec, rotMatNew] = sampling_POP_ABS(obj, Ei, rotMatOld)
            % the first thing is to update energy
            Ef = Ei + obj.dEList(2);
            
            % the second thing is to update momentum : since the energy is update, we only need to determine the direction
            % direction
            phi = 2 * pi * rand(1);
            
            rp = rand(1);
            xi = 2 * sqrt(Ei * Ef) / (Ei + Ef - 2 * sqrt(Ei * Ef));
            cosTheta = 1 + 1 / xi - (1 + 2 * xi)^rp / xi;
            sinTheta = sqrt(1 - cosTheta^2);
            % Theta is the angle between \vec{k}_i and \vec{q}, not the angle between \vec{k}_i and \vec{k}_f
            
            % momentum ( under the relative frame )
            kf = obj.kFactor * sqrt(Ef); % unit : 1 / nm
            kzf = kf * cosTheta;
            kxyf = kf * sinTheta * [cos(phi); sin(phi)]; % in-plane % not kf * sinTheta !!!
            kfVec = [kxyf; kzf];
            
            %% transform from relative frame to lab frame
            kfVec = rotMatOld * kfVec;

            % update cosTheta, sinTheta, and phi
            cosTheta = kfVec(3) / kf;
            sinTheta = sqrt(1 - cosTheta^2);
            finalKxy = sqrt(kfVec(1)^2 + kfVec(2)^2);
            cosphi = kfVec(1) / finalKxy;
            sinphi = kfVec(2) / finalKxy;
    
            % update rotation matrix
            rotPhi = [cosphi, -sinphi, 0; sinphi, cosphi, 0; 0, 0, 1];
            rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
            rotMatNew = rotPhi * rotTheta;
        end
    
        function [Ef, kf, kfVec, rotMatNew] = sampling_POP_EMS_old(obj, Ei, ki, rotMatOld)
            % the first thing is to update energy
            Ef = Ei + obj.dEList(3);
            
            % the second thing is to update momentum : since the energy is update, we only need to determine the direction
            phi = 2 * pi * rand(1);
            
            rp = rand(1);
            s = obj.omega0 / Ei;
            x1 = 1 + sqrt(1-s);
            cosTheta = 1 / 2 * s^(1/2) * (x1^(rp)*s^(-rp/2) + x1^(-rp)*s^(rp/2));
            sinTheta = sqrt(1 - cosTheta^2);
            
            % get the momentum of phonon firstly, but it can have two possible solutions
            if rand(1) < 0.5
                qOp = + ki * cosTheta + ki * cosTheta * sqrt(1 - s / cosTheta^2); % unit : 1 / nm 
            else
                qOp = + ki * cosTheta - ki * cosTheta * sqrt(1 - s / cosTheta^2); % unit : 1 / nm 
            end
            
            % momentum ( under the relative frame )
            kf = sqrt(ki^2 + qOp^2 + 2 * ki * qOp * cosTheta); % unit : 1 / nm
            kzf = ki - qOp * cosTheta;
            kxyf = - qOp * sinTheta * [cos(phi); sin(phi)]; % in-plane % not kf * sinTheta !!!
            kfVec = [kxyf; kzf];

            %% transform from relative frame to lab frame
            kfVec = rotMatOld * kfVec;

            % update cosTheta, sinTheta, and phi
            cosTheta = kfVec(3) / kf;
            sinTheta = sqrt(1 - cosTheta^2);
            finalKxy = sqrt(kfVec(1)^2 + kfVec(2)^2);
            cosphi = kfVec(1) / finalKxy;
            sinphi = kfVec(2) / finalKxy;
    
            % update rotation matrix
            rotPhi = [cosphi, -sinphi, 0; sinphi, cosphi, 0; 0, 0, 1];
            rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
            rotMatNew = rotPhi * rotTheta;
        end
        
        function [Ef, kf, kfVec, rotMatNew] = sampling_POP_EMS(obj, Ei, rotMatOld)
            % the first thing is to update energy
            Ef = Ei + obj.dEList(3);
            
            % the second thing is to update momentum : since the energy is update, we only need to determine the direction
            phi = 2 * pi * rand(1);
            
            rp = rand(1);
            xi = 2 * sqrt(Ei * Ef) / (Ei + Ef - 2 * sqrt(Ei * Ef));
            cosTheta = 1 + (1 / xi) - (1 + 2 * xi)^rp / xi;
            sinTheta = sqrt(1 - cosTheta^2);
            
            % momentum ( under the relative frame )
            kf = obj.kFactor * sqrt(Ef); % unit : 1 / nm
            kzf = kf * cosTheta;
            kxyf = kf * sinTheta * [cos(phi); sin(phi)]; % in-plane % not kf * sinTheta !!!
            kfVec = [kxyf; kzf];

            %% transform from relative frame to lab frame
            kfVec = rotMatOld * kfVec;

            % update cosTheta, sinTheta, and phi
            cosTheta = kfVec(3) / kf;
            sinTheta = sqrt(1 - cosTheta^2);
            finalKxy = sqrt(kfVec(1)^2 + kfVec(2)^2);
            cosphi = kfVec(1) / finalKxy;
            sinphi = kfVec(2) / finalKxy;
    
            % update rotation matrix
            rotPhi = [cosphi, -sinphi, 0; sinphi, cosphi, 0; 0, 0, 1];
            rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
            rotMatNew = rotPhi * rotTheta;
        end
        
        function [Ef, kf, kfVec, rotMat] = sampling_ADP(~, Ei, ki)
            % update energy
            Ef = Ei;
            
            % update momentum : since the energy is update, we only need to determine the direction
            phi = 2 * pi * rand(1);
            cosTheta = 1 - 2 * rand(1);
            sinTheta = sqrt(1 - cosTheta^2);
            
            kf = ki; % unit : 1 / nm
            kfVec = kf * [sinTheta * [cos(phi); sin(phi)]; cosTheta];
            % momentum don't need to be rotated back to lab frame
    
            % update rotation matrix
            rotPhi = [cos(phi), -sin(phi), 0; sin(phi), cos(phi), 0; 0, 0, 1];
            rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
            rotMat = rotPhi * rotTheta;
        end
    end

    %% update
    methods
        function [initE, initK, initKVec, initVel, rotMat] = initialize_state(obj)
            % energy sampling
            eneAvg = 3 / 2 * obj.thermalEne; % average thermal energy 3/2k_BT, unit : eV
            initE = - eneAvg * log(rand(1)); % unit : eV
            
            % angle sampling ( isotropic )
            phi = 2 * pi * rand(1);
            cosTheta = 1 - 2 * rand(1);
            sinTheta = sqrt(1 - cosTheta^2);
            
            % momentum
            initK = obj.kFactor * sqrt(initE); % assume the electron starts from Gamma valley, unit : 1 / nm
            initKVec = initK * [sinTheta * [cos(phi); sin(phi)]; cosTheta];
            
            % velocity
            initVel = obj.hbar * initKVec * 10^9 / (obj.eMass * obj.meff);

            % rotation matrix
            rotPhi = [cos(phi), -sin(phi), 0; sin(phi), cos(phi), 0; 0, 0, 1];
            rotTheta = [1, 0, 0; 0, cosTheta, sinTheta; 0, -sinTheta, cosTheta];
            rotMat = rotPhi * rotTheta;
        end

        function [midKVec, midK, midE, midVel] = update_state_by_drift(obj, Ez, initKVec, deltaTime)
            % update momentum kz after a flight
            midKVec = initKVec;
            midKVec(3) = midKVec(3) - (obj.eCharge * Ez / obj.hbar) * deltaTime; % unit : 1 / nm
            midK = sqrt(sum(midKVec.^2)); % unit : 1 / nm
            
            % update energy after a flight
            midE = obj.EkFactor * midK^2; % unit : eV
            
            % update velocity after a flight
            midVel = obj.hbar * midKVec * 10^9 / (obj.eMass * obj.meff);

            % vzt = - (midE - initE) / (Ez * 10^9); % unit : m
            % vxy = obj.hbar * midKxy * 10^9 / (obj.eMass * obj.mteff); % unit : m
        end
        
        
    end
end

