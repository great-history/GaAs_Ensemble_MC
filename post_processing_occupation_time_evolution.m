%% load data
folderPath = 'data_saved_for_problem3';
files = dir(fullfile(folderPath, '*.mat'));

% store time-evolution of the velocity at different EzList
steadyVelEzList = [];
steadyPopEzList = [];
steadyEneEzList = [];
EzList = [];

%% set up plot

% load data and plot
valleyIdx = 4;
for i = 1:length(files)
    fileName = fullfile(folderPath, files(i).name);

    load(fileName);  % 加载 .mat 文件
    idxTime = find(timeList >= 15, 1, 'first');
    
    occupPlot = figure;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 画布(figure)和坐标轴(axes)的尺寸设置
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gcf, 'unit', 'inch', 'position', [2, 2, 12, 7]) % figure
    set(gca, 'Position', [0.2, 0.12, 0.70, 0.75]) % axess
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%　坐标轴的方向
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gca, 'XDir', 'normal')
    set(gca, 'YDir', 'normal')
    xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
    ylabel('$<N_v>$', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
    set(gca, 'XColor', 'k')
    set(gca, 'YColor', 'k')

    % time evolved averaged velocity at each valley ( timeList's unit : ps )
    axis([0 20 0, 1.1])
    hold on
    line_width = 1;

    % time evolved averaged energy at each valley
    for valleyIdx = 1:3
        plot(timeList, countsValleyList(valleyIdx, :) / numParticle, 'LineWidth', line_width, 'LineStyle', '-');
        hold on
        % plot(timeList, avgOccValleyList(valleyIdx, :), 'LineWidth', line_width, 'LineStyle', '-');
    end
    title(['$<N_v>$ at each valley at Electric Field $E_z$ =', num2str(Ez*10^7), 'V/cm'], 'Interpreter', 'latex', 'FontSize', 12);
    legend('G', 'L', 'X', 'Location', 'best');  % 添加图注
    
    %% 导出图形为PDF，尺寸适应图形
    if ~exist('currentDateTime', 'var')
        currentDateTime = datestr(now, 'yyyymmdd_HHMMSS');
    end
    % 导出图形为PDF，尺寸适应图形
    % 指定目标文件夹路径（根据实际情况修改）
    savedPath = '.\figures_saved_for_problem3_occupation';
    % 构建完整的文件名（日期+时间）
    fileName = [currentDateTime '_Ez_' num2str(Ez*10^7) 'V_cm_energy_pop.pdf'];
    % 构建完整的文件路径
    fullFilePath = fullfile(savedPath, fileName);
    exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');
    close(occupPlot)
end