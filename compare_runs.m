clear variables
close all
clc

files = [
    fullfile("results","demo_data.yaml")
    % add extra datasets here
];
names = [
    "master"
    % add extra names here
];

results = {};
for file = files(:)'
    results{1,end+1} = yaml.loadFile(file,"ConvertToArray",true);
end

f = figure(1);
f.Units = "pixels";
f.Position = [50 50 900 400];
clf
t = tiledlayout(f,1,2);
for ind = 1 : numel(results)
    plot_result(results{ind},names(ind));
end
