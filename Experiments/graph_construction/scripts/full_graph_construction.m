% This code needs the GSP toolbox
clear all, close all, clc;
%% Setting of paths
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
construction_algorithm = 'k-NN';
%%
folder_challenges = {'badWeather';'baseline';'cameraJitter';'dynamicBackground';...
    'intermittentObjectMotion';'lowFramerate';'nightVideos';'PTZ';'shadow';...
    'thermal';'turbulence'};
%%
points = []; % all features
label_bin = []; % all graph signals
for i=1:length(folder_challenges)
    graph_signals = load([pwd,'/../graph_signals/graph_signal_',folder_challenges{i},'.mat']);
    label_bin = [label_bin; graph_signals.label_bin];
    for j=1:length(graph_signals.folders_sequences)-2
        features = load([pwd,'/../../nodes_representation/',segmentation_algorithm,...
            '-',background_inti_algorithm,'/',folder_challenges{i},'/features_',...
            graph_signals.folders_sequences(j+2).name,'.mat']);
        points = [points; features.features];
    end
end
%%
N = size(points,1);
knn_param = 10;
[Idx Dist] = knnsearch(points,points,'K',knn_param+1);
sigma = mean(mean(Dist));
W = sparse(N,N);
for i=1:N
    for j=2:knn_param+1
        W(i,Idx(i,j)) = exp(-(Dist(i,j)^2)/(sigma^2));
        W(Idx(i,j),i) = W(i,Idx(i,j));
    end
end
%%
G.N = N;
G.W = W;
G.coords = points;
G.type = 'nearest neighbors';
G.sigma = sigma;
G = gsp_graph_default_parameters(G);
G = gsp_estimate_lmax(G);
save([pwd,'/../',construction_algorithm,'/full_graph.mat'],'G','label_bin','points','Idx','Dist');
