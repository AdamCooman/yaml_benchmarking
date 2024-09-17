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
    data = yaml.loadFile(filepath);
    % test loading
    handle = @()yaml.loadFile(filepath);
    stats = benchmark(handle,1,string(replace(file.name,".yaml","")));
    if ~isfield(results,"load")
        results.load = stats;
    else
        results.load(end+1) = stats;
    end
    % test dumping
    handle = @()yaml.dumpFile("temp.yaml",data);
    stats = benchmark(handle,0,string(replace(file.name,".yaml","")));
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
%%
f = figure(1);
f.Units = "pixels";
f.Position = [50 50 900 400];
clf
t = tiledlayout(f,1,2);
title(t,results.user+" "+string(results.time)+" "+results.commit);
nexttile()
errorbar(1:numel(results.load),[results.load.median], ...
    [results.load.median]-[results.load.min], ...
    [results.load.median]-[results.load.max],"b")
hold on
plot(1:numel(results.load),[results.load.times],'b.')
grid on
set(gca,"XTick",1:numel(results.load),"XTickLabel",[results.load.benchmark],"TickLabelInterpreter","none");
title("Load")
ylabel("Time [s]")

nexttile()
errorbar(1:numel(results.dump),[results.dump.median], ...
    [results.dump.median]-[results.dump.min], ...
    [results.dump.median]-[results.dump.max],"b")
hold on
plot(1:numel(results.dump),[results.dump.times],'b.')
grid on
set(gca,"XTick",1:numel(results.dump),"XTickLabel",[results.dump.benchmark],"TickLabelInterpreter","none");
title("Dump")
ylabel("Time [s]")

filename = string(results.time)+"_"+results.commit;
saveas(f,fullfile("results",filename+".svg"))
yaml.dumpFile(fullfile("results",filename+".yaml"),results);

function [stats,times] = benchmark(fun,number_of_outputs,name)
number_of_attempts = 100;
times = zeros(number_of_attempts,1);
for attempt = 1 : number_of_attempts
    if number_of_outputs == 0
        tic;
        fun();
        times(attempt) = toc;
    elseif number_of_outputs == 1
        tic;
        out = fun();%#ok
        times(attempt) = toc;
    else
        error("I only support up to one output")
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