function [] = n_runModel_inhibition()
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
p.sigma         = .5;       %semisaturation constant
p.sigma_opp     = .9;       %semisaturation constant for opponency cells
p.tau           = 50;       %time constant (ms)
p.dt            = 5;        %time-step (ms)
p.T             = 20000;    %duration (ms)
p.noisefilter_t = 800;      %(ms)
p.noiseamp      = .03;      
p.nLayers       = 5;        %set to 3 for conventional model, 5 for opponency model
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

% The variable we compare
inhibgains = [1, 0.9, 0.8];

niter = 10;
wta_list = zeros(niter, numel(inhibgains));


fprintf('Iteration: 0\n'); % display progress at cmd
for iter = 1:niter
fprintf(['\b\b', num2str(iter), '\n']); % update progress




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
    
    %stimulus inputs to monocular layers
    for lay = 1:2
        p.iA{lay} = iA_amp_opts(lay)*ones(1,p.nt);
        p.iB{lay} = iB_amp_opts(lay)*ones(1,p.nt);
    end
     
    %run the model
    p = n_model_inhibition(p);
    
    %compute WTA index from summation layer
    wta_list(iter, cond) = nanmean(abs(p.rA{3}-p.rB{3})./(p.rA{3}+p.rB{3}));

end

end

figure
cla; hold on;
ylabelarray = cell(1, numel(inhibgains));
for cond = 1:numel(inhibgains);
    barh(cond, mean(wta_list(:, cond), 1), 'FaceColor', [.6 .6 .6]);
    ylabelarray{cond} = ['inhib=', num2str(inhibgains(cond))];
end
xlabel('Winner-take-all index','FontSize',20)
set(gca,'YTick', 1:numel(inhibgains), 'YLim', [0, numel(inhibgains)+1], 'XTick', [0 .2 .4 .6 .8 1], 'XLim', [0 1], 'FontSize', 14)
set(gca,'YTickLabel', ylabelarray);
set(gca,'FontSize',20);

