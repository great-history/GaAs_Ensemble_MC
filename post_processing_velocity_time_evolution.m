%% load data
folderPath = 'data_saved_for_problem3';
files = dir(fullfile(folderPath, '*.mat'));

% store time-evolution of the velocity at different EzList
steadyVelEzList = [];
steadyPopEzList = [];
steadyEneEzList = [];
EzList = [];

% selecEzList = [500, 1000, 2000, 5000, 8000, 10000, 12000, 15000];
selecEzList = [500, 1000, 2000, 5000, 8000, 10000, 12000, 15000];
%% set up plot
avgVelGvPlot = figure;
set(gcf, 'unit', 'inch', 'position', [2, 3, 9, 6]) % figure
set(gca, 'Position', [0.12, 0.12, 0.85, 0.75]) % axess
set(gca, 'XDir', 'normal')
set(gca, 'YDir', 'normal')

xlabel('time (ps)', 'FontSize', 12, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex');
ylabel('$v_i$ (m/s)', 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Arial', 'Interpreter','latex')
set(gca, 'XColor', 'k')
set(gca, 'YColor', 'k')

idxTime = find(timeList >= 5, 1, 'first');
hold on
line_width = 1;

legendEntries = {};
% cmap = parula(length(files));
cmap = jet(length(files));

% load data and plot
valleyIdx = 4;
for i = 1:length(files)
    fileName = fullfile(folderPath, files(i).name);
    tokens = regexp(fileName, '_Ez_(\d+)V_', 'tokens');
    if ~isempty(tokens)
        Ez_value_str = tokens{1}{1};
        Ez_value = str2double(Ez_value_str);
        if ~ismember(Ez_value , selecEzList)
            continue
        end
    else
        continue
    end

    load(fileName);  % 加载 .mat 文件
    
    % time evolved averaged velocity at each valley ( timeList's unit : ps )
    switch valleyIdx
        case 4 % whole ensemble
            plot(timeList(1:idxTime), squeeze(-(avgVelList(3, 1:idxTime))), 'LineWidth', line_width, ...
                    'LineStyle', '-', 'Color', cmap(end+1-i, :));
        otherwise % different valleys
            plot(timeList, squeeze(-(avgVelValleyList(valleyIdx, 3, :))), 'LineWidth', line_width, ...
                    'LineStyle', '-', 'Color', cmap(end+1-i, :));
            % for direction = 1:3
            %     plot(timeList, squeeze(-avgVelValleyList(2, direction, :)), 'LineWidth', line_width, 'LineStyle', '-');
            % end
    end
    
    % hold on
    legendEntries{end+1} = sprintf('E_z = %.2f kV/cm', Ez*10000);
end

% add a title
switch valleyIdx
    case 1 % Gamma
        title('$<v_z>$ at Gamma valley at different electric fields', 'Interpreter', 'latex', 'FontSize', 12);
        axis([0 30 0 5.5*10^5])
    case 2 % L
        title('$<v_z>$ at L valley at different electric fields', 'Interpreter', 'latex', 'FontSize', 12);
        axis([0 30 0 3*10^4])
    case 3 % X
        title('$<v_z>$ at X valley at different electric fields', 'Interpreter', 'latex', 'FontSize', 12);
        axis([0 30 0 3*10^4])
    case 4 % whole ensemble
        title('$<v_z>$ whole ensemble at different electric fields', 'Interpreter', 'latex', 'FontSize', 12);
        axis([0 5 0 5.5*10^5])
end
legend(legendEntries, 'Location', 'bestoutside');

%% 导出图形为PDF，尺寸适应图形
if ~exist('currentDateTime', 'var')
    currentDateTime = datestr(now, 'yyyymmdd_HHMMSS');
end
folderPath = '.\figures_saved_for_problem3';
fileName = [currentDateTime '_vel_time_all_curves_valley0', num2str(valleyIdx), '.pdf'];
fullFilePath = fullfile(folderPath, fileName);
exportgraphics(gcf, fullFilePath, 'ContentType', 'vector', 'BackgroundColor','none');