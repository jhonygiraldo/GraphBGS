clear all, close all, clc;
load('results_2/error_random.mat');
m = [10:10:400];
line_sample = linspace(0,0.25);
sample_complexity = 59*ones(1,length(line_sample));
%%
line_width = 1.5;
marker_size = 6;
font_size = 27.5;
width = 680;
heigth = 290;
%% Classification error
figure();
errorbar(m,mean(error_random),std(error_random),'LineWidth',line_width,'MarkerSize',marker_size);
hold on;
plot(sample_complexity,line_sample,'LineWidth',line_width,'MarkerSize',marker_size);
ylabel('Error','Interpreter','Latex');
xlabel('Sample size','Interpreter','Latex');
ylim([0 0.25]);
%title('Classification Error','Interpreter','Latex');
%%
lgd = legend({'Classification error','Sample complexity'},'Location','northeast');
set(lgd,'Interpreter','latex');
set(lgd,'color','none');
set(lgd,'Box','off');
%%
get(gca);
set(gca,'FontName','times','FontSize',font_size,'TickLabelInterpreter','Latex');
set(gcf,'Position',[100,100,width,heigth]);
saveas(gcf,['results_2/classification_error.svg']);