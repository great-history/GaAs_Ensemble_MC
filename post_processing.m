%% post-processing
% average over valley or ensemble at each interruption
tic
% avgVelList = zeros(3,3,numINTR); % the first index is valley
% avgEneList = zeros(3,1,numINTR); % the first index is valley
countsValleyList = zeros(3, numINTR); % the first index is valley, to avoid denominator to be zero
for intrIdx = 1:numINTR
    for pIndex = 1:numParticle
        valleyIdx = trValleyNpList(1, intrIdx, pIndex);
        countsValleyList(valleyIdx, intrIdx) = countsValleyList(valleyIdx, intrIdx) + 1;
    end
end

% average over ensemble but not valley
avgOccValleyList = countsValleyList(:, :)/numParticle;
avgVelValleyList = squeeze(sum(trVelNpList, 4));
avgEneValleyList = squeeze(sum(trEneNpList, 4));

% average over valley and ensemble
avgVelList = squeeze(sum(avgVelValleyList, 1)) / numParticle;
avgEneList = squeeze(sum(avgEneValleyList, 1)) / numParticle;

% average over ensemble but not valley
for valleyIdx = 1:3
    % energy
    avgEneValleyList(valleyIdx, :) = avgEneValleyList(valleyIdx, :) ./ countsValleyList(valleyIdx,:);
    
    for direction = 1:3
        % velocity
        avgVelValleyList(valleyIdx, direction, :) = squeeze(avgVelValleyList(valleyIdx, direction, :)) ./ squeeze(countsValleyList(valleyIdx,:))';
    end
end

clear trValleyNpList trEneNpList

toc

% to get the occupations at each valley
% edges = 0.5:1:3.5;
% valleyCounts = histcounts(trValleyList, edges);

% steady state properties
timeList = (timeUnit) * (1:1:numINTR) * 10^(12); % in the unit of picosecond ( 10^(-12) )
index1 = find(timeList > 10, 1, 'first'); % after 10 ps, the ensemble assumed to be in the steady state
steadyVel = mean(avgVelList(:, index1:end), 2);
steadyPopList = mean(avgOccValleyList(:,index1:end), 2);

%% plot energy and occupation of each valley
if ~exist('currentDateTime', 'var')
    currentDateTime = datestr(now, 'yyyymmdd_HHMMSS');
end

enePlot = figure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 画布(figure)和坐标轴(axes)的尺寸设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf, 'unit', 'inch', 'position', [3, 3, 12, 7]) % figure
set(gca, 'Position', [0.2, 0.12, 0.70, 0.75]) % axess
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的方向
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

