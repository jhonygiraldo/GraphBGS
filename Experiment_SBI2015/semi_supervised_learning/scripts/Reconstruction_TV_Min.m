clear all, close all, clc;
%% Setting of paths
path_to_change_detection = '/home/jhonygiraldoz/changedetection_dataset/'; % Change this line with your path to the change detection database
segmentation_algorithm = 'R_50_FPN_COCO';
background_inti_algorithm = 'median_filter';
construction_algorithm = 'k-NN-k-30';
semi_supervised_learning = 'TV';
path_to_results = [pwd,'/../',semi_supervised_learning,'-',construction_algorithm,...
    '-',segmentation_algorithm,'-',background_inti_algorithm,'/'];
mkdir(path_to_results);
%%
load([pwd,'/../../graph_construction/',construction_algorithm,'-',...
    segmentation_algorithm,'-',background_inti_algorithm,'/full_graph.mat']);
%%
clear Dist Idx points
%%
folder_challenges = {'baseline';'dynamicBackground';'shadow';'SBMI_dataset'};
folders_categories = {{'highway';'office';'pedestrians';'PETS2006'};...
    {'boats';'canoe';'fall';'fountain01';'fountain02';'overpass'};...
    {'backdoor';'bungalows';'busStation';'copyMachine';...
    'cubicle';'peopleInShade'};...
    {'Board';'Candela_m1.10';'CAVIAR1';'CAVIAR2';'CaVignal';...
    'Foliage';'HallAndMonitor';'HighwayI';'HighwayII';'HumanBody2';'IBMtest2';...
    'PeopleAndFoliage';'Snellen';'Toscana'}};
%%
x = label_bin;
x(:,3) = [];
%%
percentage_sampling = [0.001,0.005,0.01,0.02:0.02:0.2];
%%
list_raw_images = cell(size(folder_challenges,1),1);
list_of_images_cell = cell(size(folder_challenges,1),1);
indx_first_image_in_list = cell(size(folder_challenges,1),1);
for i=1:size(folder_challenges,1)
    list_raw_images_temp = cell(size(folders_categories{i},1),1);
    list_of_images_cell_temp = cell(size(folders_categories{i},1),1);
    indx_first_image_in_list_temp = zeros(size(folders_categories{i},1),1);
    for j=1:size(folders_categories{i,1},1)
        if strcmp(folder_challenges{i},'SBMI_dataset')
            folder_raw_images = ['/home/jhonygiraldoz/SBI_dataset/',...
                folders_categories{i}{j},'/input/'];
        else
            folder_raw_images = ['/home/jhonygiraldoz/changedetection_dataset/',folder_challenges{i},'/',...
                folder_challenges{i},'/',folders_categories{i}{j},'/input/'];
        end
        list_raw_images_temp{j} = dir(folder_raw_images);
        %%
        if strcmp(folder_challenges{i},'SBMI_dataset')
            indx_first_image_in_list_temp(j) = 2;
            list_of_images_cell_temp{j} = load(['/home/jhonygiraldoz/SBMI_dataset/',folder_challenges{i},'/features_extraction/list_of_images_',...
                folders_categories{i}{j},'.mat']);
        else
            path_to_category = ['/home/jhonygiraldoz/changedetection_dataset/',folder_challenges{i},'/',...
                folder_challenges{i},'/',folders_categories{i}{j},'/'];
            file_txt_ID = fopen([path_to_category,'temporalROI.txt'],'r');
            range_eval = fscanf(file_txt_ID,'%f');
            indx_first_image_in_list_temp(j) = range_eval(1) + 2;
            list_of_images_cell_temp{j} = load(['/home/jhonygiraldoz/PAMI_2020/Experiments_vs_02/nodes_representation/R_50_FPN_COCO-median_filter/',folder_challenges{i},'/list_of_images_',...
                folders_categories{i}{j},'.mat']);
        end
    end
    list_raw_images{i} = list_raw_images_temp;
    list_of_images_cell{i} = list_of_images_cell_temp;
    indx_first_image_in_list{i} = indx_first_image_in_list_temp;
