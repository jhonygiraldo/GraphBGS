clear all, close all, clc;
%% Setting of paths
path_to_dataset = '/home/jhonygiraldoz/SBI_dataset'; % Change this line with your path to the change detection database
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
path_to_nodes_representation = [pwd,'/../',segmentation_algorithm,'-',...
    background_inti_algorithm,'/'];
mkdir(path_to_nodes_representation);
%%
folders_sequences = {'Board';'Candela_m1.10';'CAVIAR1';'CAVIAR2';'CaVignal';...
    'Foliage';'HallAndMonitor';'HighwayI';'HighwayII';'HumanBody2';'IBMtest2';...
    'PeopleAndFoliage';'Snellen';'Toscana'};
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
path_to_sequences = [path_to_dataset,'/'];
for h=1:size(folders_sequences,1)
    disp(['Sequence: ',folders_sequences{h}]);
    path_to_instances = [pwd,'/../../instance_segmentation/',segmentation_algorithm,...
        '/',folders_sequences{h},'/'];
    path_to_raw_imgs = [path_to_sequences,folders_sequences{h},'/input/'];
    list_img_path = dir(path_to_raw_imgs);
    %% Path to isolated nodes (before segment_results)
    path_to_isolated_nodes = [pwd,'/../../isolated_nodes/',segmentation_algorithm,...
        '/',folders_sequences{h},'/'];
    mkdir(path_to_isolated_nodes);
    %%
    features = [];
    cont = 1;
    %%
    list_of_images = {};
    %% Background image
    background_image = imread([pwd,'/../../background_initialization/',...
        background_inti_algorithm,'/',folders_sequences{h},...
        '_background.png']);
    %% Opticalflow objects
    opticFlow = opticalFlowLK('NoiseThreshold',0.009);
    for i=1:length(list_img_path)-2
        %% current image
        current_img_path = list_img_path(i+2).name;
        ind_point_current = strfind(current_img_path,'.');
        ind_underscore_current = strfind(current_img_path,'_');
        %% Read current raw image, and current instances
        if ~isempty(ind_underscore_current)
            load([path_to_instances,current_img_path(ind_underscore_current(end)+1:ind_point_current(end)),'mat']);
        else
            load([path_to_instances,current_img_path(1:ind_point_current(end)),'mat']);
        end
        current_raw_image = imread([path_to_raw_imgs,current_img_path]);
        %% Previous image
        if i==1
            previous_img_path = list_img_path(i+2).name;
        else
            previous_img_path = list_img_path(i+1).name;
        end
        %% Read previous raw image, and previous instances
        previous_raw_image = imread([path_to_raw_imgs,previous_img_path]);
        %%
        current_raw_image = rgb2gray(current_raw_image);
        previous_raw_image = rgb2gray(previous_raw_image);
        %% Optical flow previous frame
        flow = estimateFlow(opticFlow,current_raw_image);
        %% Instances
        [n_instances x y] = size(masks);
        for j=1:n_instances
            mask_seg = masks(j,:,:);
            mask_seg = reshape(mask_seg,[x,y]);
            indx_static_objects(classes(j)+1);
            if ~indx_static_objects(classes(j)+1)
                indexs_segment = find(mask_seg == 1);
                bounding_box = boundig_boxes(j,:);
                if bounding_box(3)-bounding_box(1) >= 3 && bounding_box(4)-bounding_box(2) >= 3 ...
                        && sum(sum(mask_seg))/(x*round(y/2)) > 0.001 % size filter 0.001 lower bound
                    mask_seg_eroded = imerode(mask_seg,se);
                    indxes_segment_eroded = find(mask_seg_eroded == 1);
                    %% Write image
                    logical_sparse_mat = sparse(logical(mask_seg));
                    save([path_to_isolated_nodes,num2str(cont),'.mat'],'logical_sparse_mat');
                    %%
                    if isempty(indxes_segment_eroded)
                        Orientation = 0;
                        Magnitude = 0;
                    else
                        Orientation = flow.Orientation(indxes_segment_eroded);
                        Magnitude = flow.Magnitude(indxes_segment_eroded);
                    end
                    %% Histograms flow
                    bins_orientation = 50;
                    hist_orientation = histcounts(Orientation,linspace(-pi,pi,bins_orientation),'Normalization', 'probability');
                    bins_magnitude = 50;
                    hist_magnitude = histcounts(Magnitude,linspace(0,30,bins_magnitude),'Normalization', 'probability');
                    % Texture features
                    xMin = round(bounding_box(1))+1;
                    yMin = round(bounding_box(2))+1;
                    xMax = round(bounding_box(3));
                    yMax = round(bounding_box(4));
                    current_image_box = current_raw_image(yMin:yMax,xMin:xMax);
                    previous_image_box = previous_raw_image(yMin:yMax,xMin:xMax);
                    back_image_box = background_image(yMin:yMax,xMin:xMax);
                    difference_current_back_box = uint8(abs(double(current_image_box)-double(back_image_box)));
                    %% For Intensity Features
                    current_intensity_features = histcounts(current_raw_image(indexs_segment),[0:2:255],'Normalization', 'probability');
                    previous_intensity_features = histcounts(previous_raw_image(indexs_segment),[0:2:255],'Normalization', 'probability');
                    background_intensity_features = histcounts(background_image(indexs_segment),[0:2:255],'Normalization', 'probability');
                    difference_intensity_features = histcounts(abs(double(current_raw_image(indexs_segment))-double(background_image(indexs_segment))),...
                        [0:2:255],'Normalization', 'probability');
                    %%
                    current_LBP_features = extractLBPFeatures(current_image_box);
                    previous_LBP_features = extractLBPFeatures(previous_image_box);
                    background_LBP_features = extractLBPFeatures(back_image_box);
                    difference_LBP_features = extractLBPFeatures(difference_current_back_box);
                    %%
                    features(cont,:) = [max(Magnitude) mean(Magnitude) range(Magnitude) std(Magnitude) mad(Magnitude),...
                        min(Orientation) max(Orientation) mean(Orientation) range(Orientation) std(Orientation) mad(Orientation),...
                        hist_orientation, hist_magnitude,...
                        current_LBP_features, previous_LBP_features, background_LBP_features, difference_LBP_features,...
                        current_intensity_features, previous_intensity_features, background_intensity_features, difference_intensity_features];
                    %%
                    list_of_images{cont,1} = list_img_path(i+2).name;
                    cont = cont + 1;
                end
            end
        end
    end
    save([path_to_nodes_representation,...
        '/list_of_images_',folders_sequences{h},'.mat'],'list_of_images');
    save([path_to_nodes_representation,...
        '/features_',folders_sequences{h},'.mat'],'features');
end