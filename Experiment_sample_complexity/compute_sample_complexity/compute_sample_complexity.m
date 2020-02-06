clear all, close all, clc;
load('../graph_construction/k-NN-k-30-R_50_FPN_COCO-median_filter/full_graph.mat');
cutoff_energy = 0.9;
x_hat = G.U'*label_bin(:,1:2);
x_hat = x_hat.^2;
total_energy = sum(x_hat);
cutoff_energy = total_energy*cutoff_energy;
x_hat_cum = cumsum(x_hat);
%%
rho_1 = max(find(x_hat_cum(:,1) <= cutoff_energy(1)));
rho_2 = max(find(x_hat_cum(:,2) <= cutoff_energy(2)));
sample_complexity = max(rho_1,rho_2)
%%
line_width = 1;
marker_size = 1.5;
font_size = 27.5;
width = 680;
heigth = 290;
%% Graph signal 1
figure();
stem(G.e,x_hat(:,1),'k','LineWidth',line_width,'MarkerSize',marker_size);
%stem(x_hat(:,1),'k','LineWidth',line_width,'MarkerSize',marker_size);
ylabel('$\mathbf{\hat{x}}_1^2(\rho)$','Interpreter','Latex');
xlabel('$\rho$','Interpreter','Latex');
ylim([0 3]);
xlim([0 80]);
%xlim([0 G.e(end)]);
%xlim([0 G.N]);
title('Power Spectrum','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
%% Graph signal 2
figure();
stem(G.e,x_hat(:,2),'LineWidth',line_width,'MarkerSize',marker_size);
ylabel('$\mathbf{\hat{y}}_2^2(\lambda)$','Interpreter','Latex');
xlabel('$\lambda$','Interpreter','Latex');
%%
lgd = legend({'Power Spectrum Foreground'},'Location','northeast');
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
%%
ylim([0 3]);
xlim([0 80]);
%title('Power Spectrum Moving Objects','Interpreter','Latex');
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
mkdir('results/');
saveas(gcf,['results/x_hat_moving_objects.svg']);