subplot(1,2,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('E (eV)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 timeList(end) 0, 0.2])
hold on
line_width = 1;

% time evolved averaged energy at each valley
for valleyIdx = 1:3
    plot(timeList, squeeze(avgEneValleyList(valleyIdx, :)), 'LineWidth', line_width, 'LineStyle', '-');
end

% plot(timeList, avgEneList, 'LineWidth', line_width, 'LineStyle', '-');

title(['E at each valley at Electric Field $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('G', 'L', 'X', 'Location', 'best');  % 添加图注

subplot(1,2,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('Occupation', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 timeList(end) 0, 1.1])
hold on
line_width = 1;

% time evolved averaged energy at each valley
for valleyIdx = 1:3
    plot(timeList, countsValleyList(valleyIdx, :) / numParticle, 'LineWidth', line_width, 'LineStyle', '-');
    % plot(timeList, avgOccValleyList(valleyIdx, :), 'LineWidth', line_width, 'LineStyle', '-');
end
title(['E at each valley at Electric Field $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('G', 'L', 'X', 'Location', 'best');  % 添加图注

% 导出图形为PDF，尺寸适应图形
% 指定目标文件夹路径（根据实际情况修改）
folderPath = '.\figures_saved_for_problem3';
% 构建完整的文件名（日期+时间）
fileName = [currentDateTime '_Ez_' num2str(Ez*10^7) 'V_cm_energy_pop.pdf'];
% 构建完整的文件路径
fullFilePath = fullfile(folderPath, fileName);
exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');


%% plot averaged velocity over the whole ensemble and all valleys
avgVelGvPlot = figure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 画布(figure)和坐标轴(axes)的尺寸设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf, 'unit', 'inch', 'position', [2, 3, 15, 3]) % figure
set(gca, 'Position', [0.12, 0.12, 0.95, 0.75]) % axess
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的方向
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

subplot(1,2,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 timeList(end) 0 3.75*10^5])
hold on
line_width = 1;

% time evolved averaged velocity at each valley
for direction = 1:3
    plot(timeList, squeeze(-(avgVelList(direction, :))), 'LineWidth', line_width, 'LineStyle', '-');
    % plot(timeList, squeeze(abs(avgGvVelList(direction, :))), 'LineWidth', line_width, 'LineStyle', '-');
end

title(['$\vec{v}$ averaged over both valleys and ensemble at $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('$v_x$', '$v_y$', '$v_z$', 'Location', 'best', 'Interpreter','latex');  % 添加图注

subplot(1,2,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 4.2 0 3.75*10^5])
hold on
line_width = 1;

% time evolved averaged velocity at each valley
for direction = 1:3
    plot(timeList(1:index1), squeeze(-(avgVelList(direction, 1:index1))), 'LineWidth', line_width, 'LineStyle', '-');
    % plot(timeList, squeeze(abs(avgGvVelList(direction, :))), 'LineWidth', line_width, 'LineStyle', '-');
end

title(['$\vec{v}$ averaged over both valleys and ensemble at $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('$v_x$', '$v_y$', '$v_z$', 'Location', 'best', 'Interpreter','latex');  % 添加图注

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 将坐标轴的框置于顶层
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'Layer', 'top')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 保存为pdf格式
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [currentDateTime '_Ez_' num2str(Ez*10^7) 'V_cm_velocity_avg_all.pdf'];
% 构建完整的文件路径
fullFilePath = fullfile(folderPath, fileName);
exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');
% close(avgVelGvPlot)

%% plot velocity of G valley
velGvPlot = figure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 画布(figure)和坐标轴(axes)的尺寸设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf, 'unit', 'inch', 'position', [2, 3, 15, 3]) % figure
set(gca, 'Position', [0.12, 0.12, 0.95, 0.75]) % axess
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的方向
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

subplot(1,2,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 timeList(end) 0 3.75*10^5])
hold on
line_width = 1;

% time evolved averaged velocity at each valley
for direction = 1:3
    plot(timeList, squeeze(-avgVelValleyList(1, direction, :)), 'LineWidth', line_width, 'LineStyle', '-');
end

title(['$\vec{v}$ at G valley at $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('$v_x$', '$v_y$', '$v_z$', 'Location', 'best', 'Interpreter','latex');  % 添加图注

subplot(1,2,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 4.2 0 3.75*10^5])
hold on
line_width = 1;

% time evolved averaged velocity at each valley
for direction = 1:3
    plot(timeList(1:index1), squeeze(-avgVelValleyList(1, direction, 1:index1)), 'LineWidth', line_width, 'LineStyle', '-');
end

title(['$\vec{v}$ at G valley at $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('$v_x$', '$v_y$', '$v_z$', 'Location', 'best', 'Interpreter','latex');  % 添加图注

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 将坐标轴的框置于顶层
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'Layer', 'top')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 保存为pdf格式
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileName = [currentDateTime '_Ez_' num2str(Ez*10^7) 'V_cm_velocity_Gv.pdf'];
% % 构建完整的文件路径
% fullFilePath = fullfile(folderPath, fileName);
% exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');
% close(velGvPlot)

%% plot velocity of L valley and X valley
velLXPlot = figure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 画布(figure)和坐标轴(axes)的尺寸设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf, 'unit', 'inch', 'position', [3, 3, 10, 3.5]) % figure
set(gca, 'Position', [0.2, 0.12, 0.70, 0.75]) % axess
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的方向
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

subplot(1,2,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 timeList(end) 0 6*10^4])
hold on
line_width = 1;

% time evolved averaged velocity at each valley
for direction = 1:3
    plot(timeList, squeeze(-avgVelValleyList(2, direction, :)), 'LineWidth', line_width, 'LineStyle', '-');
end

title(['$\vec{v}$ at L valley at $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('$v_x$', '$v_y$', '$v_z$', 'Location', 'best', 'Interpreter','latex');  % 添加图注

subplot(1,2,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴标签名字
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的范围
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis([0 timeList(end) 0 3*10^4])
hold on
line_width = 1;

% time evolved averaged velocity at each valley
for direction = 1:3
    plot(timeList, squeeze(-avgVelValleyList(3, direction, :)), 'LineWidth', line_width, 'LineStyle', '-');
end

title(['$\vec{v}$ at X valley at $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
legend('$v_x$', '$v_y$', '$v_z$', 'Location', 'best', 'Interpreter','latex');  % 添加图注

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 将坐标轴的框置于顶层
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'Layer', 'top')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 保存为pdf格式
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileName = [currentDateTime '_Ez_' num2str(Ez*10^7) 'V_cm_velocity_LX.pdf'];
% % 构建完整的文件路径
% fullFilePath = fullfile(folderPath, fileName);
% exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');
% close(velLXPlot)

%% save data
folderPath = '.\data_saved_for_problem3';
dataName = [currentDateTime '_Ez_' num2str(Ez*10^7) 'V_cm.mat'];
fullFilePath = fullfile(folderPath, dataName);
save(fullFilePath, ...
    'avgVelList', 'avgEneList', 'avgVelValleyList', 'avgEneValleyList', 'avgOccValleyList', 'countsValleyList', ...
    'currentDateTime',...
    'numParticle', 'Ez', 'intrTime', 'timeUnit', 'numINTR', 'steadyVel', 'steadyPopList', 'timeList', 'index1')