function [wta_list, mixdur, domdur, reverses, switches] = n_runModel_adaptation(p)

%Run this function.
%This function will loop through 3 conditions: Dichoptic gratings,
%monocular plaids, and binocular plaids
%The word 'layer' is used in the following sense:
%Layer 1 = Left monocular neurons
%Layer 2 = Right monocular neurons
%Layer 3 = Summation neurons
%Layer 4 = Left-Right opponency neurons
%Layer 5 = Right-Left opponency neurons
%A and B refer to the two stimulus orientations.
%
%If you use this code, please cite
%Said and Heeger (2013) A model of binocular rivalry and cross-orientation
%suppression. PLOS Computational Biology.

c = .5; %contrast
iA_amp_opts = [0 c]; %dichoptic grating, monocular plaid, binocular plaids
iB_amp_opts = [c 0]; %dichoptic grating, monocular plaid, binocular plaids

drawn_iter = 0;

taus = p.adaptationvars;

% preallocate
wta_list = zeros(p.niter, numel(taus));
mixdur = zeros(p.niter, numel(taus));
domdur = zeros(p.niter, numel(taus));
switches = zeros(p.niter, numel(taus));
reverses = zeros(p.niter, numel(taus));


fprintf('Iteration: 0\n'); % display progress at cmd
for iter = 1:p.niter
fprintf([repmat('\b', 1, 1+length(num2str(iter-1))), num2str(iter), '\n']); % update progress


%loop through conditions
for cond = 1:numel(taus);
    
    %Initializing time-courses for neuron (d)rives, (r)esponses, and (n)oise.
    %Each neuron is tuned to either orientation A or B.
    for lay=1:5 %go through maximum possible layers. This way, if there are <5 layers, the feedback can be zero.
        p.dA{lay}   = zeros(1,p.nt);
        p.dB{lay}   = zeros(1,p.nt);
        p.rA{lay}   = zeros(1,p.nt);
        p.rB{lay}   = zeros(1,p.nt);
        p.nA{lay}   = n_makeNoise(p);
        p.nB{lay}   = n_makeNoise(p);
    end

    p.tau = taus(cond);
    %stimulus inputs to monocular layers
    for lay = 1:2
        p.iA{lay} = iA_amp_opts(lay)*ones(1,p.nt);
        p.iB{lay} = iB_amp_opts(lay)*ones(1,p.nt);
    end
     
    %run the model
    p = n_model(p);
    
    %compute WTA index from summation layer
    wta_list(iter, cond) = nanmean(abs(p.rA{3}-p.rB{3})./(p.rA{3}+p.rB{3}));
    % compute average duration of mix and dominant percepts
    [mixdur(iter, cond), domdur(iter, cond), switches(iter, cond), reverses(iter, cond)] = parse_summation(p);

if iter == drawn_iter
        subplot(numel(taus), 1, cond);
        hold on;
        title(['Adaptation Constant = ', num2str(p.tau), 'ms']);
        p1 = plot(p.tlist/1000,p.rA{3},'color',[1 0 1]);
        p2 = plot(p.tlist/1000,p.rB{3},'color',[0 0 1]);
        legend([p1 p2], 'A','B');
        ylabel('Firing rate');
        xlabel('Time (s)');
        set(gca,'YLim',[0 1]);
        drawnow;
end

end
end

%% Plot
% figure;
% cla;
% subplot(5, 1, 1); hold on;
% ylabelarray = cell(1, numel(taus));
% for cond = 1:numel(taus)
%     barh(cond, mean(wta_list(:, cond), 1), 'FaceColor', [0.6 0.6 0.6]);
%     ylabelarray{cond} = [num2str(taus(cond)), 'ms'];
% end
% xlabel('Winner-take-all index','FontSize',20);
% % ylabel('Adaptation Time Constant','FontSize',20);
% set(gca,'YTick', 1:numel(taus), 'YLim', [0 numel(taus)+1], 'XTick', [0 .2 .4 .6 .8 1], 'XLim', [0 1], 'FontSize', 14)
% set(gca,'YTickLabel', ylabelarray);
% set(gca,'FontSize',20);
% 
% subplot(5, 1, 2); hold on;
% ylabelarray = cell(1, numel(taus));
% for cond = 1:numel(taus)
%     barh(cond, mean(wta_list(:, cond), 1), 'FaceColor', [0.6 0.6 0.6]);
%     ylabelarray{cond} = [num2str(taus(cond)), 'ms'];
% end
% xlabel('Average Mix Dur','FontSize',20);
% ylabel('Adaptation Time Constant','FontSize',20);
% set(gca,'YTick', 1:numel(taus), 'YLim', [0 numel(taus)+1], 'XTick', 0:5, 'XLim', [0 5], 'FontSize', 14)
% set(gca,'YTickLabel', ylabelarray);
% set(gca,'FontSize',20);
% 
% subplot(5, 1, 3); hold on;
% ylabelarray = cell(1, numel(taus));
% for cond = 1:numel(taus)
%     barh(cond, mean(domdur(:, cond), 1), 'FaceColor', [0.6 0.6 0.6]);
%     ylabelarray{cond} = [num2str(taus(cond)), 'ms'];
% end
% xlabel('Average Dom Dur','FontSize',20);
% % ylabel('Adaptation Time Constant','FontSize',20);
% set(gca,'YTick', 1:numel(taus), 'YLim', [0 numel(taus)+1], 'XTick', 0:5, 'XLim', [0 5], 'FontSize', 14)
% set(gca,'YTickLabel', ylabelarray);
% set(gca,'FontSize',20);
% 
% subplot(5, 1, 4); hold on;
% ylabelarray = cell(1, numel(taus));
% for cond = 1:numel(taus)
%     barh(cond, mean(reverses(:, cond), 1)/(0.001*p.T), 'FaceColor', [0.6 0.6 0.6]);
%     ylabelarray{cond} = [num2str(taus(cond)), 'ms'];
% end
% xlabel('Reversions','FontSize',20);
% % ylabel('Adaptation Time Constant','FontSize',20);
% set(gca,'YTick', 1:numel(taus), 'YLim', [0 numel(taus)+1], 'XTick', 0:0.2:1, 'XLim', [0 1], 'FontSize', 14)
% set(gca,'YTickLabel', ylabelarray);
% set(gca,'FontSize',20);
% 
% subplot(5, 1, 5); hold on;
% ylabelarray = cell(1, numel(taus));
% for cond = 1:numel(taus)
%     barh(cond, mean(switches(:, cond), 1)/(0.001*p.T), 'FaceColor', [0.6 0.6 0.6]);
%     ylabelarray{cond} = [num2str(taus(cond)), 'ms'];
% end
% xlabel('Switches','FontSize',20);
% % ylabel('Adaptation Time Constant','FontSize',20);
% set(gca,'YTick', 1:numel(taus), 'YLim', [0 numel(taus)+1], 'FontSize', 14)
% set(gca,'YTickLabel', ylabelarray);
% set(gca,'FontSize',20);