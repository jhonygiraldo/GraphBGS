clear all, close all, clc;
knn = load('../variational_splines-k-NN-k-30-R_50_FPN_COCO-median_filter/results_metrics.mat');
robust = load('../variational_splines-robust-R_50_FPN_COCO-median_filter/results_metrics.mat');
%%
figures_cvpr = [1:11];
challenges = {'badWeather';'baseline';'cameraJitter';'dynamicBackground';...
    'intermittentObjectMotion';'lowFramerate';'nightVideos';'PTZ';'shadow';...
    'thermal';'turbulence'};
line_width = 1.5;
marker_size = 6;
font_size = 20;
width = 680;
heigth = 290;
path_figures = 'figures_pami_exp_3/';
mkdir(path_figures);
%% Figure bad weather
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(1)}),std(knn.average_FMeasure{figures_cvpr(1)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(1)}),std(robust.average_FMeasure{figures_cvpr(1)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Bad Weather','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'bad_weather.svg']);
%% Figure baseline
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(2)}),std(knn.average_FMeasure{figures_cvpr(2)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(2)}),std(robust.average_FMeasure{figures_cvpr(2)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Baseline','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'baseline.svg']);
%% Figure camera jitter
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(3)}),std(knn.average_FMeasure{figures_cvpr(3)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(3)}),std(robust.average_FMeasure{figures_cvpr(3)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Camera Jitter','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'camera_jitter.svg']);
%% Figure dynamic background
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(4)}),std(knn.average_FMeasure{figures_cvpr(4)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(4)}),std(robust.average_FMeasure{figures_cvpr(4)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Dynamic Background','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'dynamic_background.svg']);
%% Figure intermittent object motion
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(5)}),std(knn.average_FMeasure{figures_cvpr(5)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(5)}),std(robust.average_FMeasure{figures_cvpr(5)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Intermittent Object Motion','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'io_motion.svg']);
%% Figure low frame rate
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(6)}),std(knn.average_FMeasure{figures_cvpr(6)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(6)}),std(robust.average_FMeasure{figures_cvpr(6)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Low Frame Rate','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'low_frame_rate.svg']);
%% Figure PTZ
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(8)}),std(knn.average_FMeasure{figures_cvpr(8)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(8)}),std(robust.average_FMeasure{figures_cvpr(8)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('PTZ','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'ptz.svg']);
%% Figure Shadow
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(9)}),std(knn.average_FMeasure{figures_cvpr(9)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(9)}),std(robust.average_FMeasure{figures_cvpr(9)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Shadow','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'shadow.svg']);
%% Figure Thermal
figure()
errorbar(knn.sampling_density,mean(knn.average_FMeasure{figures_cvpr(10)}),std(knn.average_FMeasure{figures_cvpr(10)}),...
    'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
errorbar(robust.sampling_density,mean(robust.average_FMeasure{figures_cvpr(10)}),std(robust.average_FMeasure{figures_cvpr(10)}),...
    'o--','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Average f-measure','Interpreter','Latex');
xlabel('Sampling density','Interpreter','Latex');
xlim([knn.sampling_density(1) 0.1]);
lgd = legend({'k-NN','Robust'},'Location','best');
lgd.NumColumns = 2;
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
title('Thermal','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,[path_figures 'thermal.svg']);
