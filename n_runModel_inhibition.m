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
condnames =  {'Full inhibition', 'Intermediate inhibition', 'Low inhibition'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
p.tau           = 50;       %time constant (ms)
p.dt            = 5;        %time-step (ms)
p.T             = 20000;    %duration (ms)
p.noisefilter_t = 800;      %(ms)
p.noiseamp      = .03;      
p.nLayers       = 5;        %set to 3 for conventional model, 5 for opponency model
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

% The variable we compare
inhibgains = [1, 0.95, 0.9];

niter = 100;
drawn_iter = randi([1 niter]);
wta_list = zeros(niter, numel(inhibgains));


fprintf('Iteration: 0\n'); % display progress at cmd
for iter = 1:niter
fprintf([repmat('\b', 1, 1+length(num2str(iter-1))), num2str(iter), '\n']); % update progress

if iter == 2
    figure;
end


%loop through conditions
for cond = 1:numel(inhibgains);
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

    p.inhib_gain = inhibgains(cond);
    p.sigma         = .5;       %semisaturation constant
    p.sigma_opp     = .9;       %semisaturation constant for opponency cells
    
    %stimulus inputs to monocular layers
    for lay = 1:2
        p.iA{lay} = iA_amp_opts(lay)*ones(1,p.nt);
        p.iB{lay} = iB_amp_opts(lay)*ones(1,p.nt);
    end
     
    %run the model
    p = n_model_inhibition(p);
    
    %compute WTA index from summation layer
    wta_list(iter, cond) = nanmean(abs(p.rA{3}-p.rB{3})./(p.rA{3}+p.rB{3}));
    
    if iter == drawn_iter
        subplot(numel(inhibgains), 1, cond);
        hold on;
        title(['Inhibitory Gain = ', num2str(p.inhib_gain*100), '%']);
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

figure
cla; hold on;
ylabelarray = cell(1, numel(inhibgains));
for cond = 1:numel(inhibgains);
    barh(cond, mean(wta_list(:, cond), 1), 'FaceColor', [.6 .6 .6]);
    ylabelarray{cond} = [num2str(inhibgains(cond)*100), '%'];
end
xlabel('Winner-take-all index', 'FontSize', 20);
ylabel('Inhibitory Gain', 'FontSize', 20);
set(gca,'YTick', 1:numel(inhibgains), 'YLim', [0, numel(inhibgains)+1], 'XTick', [0 .2 .4 .6 .8 1], 'XLim', [0 1], 'FontSize', 14)
set(gca,'YTickLabel', ylabelarray);
set(gca,'FontSize',20);

