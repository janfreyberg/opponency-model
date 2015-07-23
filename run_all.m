% Simulation specifics
p.dt            = 5;        %time-step (ms)
p.T             = 20000;    %duration (ms)
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;
p.niter         = 250;      %how often model should be run

% Model specifics
p.sigma         = .5;       %semisaturation constant
p.sigma_opp     = .9;       %semisaturation constant for opponency cells
p.tau           = 50;       %time constant (ms)
p.noisefilter_t = 800;      %(ms)
p.noiseamp = 0.03;          %amplitude of noise
p.nLayers       = 5;        %set to 3 for conventional model, 5 for opponency model

p.cutoff = 0.2; % this is the WTA-index score that has to be surpassed to count as dominant
p.mintime = 0; % this is the minimum duration a percept needs to be long to count at all

% Model Noise
p.noisevars = [0.03, 0.04, 0.05]; % The parameters for the model
[noisemodel.wta, noisemodel.mixdur, noisemodel.domdur, noisemodel.switches, noisemodel.reverses] = n_runModel_noise(p);
noisemodel.params = p.noisevars;
noisemodel.ylabstring = 'Noise Amplitude';

p.adaptationvars = [50 100 150]; % The parameters for the model
[adapmodel.wta, adapmodel.mixdur, adapmodel.domdur, adapmodel.switches, adapmodel.reverses] = n_runModel_adaptation(p);
adapmodel.params = p.adaptationvars/1000;
adapmodel.ylabstring = 'Adaptation Time Constant';

p.inhibvars = [1 0.9 0.8]; % The parameters for the model
[inhibmodel.wta, inhibmodel.mixdur, inhibmodel.domdur, inhibmodel.switches, inhibmodel.reverses] = n_runModel_inhibition(p);
inhibmodel.params = p.inhibvars;
inhibmodel.ylabstring = 'Inhibitory Gain';

