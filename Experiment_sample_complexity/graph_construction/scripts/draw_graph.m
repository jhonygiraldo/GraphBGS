clear all, close all, clc;
load('../k-NN-k-30-R_50_FPN_COCO-median_filter/full_graph.mat');
%%
N = G.N;
%%
figure();
p = plot(graph(G.W));
% xlim([-6.2 3.65]);
% ylim([-4.7 4.8]);
%xlim([-4.2 6.6]);
%ylim([-6.1 4.8]);
set(gca,'LooseInset',get(gca,'TightInset'));
%%
cmap = colormap(colorcube);
color_matrix = zeros(N,3);
color_edges = repmat([192,192,192]/255,[G.Ne,1]);
p.EdgeColor = color_edges;
%%
marker_size_vector = 2*ones(N,1);
p.MarkerSize = marker_size_vector;
%%
color_matrix = zeros(N,3);
for(i=1:size(label_bin,1))
    if label_bin(i,1) == 1
        color_matrix(i,:) = [0,0,1]; %Static objects red
    elseif label_bin(i,2) == 1
        color_matrix(i,:) = [0,1,0]; %Moving objects green
    else
        color_matrix(i,:) = [0,0,0];
    end
end
p.NodeColor = color_matrix;
axis off