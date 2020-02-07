% This code needs the GSP toolbox
clear all, close all, clc;
%% Setting of paths
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
construction_algorithm = 'k-NN-k-30';
path_to_construction = [pwd,'/../',construction_algorithm,'-',segmentation_algorithm,...
    '-',background_inti_algorithm,'/'];
mkdir(path_to_construction);
%%
folder_challenges_CDNet = {'baseline';'dynamicBackground';'shadow'};
folders_sequences_CDNet = {{'PETS2006';'highway';'office';'pedestrians'};...
    {'boats';'canoe';'fall';'fountain01';'fountain02';'overpass'};...
    {'backdoor';'bungalows';'busStation';'copyMachine';'cubicle';'peopleInShade'}};
path_to_challenges_CDNet = '/home/jhonygiraldoz/PAMI_2020/Experiments_vs_02/nodes_representation/R_50_FPN_COCO-median_filter/';
path_to_graph_signal_CDNet = '/home/jhonygiraldoz/PAMI_2020/Experiments_vs_02/graph_construction/graph_signal_R_50_FPN_COCO-median_filter/';
points_CDNet = [];
label_bin_CDNet = [];
for i=1:length(folder_challenges_CDNet)
    for j=1:size(folders_sequences_CDNet{i},1)
        load([path_to_challenges_CDNet,folder_challenges_CDNet{i},'/features_',...
            folders_sequences_CDNet{i}{j},'.mat']);
        points_CDNet = [points_CDNet;features];
    end
    sublabels = load([path_to_graph_signal_CDNet,folder_challenges_CDNet{i},'.mat']);
    label_bin_CDNet = [label_bin_CDNet;sublabels.label_bin];
end
%%
folders_sequences = {'Board';'Candela_m1.10';'CAVIAR1';'CAVIAR2';'CaVignal';...
    'Foliage';'HallAndMonitor';'HighwayI';'HighwayII';'HumanBody2';'IBMtest2';...
    'PeopleAndFoliage';'Snellen';'Toscana'};
%%
points = []; % all features
label_bin = []; % all graph signals
graph_signals = load([pwd,'/../graph_signal_',segmentation_algorithm,'-',...
    background_inti_algorithm,'/','SBI_graph_signal.mat']);
label_bin = [label_bin; graph_signals.label_bin];
for j=1:length(folders_sequences)
    features = load([pwd,'/../../nodes_representation/',segmentation_algorithm,...
        '-',background_inti_algorithm,'/','/features_',...
        folders_sequences{j},'.mat']);
    points = [points; features.features];
end
%%
points = [points_CDNet; points];
label_bin = [label_bin_CDNet; label_bin];
%%
N = size(points,1);
knn_param = 30;
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
save([path_to_construction,'full_graph.mat'],'G','label_bin','points','Idx','Dist');