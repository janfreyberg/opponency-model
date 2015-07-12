Branch: "compare-perturbations"
-------------
This branch compares three perturbations possibly present in autism: Increased/Decreased noise, decreased adaptation, and decreased inhibition.

Instructions
-------------

To run the original model, just enter
`n_runModel`
into Matlab.

To compare across possible perturbations, run the 'n_runModel_XXX' scripts.
You can edit how often the scripts iterate by changing the "iter" variable. You can change computational load per iteration by changing the p.dt variable in each script. This determines how fine the time steps are when running using the Euler method.

If you use this, please cite
Said and Heeger (2013) A model of binocular rivalry and cross-orientation
suppression. PLOS Computational Biology.

If you modify and distribute the code, please include this README.txt file.

Copyright Information
-------------

Copyright 2013 by New York University
Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of New York University not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission.

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.
