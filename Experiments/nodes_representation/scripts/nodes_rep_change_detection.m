clear all, close all, clc;
%% Setting of paths
path_to_change_detection = '/home/jhonygiraldoz/changedetection_dataset/'; % Change this line with your path to the change detection database
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
path_to_nodes_representation = [pwd,'/../',segmentation_algorithm,'-',...
    background_inti_algorithm,'/'];
%%
folder_challenges = {'badWeather';'baseline';'cameraJitter';'dynamicBackground';...
    'intermittentObjectMotion';'lowFramerate';'nightVideos';'PTZ';'shadow';...
    'thermal';'turbulence'};
%% Likely static objects from the COCO 2017 dataset
statics_objects = {'traffic light','fire hydrant',...
    'stop sign','parking meter','bench','chair','couch','potted plant','bed',...
    'dining table','toilet','tv','microwave','oven','toaster','sink','refrigerator',...
    'clock','vase'};
%% Load COCO instances.mat
load([pwd,'/../../COCO_instaces/COCO_instances.mat']);
%% Generate mask of COCO instances for static objects
COCO_instances = COCO_instances';
indx_static_objects = zeros(length(COCO_instances),1);
for i=1:length(statics_objects)
    indx_static_objects = indx_static_objects | strcmp(COCO_instances,statics_objects{i});
