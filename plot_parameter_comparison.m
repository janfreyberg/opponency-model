function plot_parameter_comparison(model)

if ~isfield(model, 'wta')
    error('There is no WTA-Index in results');
end

conditions = size(model.wta, 2);
plotarray{1} = model.wta;
xlabelarray{1} = 'Winner-Take-All Index';
plotvar = 1;
yrangearray{plotvar} = [0 1];

if isfield(model, 'mixdur')
    plot_mixdur = 1;
    plotvar = plotvar + 1;
    plotarray{plotvar} = model.mixdur;
    xlabelarray{plotvar} = 'Mixed Durations';
    yrangearray{plotvar} = [0 3];
else
    plot_mixdur = 0;
end
if isfield(model, 'domdur')
    plot_domdur = 1;
    plotvar = plotvar + 1;
    plotarray{plotvar} = model.domdur;
    xlabelarray{plotvar} = 'Dominant Durations';
    yrangearray{plotvar} = [0 3];
else
    plot_domdur = 0;
end
if isfield(model, 'switches')
    plot_switches = 1;
    plotvar = plotvar + 1;
    plotarray{plotvar} = model.switches;
    xlabelarray{plotvar} = 'Switches';
    yrangearray{plotvar} = [0 10];
else
    plot_switches = 0;
end
if isfield(model, 'reverses')
    plot_reverses = 1;
    plotvar = plotvar + 1;
    plotarray{plotvar} = model.reverses;
    xlabelarray{plotvar} = 'Reversions';
    yrangearray{plotvar} = [0 10];
else
    plot_reverses = 0;
end

n_subplots = sum([1, plot_mixdur, plot_domdur, plot_switches, plot_reverses]);
fighandle = figure;

for plotvar = 1:n_subplots
    
    subplot(n_subplots, 1, plotvar);
    hold on;
    
    ylabelarray = cell(1, conditions);
    
    for cond = 1:conditions;
        barh(cond, mean(plotarray{plotvar}(:, cond), 1), 'FaceColor', 1-0.8*[cond/conditions, cond/conditions, cond/conditions]);
        ylabelarray{cond} = num2str(model.params(cond));
    end
    
    if plotvar == ceil(n_subplots/2)
        ylabel(model.ylabstring, 'FontSize', 16);
    end
    xlim(yrangearray{plotvar});
    xlabel(xlabelarray{plotvar}, 'FontSize', 16);
    set(gca,'YTick', 1:conditions, 'YLim', [0, conditions+1], 'XLim', yrangearray{plotvar}, 'XTick', linspace(yrangearray{plotvar}(1), yrangearray{plotvar}(2), 5), 'FontSize', 14)
    set(gca,'YTickLabel', ylabelarray);
    set(gca,'FontSize',14);
    
end