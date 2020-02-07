clear all, close all, clc;
%% Setting of paths
path_to_dataset = '/home/jhonygiraldoz/SBI_dataset'; % Change this line with your path to the change detection database
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
path_to_graph_signal = [pwd,'/../graph_signal_',segmentation_algorithm,...
    '-',background_inti_algorithm,'/'];
mkdir(path_to_graph_signal);
%%
folders_sequences = {'Board';'Candela_m1.10';'CAVIAR1';'CAVIAR2';'CaVignal';...
    'Foliage';'HallAndMonitor';'HighwayI';'HighwayII';'HumanBody2';'IBMtest2';...
    'PeopleAndFoliage';'Snellen';'Toscana'};
%%
label_bin = [];
path_to_features = [pwd,'/../../nodes_representation/',segmentation_algorithm,...
    '-',background_inti_algorithm,'/'];
path_to_sequences = [path_to_dataset,'/'];
for i=1:size(folders_sequences,1)
    disp(['Sequence: ',folders_sequences{i}]);
    %%
    load([path_to_features,'list_of_images_',folders_sequences{i},'.mat']);
    %%
    path_to_category = [path_to_sequences,folders_sequences{i},'/'];
    path_to_ground_truth = [path_to_category,'groundtruth/'];
    path_to_nodes = [pwd,'/../../isolated_nodes/',segmentation_algorithm,...
        '/',folders_sequences{i},'/'];
    %% ROI
    for j=1:size(list_of_images,1)
        number_image = list_of_images{j};
        indx_n = strfind(number_image,'n');
        indx_underscore = strfind(number_image,'_');
        indx_point = strfind(number_image,'.');
        if ~isempty(indx_underscore)
            number_image = number_image(indx_underscore(end)+1:indx_point(end)-1);
        else
            number_image = number_image(indx_n+1:indx_point-1);
        end
        %% Read isolated node
        load([path_to_nodes,num2str(j),'.mat']);
        node_image = full(logical_sparse_mat);
        gt_image_temp = imread([path_to_ground_truth,'gt',number_image,'.png']);
        [x_gt y_gt] = size(gt_image_temp);
        gt_image = zeros(x_gt,y_gt);
        gt_image(find(gt_image_temp == 255)) = 1;
        [L_gt,n_gt] = bwlabel(gt_image);
        all_IoU = zeros(n_gt,1);
        for k=1:n_gt
            gt_image_k = logical(zeros(x_gt,y_gt));
            gt_image_k(find(L_gt == k)) = 1;
            all_IoU(k) = jaccard(node_image,gt_image_k); % Vector of intersection over union
        end
        IoNode = sum(sum(node_image & gt_image))/(sum(sum(node_image))); % Intersection over node
        if ~isempty(all_IoU)
            if (max(all_IoU) > 0.02) && ...
                    ((IoNode > 0.9) || (max(all_IoU) > 0.05 && IoNode > 0.45) || (max(all_IoU) > 0.25)) % Foreground
                label_bin = [label_bin; 0 1 0];
            else %Background
                label_bin = [label_bin; 1 0 0];
            end
        else % Background
            label_bin = [label_bin; 1 0 0];
        end
    end
end
save([path_to_graph_signal,'SBI_graph_signal.mat'],'label_bin');