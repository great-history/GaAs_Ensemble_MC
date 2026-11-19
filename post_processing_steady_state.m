%% load data
folderPath = 'data_saved_for_problem3';
files = dir(fullfile(folderPath, '*.mat'));

eneAvg = 3 / 2 * (1.380649 * 10^(-23)) * 300 / (1.60217663 * 10^(-19));
% store velocity of steady state
steadyVelEzList = [0;0;0];
steadyPopEzList = [1;0;0];
steadyEneEzList = [eneAvg];
EzList = [0];

%% load data to extract steady behaviour
for i = 1:length(files)
    fileName = fullfile(folderPath, files(i).name);
    % tokens = regexp(fileName, '(\d{8}_\d{6})', 'tokens');
    % if ~isempty(tokens)
    %     fileDateTime = tokens{1}{1};
    % 
    %     if ~strcmp(fileDateTime, currentDateTime)
    %         continue
    %     end
    % end

    load(fileName);  % 加载 .mat 文件
    
    EzList = [EzList, Ez];
    %% steady state properties
    index1 = find(timeList > 10, 1, 'first'); % after 10 ps, the ensemble assumed to be in the steady state
    % if exist('steadyEne', 'var')
    %     steadyEneEzList = [steadyEneEzList, steadyEne];
    % else
    % 
    % end
    
    steadyEne = mean(avgEneList(:, index1:end), 2);
    steadyEneEzList = [steadyEneEzList, steadyEne];
    % disp(["the steady energy is ", steadyEne, " eV "])

    if exist('steadyVel', 'var')
        steadyVelEzList = [steadyVelEzList, steadyVel];
    else
        warning('文件 %s 中没有 steadyVel 变量', files(i).name);
        steadyVel = mean(avgVelList(:, index1:end), 2);
        steadyVelEzList = [steadyVelEzList, steadyVel];
    end

    if exist('steadyPopList', 'var')
        steadyPopEzList = [steadyPopEzList, steadyPopList];
    else
        warning('文件 %s 中没有 steadyVel 变量', files(i).name);
        steadyPopList = mean(avgOccValleyList(:, index1:end), 2);
        steadyPopEzList = [steadyPopEzList, steadyPopList];
    end
end
EzList = EzList * 10000; % unit : kV/cm

%% re-order
[EzList, idx] = sort(EzList);
steadyVelEzList = steadyVelEzList(:,idx);
steadyPopEzList = steadyPopEzList(:,idx);
steadyEneEzList = steadyEneEzList(:,idx);

%% linear fit to extract out the low-field mobility
% 1. choose the low-field regime（for example, Ez < 0.2e-3 V/nm）
idx_fit = EzList < 5; % unit : kV/cm
Ez_fit = EzList(idx_fit) * 1e+3; % unit : V/cm
vel_fit = steadyVelEzList(3,idx_fit) * 10^2; % unit : cm/s

% 2. linear fit : velocity (cm/s) = slope * electric field (V / cm) + something
% the unit of the slope is cm^2 / (V*s)
p = polyfit(Ez_fit, vel_fit, 1);


%% plot steady velocity and occupation of each valley
enePlot = figure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 画布(figure)和坐标轴(axes)的尺寸设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf, 'unit', 'inch', 'position', [3, 3, 13, 5]) % figure
% set(gca, 'Position', [0.1, 0.1, 0.90, 0.90]) % axess
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的方向
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

subplot(1,3,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('Ez (kV/cm)', 'FontSize', 13, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 13, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axis([0 timeList(end) 0, 0.2])
hold on
line_width = 1;

% steady state's velocity as a function of electric field Ez
for direction = 1:3
    plot(EzList, squeeze(-steadyVelEzList(direction, :)), 'LineWidth', line_width, 'LineStyle', '-');
end

% plot(timeList, avgEneList, 'LineWidth', line_width, 'LineStyle', '-');

title('$<\vec{v}>$ at Different Electric Field', 'Interpreter', 'latex', 'FontSize', 12);
legend('$v_x$', '$v_y$', '$v_z$', 'Location', 'best','Interpreter', 'latex');  % 添加图注
set(gca, 'Position', [0.08 0.15 0.25 0.75]);  % [left bottom width height]

subplot(1,3,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('Ez (kV/cm)', 'FontSize', 13, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('Occupation', 'FontSize', 13, 'FontWeight', 'normal', 'FontName', 'Arial')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 EzList(end) 0, 1.1])
hold on
line_width = 1;

% steady averaged occupation at each valley
for valleyIdx = 1:3
    plot(EzList, steadyPopEzList(valleyIdx, :), 'LineWidth', line_width, 'LineStyle', '-');
end
title('$<N_{v}>$ at Different Electric Field', 'Interpreter', 'latex', 'FontSize', 12);
legend('G', 'L', 'X', 'Location', 'best');  % 添加图注
set(gca, 'Position', [0.38 0.15 0.25 0.75]);

subplot(1,3,3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('Ez (kV/cm)', 'FontSize', 13, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('E (eV)', 'FontSize', 13, 'FontWeight', 'normal', 'FontName', 'Arial')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axis([0 EzList(end) 0, 2.0])
hold on
line_width = 1;

% steady energy averaged over the whole ensemble and all three valleys
plot(EzList, steadyEneEzList, 'LineWidth', line_width, 'LineStyle', '-');
title('$<E>$ at Different Electric Field', 'Interpreter', 'latex', 'FontSize', 12);
set(gca, 'Position', [0.68 0.15 0.25 0.75]);

%% 导出图形为PDF，尺寸适应图形
% 指定目标文件夹路径（根据实际情况修改）
folderPath = '.\figures_saved_for_problem4';
% 构建完整的文件名（日期+时间）
fileName = [currentDateTime '_vel_pop_ene_Ez.pdf'];
% 构建完整的文件路径
fullFilePath = fullfile(folderPath, fileName);
exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');