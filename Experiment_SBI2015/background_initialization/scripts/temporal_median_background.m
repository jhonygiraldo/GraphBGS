clear all, close all, clc;
%% Setting of paths
path_to_dataset = '/home/jhonygiraldoz/SBI_dataset/';
background_init_algorithm = 'median_filter';
%%
folders_categories = {'Board';'Candela_m1.10';'CAVIAR1';'CAVIAR2';'CaVignal';...
    'Foliage';'HallAndMonitor';'HighwayI';'HighwayII';'HumanBody2';'IBMtest2';...
    'PeopleAndFoliage';'Snellen';'Toscana'};
path_to_results = [pwd,'/../',background_init_algorithm,'/'];
mkdir(path_to_results);
for h=1:size(folders_categories,1)
    disp(['Computing background of sequence: ',folders_categories{h}]);
    path_raw_imgs = [path_to_dataset,folders_categories{h},'/input/'];
    list_img_path = dir(path_raw_imgs);
    image_i = imread([path_raw_imgs list_img_path(3).name]);
    [x y z] = size(image_i);
    whole_video = uint8(zeros(length(list_img_path)-2,x*y,'int8'));
    for i=1:length(list_img_path)-2
        image_i = imread([path_raw_imgs list_img_path(i+2).name]);
        image_i = rgb2gray(image_i);
        whole_video(i,:) = reshape(image_i,[1,x*y]);
    end
    background_image = median(whole_video);
    background_image = reshape(background_image,[x y]);
    imwrite(uint8(background_image),[path_to_results,...
        folders_categories{h},'_background.png']);
end