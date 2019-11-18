clear all, close all, clc;
%% Setting of paths
path_to_change_detection = '/home/jhonygiraldoz/changedetection_dataset/'; % Change this line with your path to the change detection database
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
%%
folder_challenges = {'badWeather';'baseline';'cameraJitter';'dynamicBackground';...
    'intermittentObjectMotion';'lowFramerate';'nightVideos';'PTZ';'shadow';...
    'thermal';'turbulence'};
%%
for h=1:length(folder_challenges)
    disp(['Computing the graph signal of challenge ',folder_challenges{h}]);
    label_bin = [];
    path_to_features = [pwd,'/../../nodes_representation/',segmentation_algorithm,...
        '-',background_inti_algorithm,'/',folder_challenges{h},'/'];
    path_to_sequences = [path_to_change_detection,folder_challenges{h},'/',...
        folder_challenges{h},'/'];
    folders_sequences = dir(path_to_sequences);
    for i=1:size(folders_sequences,1)-2
        disp(['Sequence: ',folders_sequences(i+2).name]);
        %% 
        load([path_to_features,'list_of_images_',folders_sequences(i+2).name,'.mat']);
        %% 
        path_to_category = [path_to_sequences,folders_sequences(i+2).name,'/'];
        file_txt_ID = fopen([path_to_category,'temporalROI.txt'],'r');
        range_eval = fscanf(file_txt_ID,'%f');
        path_to_ground_truth = [path_to_category,'groundtruth/'];
        path_to_nodes = [pwd,'/../../isolated_nodes/',segmentation_algorithm,...
            '/',folder_challenges{h},'/',folders_sequences(i+2).name,'/'];
        %% ROI
        ROI = logical(imread([path_to_category,'ROI.bmp']));
        for j=1:size(list_of_images,1)
            number_image = list_of_images{j};
            indx_n = strfind(number_image,'n');
            indx_point = strfind(number_image,'.');
            number_image = number_image(indx_n+1:indx_point-1);
            if str2num(number_image) < range_eval(1) || str2num(number_image) > range_eval(2)
                label_bin = [label_bin; 0 0 1];
            else
                %% Read isolated node
                load([path_to_nodes,num2str(j),'.mat']);
                node_image = full(logical_sparse_mat);
                IoNode_ROI = sum(sum(node_image & ~ROI))/(sum(sum(node_image))); %Intersection over Node with ROI
                if IoNode_ROI == 1
                    label_bin = [label_bin; 0 0 1]; % This is to be sure that any node outside the ROI is incorrectly classified
                else
                    gt_image_temp = imread([path_to_ground_truth,'gt',number_image,'.png']);
                    [x_gt y_gt] = size(gt_image_temp);
                    gt_image = zeros(x_gt,y_gt);
                    gt_image(find(gt_image_temp == 255)) = 1; % We are going to process just the foreground region
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
        end
    end
    save([pwd,'/../graph_signals/graph_signal_',folder_challenges{h},'.mat'],'label_bin','folders_sequences'); % We need the file folders sequences to now the order of the nodes
end
