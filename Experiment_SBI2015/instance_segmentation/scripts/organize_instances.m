clear all, close all, clc;
%%
path_to_dataset = '/home/jhonygiraldoz/SBMI_dataset/';
folder_category = 'SBMI_dataset/';
folders_categories = {'Board';'Candela_m1.10';'CAVIAR1';'CAVIAR2';'CaVignal';...
    'Foliage';'HallAndMonitor';'HighwayI';'HighwayII';'HumanBody2';'IBMtest2';...
    'PeopleAndFoliage';'Snellen';'Toscana'};
%% Create instances paths
for i=1:length(folders_categories)
    mkdir([path_to_dataset,folder_category,folder_category,'instances_',folders_categories{i}]);
end
instances_path = 'results_instances_SBMIDataset/';
list_instances = dir(instances_path);
for h=1:length(list_instances)-2
    name_instance = list_instances(h+2).name;
    load([instances_path name_instance]);
    indxs_script = strfind(name_instance,'_');
    category = name_instance(indxs_script(3)+1:indxs_script(4)-1);
    if strcmp(category,'Candela')
        category = 'Candela_m1.10';
    end
    image_name = name_instance(indxs_script(end)+1:end);
    save([path_to_dataset,folder_category,folder_category,'instances_',category,'/',image_name],...
        'masks','classes','boundig_boxes');
end