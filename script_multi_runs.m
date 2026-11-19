%% parallel
poolobj = gcp('nocreate');
if isempty(poolobj)
    cluster = parcluster('local');
    maxWorkers = cluster.NumWorkers;
    parpool(cluster, maxWorkers);
    disp(["启动并行运算，核心数：", maxWorkers]);

    % Perform a basic check by entering this code, where "local" is one kind of cluster profile.
    % parpool('local', 6);
else
    disp(['并行运算已启动，核心数：' num2str(poolobj.NumWorkers)]);
end
delete(gcp('nocreate'));

%% 模板文件路径（原始文件）
fileName1 = 'test_Nparticle_3valley_part1.m';
fileName2 = 'test_Nparticle_3valley_part4.m';

Ez_list = [0.2, 0.5, 1, 2, 5, 8, 10];
avgVelEzList = zeros(3, 3, length(Ez_list));
avgEneEzList = zeros(3, length(Ez_list));

tic
for i = 1:length(Ez_list)
    Ez = Ez_list(i);

    % 读取模板文件
    txt = fileread(fileName1);
    
    % 替换 Ez 的那一行（你用正则表达式替换）
    newLine = sprintf('Ez = %.1f * 10^3 * 10^(-7); %% unit : V/nm', Ez);
    txt = regexprep(txt, 'Ez\s*=\s*.*?;', newLine);  % 用正则替换 Ez = ... 这一行

    % 生成临时文件
    tempFile = sprintf('temp_Ez_%d.m', i);

    fid = fopen(tempFile, 'w');
    fwrite(fid, txt);
    fclose(fid);
    
    % 运行临时文件
    run(tempFile);
    run(fileName2);
    
    % 
    veParticle_mean = squeeze(mean(velParticle, 3));
    eneParticle_mean = squeeze(mean(eneParticle, 2));
    avgVelEzList(:, :, i) = veParticle_mean;
    avgEneEzList(:, i) = eneParticle_mean;
end
toc

%% plot
valleyIndex = 1;

% time resolved
% figure
% plot(velFlyDiary_mean(:,valleyIndex,1), 'b')

% average
% mink(squeeze(velParticle(3,1,:)), 10)
figure
plot(squeeze(avgVelEzList(3,valleyIndex,:)), 'b')
% histogram(squeeze(velParticle(3,1,:)), 50)