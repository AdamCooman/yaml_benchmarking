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

figure(1)
clf
subplot(121)
errorbar(1:numel(results.load),[results.load.median], ...
    [results.load.median]-[results.load.min], ...
    [results.load.median]-[results.load.max],"b")
hold on
plot(1:numel(results.load),[results.load.times],'b.')
grid on
set(gca,"XTick",1:numel(results.load),"XTickLabel",[results.load.benchmark],"TickLabelInterpreter","none");
title("Load")
ylabel("Time [s]")

subplot(122)
errorbar(1:numel(results.dump),[results.dump.median], ...
    [results.dump.median]-[results.dump.min], ...
    [results.dump.median]-[results.dump.max],"b")
hold on
plot(1:numel(results.dump),[results.dump.times],'b.')
grid on
set(gca,"XTick",1:numel(results.dump),"XTickLabel",[results.dump.benchmark],"TickLabelInterpreter","none");
title("Dump")
ylabel("Time [s]")

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
