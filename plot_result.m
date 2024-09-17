function plot_result(result,name)
nexttile(1)
errorbar(1:numel(result.load),[result.load.median], ...
    [result.load.median]-[result.load.min], ...
    [result.load.median]-[result.load.max], ...
    "DisplayName",name);
hold on
grid on
set(gca,"XTick",1:numel(result.load),"XTickLabel",[result.load.benchmark],"TickLabelInterpreter","none");
title("Load")
ylabel("Time [s]")

nexttile(2)
errorbar(1:numel(result.dump),[result.dump.median], ...
    [result.dump.median]-[result.dump.min], ...
    [result.dump.median]-[result.dump.max], ...
    "DisplayName",name);
hold on
grid on
set(gca,"XTick",1:numel(result.dump),"XTickLabel",[result.dump.benchmark],"TickLabelInterpreter","none");
title("Dump")
ylabel("Time [s]")
legend("show",Location="northwest",Interpreter="none")

end