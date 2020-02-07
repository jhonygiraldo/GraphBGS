clear all, close all, clc;
load('../graph_construction/k-NN-k-30-R_50_FPN_COCO-median_filter/full_graph.mat');
W = G.W;
N = size(W,1);
x = label_bin(:,1:2);
[~,f_x] = max(x,[],2);
%%
repetitions = 200;
m = [10:10:400];
%%
param.regularize_epsilon = 0.2;
error_random = zeros(repetitions,length(m));
for(p=1:size(m,2))
    p/size(m,2)
    %%
    random_pattern = zeros(repetitions,N);
    for(h=1:repetitions)
        amount_intial_nodes = m(p); % Minority nodes
        initial_binary_pattern = zeros(N,1);
        white_noise_pattern = normrnd(1,0.5,[N,1]);
        white_noise_orderer = sort(white_noise_pattern,'descend');
        white_noise_orderer = white_noise_orderer(1:amount_intial_nodes);
        for(i=1:amount_intial_nodes)
            initial_binary_pattern(find(white_noise_pattern == white_noise_orderer(i))) = 1;
        end
        random_pattern(h,:) = initial_binary_pattern;
    end
    %%
    for(h=1:repetitions)
        M_random = zeros(m(p),N);
        %%
        ind_M_random = 1;
        for(j=1:N)
            if(random_pattern(h,j))
                M_random(ind_M_random,j) = 1;
                ind_M_random = ind_M_random + 1;
            end
        end
        %%
        x_sampled_random = M_random*x;
        %%
        sampled_nodes = find(sum(M_random) == 1);
        non_sampled_nodes = find(sum(M_random) == 0);
        x_reconstructed_random = gsp_interpolate(G, x_sampled_random,...
            sampled_nodes, param);
        [~,f_recon_random] = max(x_reconstructed_random,[],2);
        %%
        error_random(h,p) = sum(f_recon_random(non_sampled_nodes)~=f_x(non_sampled_nodes))/(length(non_sampled_nodes));
    end
end
%%
mkdir('results_2/');
save('results_2/error_random.mat','error_random');