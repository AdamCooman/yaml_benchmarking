clear variables
close all
clc

addpath("yaml")

test_files = dir("files");
results = struct();
for file = test_files(:)'
    if file.isdir
        continue
    end
    disp("Running test: "+file.name)
    filepath = fullfile(file.folder,file.name);
    file_data = readlines(filepath);
    file_data = file_data.join(newline);
    % test loading
    handle = @()yaml.load(file_data);
    stats = benchmark(handle,1,string(replace(file.name,".yaml","")));
    if ~isfield(results,"load")
        results.load = stats;
    else
        results.load(end+1) = stats;
    end
    % test dumping
    data = yaml.loadFile(filepath);
    handle = @()yaml.dump(data);
    stats = benchmark(handle,1,string(replace(file.name,".yaml","")));
    if ~isfield(results,"dump")
        results.dump = stats;
    else
        results.dump(end+1) = stats;
    end
end

results.commit = get_yaml_git_commit();
results.user   = getenv('username');
results.time   = datetime();
results.time.Format = "uuuu-MM-dd";

f = figure(1);
f.Units = "pixels";
f.Position = [50 50 900 400];
clf
plot_result(results,"result")

filename = string(results.time)+"_"+results.commit;
saveas(f,fullfile("results",filename+".svg"))
yaml.dumpFile(fullfile("results",filename+".yaml"),results);

function [stats,times] = benchmark(fun,number_of_outputs,name)
% perfrom a few warmup runs
for attempt = 1 : 10
    if number_of_outputs == 0
        fun();
    else
        out = fun();%#ok
    end
end
% run the actual benchmarking runs
number_of_attempts = 100;
times = zeros(number_of_attempts,1);
for attempt = 1 : number_of_attempts
    if number_of_outputs == 0
        tic;
        fun();
        times(attempt) = toc;
    else
        tic;
        out = fun();%#ok
        times(attempt) = toc;
    end
end
% return the statistics
stats.times = times;
stats.mean = mean(times);
stats.std = std(times);
stats.median = median(times);
stats.min = min(times);
stats.max = max(times);
stats.benchmark = name;
end

function res=get_yaml_git_commit()
    old_dir = pwd();
    cd("yaml")
    [~,res] = system("git rev-parse HEAD");
    cd(old_dir)
    res = string(res);
    res = replace(res,newline,"");
end