end
%% Erosion of mask
se = strel('disk',4);
%% Features extraction
for hh=1:size(folder_challenges,1)
    disp(['Computing the nodes representantion of challenge ',folder_challenges{hh}]);
    path_to_sequences = [path_to_change_detection,folder_challenges{hh},'/',...
        folder_challenges{hh},'/'];
    folders_sequences = dir(path_to_sequences);
    for h=1:size(folders_sequences,1)-2
        disp(['Sequence: ',folders_sequences(h+2).name]);
        path_to_instances = [pwd,'/../../instance_segmentation/',segmentation_algorithm,...
            '/',folder_challenges{hh},'/instances_',folders_sequences(h+2).name,'/'];
        path_to_raw_imgs = [path_to_sequences,folders_sequences(h+2).name,'/input/'];
        list_img_path = dir(path_to_raw_imgs);
        %% Path to isolated nodes (before segment_results)
        path_to_isolated_nodes = [pwd,'/../../isolated_nodes/',segmentation_algorithm,...
            '/',folder_challenges{hh},'/',folders_sequences(h+2).name,'/'];
        mkdir(path_to_isolated_nodes);
        %%
        features = [];
        cont = 1;
        %%
        list_of_images = {};
        %% Background image
        background_image = imread([pwd,'/../../background_initialization/',...
            background_inti_algorithm,'/',folder_challenges{hh},'/',folders_sequences(h+2).name,...
            '_background.png']);
        %% ROI image
        img_ROI = imread([path_to_sequences,folders_sequences(h+2).name,'/ROI.bmp']);
        %% Opticalflow objects
        opticFlow = opticalFlowLK('NoiseThreshold',0.009);
        for i=1:length(list_img_path)-2
            %% current image
            current_img_path = list_img_path(i+2).name;
            ind_point_current = strfind(current_img_path,'.');
            current_img_path(ind_point_current:end) = [];
            %% Read current raw image, and current instances
            load([path_to_instances,current_img_path,'.mat']);
            current_raw_image = imread([path_to_raw_imgs,current_img_path,'.jpg']);
            current_raw_image = rgb2gray(current_raw_image);
            %% Optical flow previous frame
            flow = estimateFlow(opticFlow,current_raw_image);
            %% Optical flow background image
            opticFlow_background = opticalFlowLK('NoiseThreshold',0.009,'NumFrames',2);
            flow_background = estimateFlow(opticFlow_background,background_image);
            flow_background = estimateFlow(opticFlow_background,current_raw_image);
            %% Instances
            [n_instances x y] = size(masks);
            for j=1:n_instances
                mask_seg = masks(j,:,:);
                mask_seg = reshape(mask_seg,[x,y]);
                indx_static_objects(classes(j)+1);
                IoNode = sum(sum(mask_seg & ~img_ROI))/(sum(sum(mask_seg))); %Intersection over Node with the logical not ROI
                if ~indx_static_objects(classes(j)+1) && IoNode < 1
                    indexs_segment = find(mask_seg == 1);
                    % Structural features
                    struc_features = regionprops(mask_seg,'Eccentricity','EulerNumber',...
                        'Extent','Orientation','Solidity','BoundingBox');
                    bounding_box = boundig_boxes(j,:);
                    if bounding_box(3)-bounding_box(1) >= 3 && bounding_box(4)-bounding_box(2) >= 3 ...
                            && sum(sum(mask_seg))/(x*round(y/2)) > 0.001 % size filter 0.001 lower bound
                        mask_seg_eroded = imerode(mask_seg,se);
                        indxes_segment_eroded = find(mask_seg_eroded == 1);
                        %% Write image
                        mask_seg = mask_seg & img_ROI; % If we let the entire mask, this is going to be confussing for the graph signal construction algorithm.
                        logical_sparse_mat = sparse(logical(mask_seg));
                        save([path_to_isolated_nodes,num2str(cont),'.mat'],'logical_sparse_mat');
                        %%
                        if isempty(indxes_segment_eroded)
                            Vx = 0;
                            Vy = 0;
                            Orientation = 0;
                            Magnitude = 0;
                        else
                            Vx = flow.Vx(indxes_segment_eroded);
                            Vy = flow.Vy(indxes_segment_eroded);
                            Orientation = flow.Orientation(indxes_segment_eroded);
                            Magnitude = flow.Magnitude(indxes_segment_eroded);
                        end
                        %% Histograms flow
                        bins_orientation = 50;
                        hist_orientation = histcounts(Orientation,linspace(-pi,pi,bins_orientation),'Normalization','probability');
                        hist_vx = histcounts(Vx,linspace(-30,30,bins_orientation),'Normalization','probability');
                        hist_vy = histcounts(Vy,linspace(-30,30,bins_orientation),'Normalization','probability');
                        bins_magnitude = 200;
                        hist_magnitude = histcounts(Magnitude,linspace(0,30,bins_magnitude),'Normalization','probability');
                        % Texture features
                        xMin = round(bounding_box(1))+1;
                        yMin = round(bounding_box(2))+1;
                        xMax = round(bounding_box(3));
                        yMax = round(bounding_box(4));
                        image_box = current_raw_image(yMin:yMax,xMin:xMax);
                        %% For Color Features, maybe histograms of each channel
                        color_features = histcounts(current_raw_image(indexs_segment),[0:2:255],'Normalization','probability');
                        %%
                        Vx_background = flow_background.Vx(indexs_segment);
                        Vy_background = flow_background.Vy(indexs_segment);
                        Orientation_background = flow_background.Orientation(indexs_segment);
                        Magnitude_background = flow_background.Magnitude(indexs_segment);
                        %%
                        hist_orientationB = histcounts(Orientation_background,linspace(-pi,pi,bins_orientation),'Normalization','probability');
                        hist_vxB = histcounts(Vx_background,linspace(-30,30,bins_orientation),'Normalization','probability');
                        hist_vyB = histcounts(Vy_background,linspace(-30,30,bins_orientation),'Normalization','probability');
                        hist_magnitudeB = histcounts(Magnitude_background,linspace(0,30,bins_magnitude),'Normalization','probability');
                        %%
                        features(cont,:) = [max(Magnitude) mean(Magnitude) range(Magnitude) std(Magnitude) mad(Magnitude),...
                            min(Vx) max(Vx) mean(Vx) range(Vx) std(Vx) mad(Vx),...
                            min(Vy) max(Vy) mean(Vy) range(Vy) std(Vy) mad(Vy),...
                            min(Orientation) max(Orientation) mean(Orientation) range(Orientation) std(Orientation) mad(Orientation),...
                            max(Magnitude_background) mean(Magnitude_background) range(Magnitude_background) std(Magnitude_background) mad(Magnitude_background),...
                            min(Vx_background) max(Vx_background) mean(Vx_background) range(Vx_background) std(Vx_background) mad(Vx_background),...
                            min(Vy_background) max(Vy_background) mean(Vy_background) range(Vy_background) std(Vy_background) mad(Vy_background),...
                            min(Orientation_background) max(Orientation_background) mean(Orientation_background) range(Orientation_background) std(Orientation_background) mad(Orientation_background),...
                            length(indexs_segment)/(x*round(y/2)), struc_features(1).Eccentricity,...
                            struc_features(1).EulerNumber, struc_features(1).Extent, struc_features(1).Orientation,...
                            struc_features(1).Solidity, extractLBPFeatures(image_box), color_features,...
                            hist_magnitude hist_orientation hist_vx hist_vy,...
                            hist_orientationB hist_vxB hist_vyB hist_magnitudeB];
                        %%
                        list_of_images{cont,1} = list_img_path(i+2).name;
                        cont = cont + 1;
                    end
                end
            end
        end
        save([path_to_nodes_representation,folder_challenges{hh},...
            '/list_of_images_',folders_sequences(h+2).name,'.mat'],'list_of_images');
        save([path_to_nodes_representation,folder_challenges{hh},...
            '/features_',folders_sequences(h+2).name,'.mat'],'features');
    end
end