end
%%
epsilon_set_pesenson = [0];
%%
repetitions = 5;
param.maxit = 200;
for i=1:length(epsilon_set_pesenson)
    i
    param.regularize_epsilon = epsilon_set_pesenson(i);
    for j=1:length(percentage_sampling)
        for k=1:repetitions
            indentifier_category_in_nodes = [];
            random_sampling_pattern = [];
            cont_y = 1;
            for kk=1:size(folder_challenges)
                results_path = [path_to_results,...
                    'sampling_percentage_',num2str(percentage_sampling(j)),'_epsilon_',num2str(epsilon_set_pesenson(i)),...
                    '_repet_',num2str(k),'/',folder_challenges{kk},'/'];
                mkdir(results_path);
                for y=1:size(folders_categories{kk},1)
                    %%
                    result_path_category = [results_path,folders_categories{kk}{y}];
                    %if strcmp(folders_categories{kk}{y},'Candela_m1.10')
                    %    rmdir(result_path_category,'s');
                    %end
                    mkdir(result_path_category);
                    %%
                    if strcmp(folder_challenges{kk},'SBMI_dataset')
                        path_to_category = ['/home/jhonygiraldoz/SBMI_dataset/',folder_challenges{kk},'/',...
                            folder_challenges{kk},'/',folders_categories{kk}{y},'/'];
                        number_images = length(dir([path_to_category,'input']))-2;
                        number_sampling_images = round(number_images*percentage_sampling(j));
                        images_per_category = number_images;
                    else
                        path_to_category = ['/home/jhonygiraldoz/changedetection_dataset/',folder_challenges{kk},'/',...
                        folder_challenges{kk},'/',folders_categories{kk}{y},'/'];
                        file_txt_ID = fopen([path_to_category,'temporalROI.txt'],'r');
                        range_eval = fscanf(file_txt_ID,'%f');
                        number_sampling_images = round(range_eval(2)*percentage_sampling(j));
                        images_per_category = range_eval(2)-range_eval(1);
                    end
                    %%
                    selected_images_indx = randperm(images_per_category,number_sampling_images);
                    selected_images_indx = selected_images_indx + indx_first_image_in_list{kk}(y);
                    indx_selected_image_in_node = zeros(length(list_of_images_cell{kk}{y}.list_of_images),1);
                    for h=1:length(selected_images_indx)
                        selected_image = list_raw_images{kk}{y}(selected_images_indx(h)).name;
                        indx_point = strfind(selected_image,'.');
                        selected_image(indx_point(end):end) = [];
                        selected_image = [selected_image,'.jpg'];
                        indx_selected_image_in_node = [indx_selected_image_in_node | ...
                            strcmp(list_of_images_cell{kk}{y}.list_of_images,selected_image)];
                    end
                    if strcmp(folder_challenges{kk},'SBMI_dataset')
                        sampling_pattern_in_category = zeros(length(indx_selected_image_in_node),1);
                    else
                        sampling_pattern_in_category = indx_selected_image_in_node;
                    end
                    random_sampling_pattern = [random_sampling_pattern;...
                        sampling_pattern_in_category];
                    indentifier_category_in_nodes = [indentifier_category_in_nodes;...
                        cont_y*ones(length(sampling_pattern_in_category),1)];
                    cont_y = cont_y + 1;
                end
            end
            S_opt_random = logical(random_sampling_pattern);
            %% Check any node has is unknown, i.e., label_bin = 0 0 1
            for h=1:length(S_opt_random)
                if S_opt_random(h) == 1 && label_bin(h,3) == 1
                    S_opt_random(h) = 0;
                end
            end
            x_sampled_random = S_opt_random.*x;
            %%
            x_reconstructed_random = gsp_regression_tv(G,S_opt_random,...
                        full(x_sampled_random),epsilon_set_pesenson(i),param);
            %x_reconstructed_random = gsp_interpolate(G, x_sampled_random,...
            %    find(random_sampling_pattern == 1),param);
            [~,f_recon_random] = max(x_reconstructed_random,[],2); % predicted class labels
            %%
            cont_h = 1;
            for kk=1:size(folder_challenges)
                results_path = [path_to_results,...
                    'sampling_percentage_',num2str(percentage_sampling(j)),'_epsilon_',num2str(epsilon_set_pesenson(i)),...
                    '_repet_',num2str(k),'/',folder_challenges{kk},'/'];
                for h=1:size(folders_categories{kk},1)
                    if strcmp(folder_challenges{kk},'SBMI_dataset')
                        nodes_path_category = ['/home/jhonygiraldoz/SBMI_dataset/',folder_challenges{kk},'/results/',...
                            folders_categories{kk}{h},'_nodes/'];
                    else
                        nodes_path_category = ['/home/jhonygiraldoz/changedetection_dataset/',folder_challenges{kk},'/results/',...
                            folders_categories{kk}{h},'_nodes/'];
                    end
                    result_path_category = [results_path,folders_categories{kk}{h},'/'];
                    indx_category_in_nodes = find(indentifier_category_in_nodes == cont_h);
                    cont_h = cont_h + 1;
                    if strcmp(folder_challenges{kk},'SBMI_dataset')
                        for z=1:length(indx_category_in_nodes)
                            original_image = list_of_images_cell{kk}{h}.list_of_images(z);
                            indx_point = strfind(original_image{1},'.');
                            original_image = [original_image{1}(1:indx_point(end)-1) '.png'];
                            if exist([result_path_category,original_image]) == 0
                                node_image = imread([nodes_path_category,num2str(z),'.bmp']);
                                image_black = zeros(size(node_image));
                                imwrite(image_black,[result_path_category,original_image]);
                            end
                            if f_recon_random(indx_category_in_nodes(z)) == 2 % Foreground
                                node_image = imread([nodes_path_category,num2str(z),'.bmp']);
                                if exist([result_path_category,original_image]) == 2
                                    old_node_image = imread([result_path_category,original_image]);
                                    new_node_image = old_node_image | node_image;
                                    imwrite(new_node_image,[result_path_category,original_image]);
                                else
                                    imwrite(node_image,[result_path_category,original_image]);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end