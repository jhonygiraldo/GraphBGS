% This code needs the GSP toolbox and unlock toolbox
clear all, close all, clc;
%% Setting of paths
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
construction_algorithm = 'k-NN-k-40';
robust_algorithm = 'robust';
mkdir([pwd,'/../',robust_algorithm,'-',segmentation_algorithm,'-',background_inti_algorithm,'/']);
%%
load([pwd,'/../',construction_algorithm,'-',segmentation_algorithm,...
    '-',background_inti_algorithm,'/full_graph.mat']);
clear G;
%%
N = size(points,1);
k = 29;
Idx = Idx(:,1:k+2);
Dist = Dist(:,1:k+2);
%%
indx = reshape(Idx',[],1);
indy = repmat(Idx(:,1),[1,size(Idx,2)]);
indy = reshape(indy',[],1);
%%
dist = reshape(Dist',[],1);
Z_sp = sparse(round(indx),round(indy),dist.^2,N,N,size(Idx,2)*N*2);
Z_sp = gsp_symmetrize(Z_sp,'full');
%%
Dist = Dist(:,2:end).^2;
Dist_is_sorted = true;
theta = gsp_compute_graph_learning_theta(Dist,k,0,Dist_is_sorted);
params.edge_mask = Z_sp > 0;
params.fix_zeros = 1;
W = gsp_learn_graph_log_degrees(Z_sp*theta,1,1,params);
G.N = N;
G.W = W;
G.coords = points;
G.type = 'robust';
G = gsp_graph_default_parameters(G);
G = gsp_estimate_lmax(G);
save([pwd,'/../',robust_algorithm,'-',segmentation_algorithm,'-',background_inti_algorithm,'/full_graph.mat'],'G','label_bin');