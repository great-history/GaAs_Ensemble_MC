%% parallel
poolobj = gcp('nocreate');
if isempty(poolobj)
    cluster = parcluster('local');
    maxWorkers = cluster.NumWorkers;
    parpool(cluster, maxWorkers);
    disp(["start the parallel, the number of workers ：", maxWorkers]);

    % Perform a basic check by entering this code, where "local" is one kind of cluster profile.
    % parpool('local', 6);
else
    disp(['并行运算已启动，核心数：' num2str(poolobj.NumWorkers)]);
end
% delete(gcp('nocreate'));

%% 模板文件路径（原始文件）
fileName1 = 'test_Nparticle_3valley_part1.m';
fileName2 = 'test_Nparticle_3valley_part5.m';
fileName3 = 'post_processing.m';

Ez_list = [14, 15, 0.5, 1, 1.5, 2.5, 3, 3.5, 4.5]; % for problem 2, use [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
% avgVelEzList = zeros(3, 3, length(Ez_list));
% avgEneEzList = zeros(3, length(Ez_list));

tic
currentDateTime = datestr(now, 'yyyymmdd_HHMMSS');
for i = 1:length(Ez_list)
    Ez = Ez_list(i);

    % 读取模板文件
    txt = fileread(fileName1);
    
    % 替换 Ez 的那一行（你用正则表达式替换）
    newLine = sprintf('Ez = %.1f * 10^3 * 10^(-7);', Ez);
    txt = regexprep(txt, 'Ez\s*=\s*.*?;', newLine);  % 用正则替换 Ez = ... 这一行

    % % 生成临时文件
    % tempFile = sprintf('temp_Ez_%d.m', i);

    % 直接覆盖原始文件
    fid = fopen(fileName1, 'w');
    fwrite(fid, txt);
    fclose(fid);
    
    % 运行临时文件
    run(fileName1);
    run(fileName2);
    run(fileName3)
end
toc

%% plot
% valleyIndex = 1;
% 
% % time resolved
% % figure
% % plot(velFlyDiary_mean(:,valleyIndex,1), 'b')
% 
% % average
% % mink(squeeze(velParticle(3,1,:)), 10)
% figure
% plot(squeeze(avgVelEzList(3,valleyIndex,:)), 'b')
% % histogram(squeeze(velParticle(3,1,:)), 50)