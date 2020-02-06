% This code needs the GSP toolbox, this code constructs a graph 
% G2 with k2 using as base another graph G1 with k1, such that k1>k2
clear all, close all, clc;
%% Setting of paths
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
knn_param = 10;
construction_algorithm = ['k-NN-k-',num2str(knn_param)];
path_to_construction = [pwd,'/../',construction_algorithm,'-',segmentation_algorithm,...
    '-',background_inti_algorithm,'/'];
mkdir(path_to_construction);
%%
load('../k-NN-k-40-R_50_FPN_COCO-median_filter/full_graph.mat'); % load graph G1
clear G
%%
N = size(points,1);
Idx = Idx(:,1:knn_param+1);
Dist = Dist(:,1:knn_param+1);
sigma = mean(mean(Dist));
W = spalloc(N,N,(2*N*knn_param));
for i=1:N
    i/N
    W(i,Idx(i,2:end)) = exp(-(Dist(i,2:end).^2)./(sigma^2));
    W(Idx(i,2:end),i) = W(i,Idx(i,2:end));
end
%%
G.N = N;
G.W = W;
G.coords = points;
G.type = 'nearest neighbors';
G.sigma = sigma;
G = gsp_graph_default_parameters(G);
G = gsp_estimate_lmax(G);
save([path_to_construction,'full_graph.mat'],'G','label_bin','points','Idx','Dist');
