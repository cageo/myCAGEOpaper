Matlab implementation of the probability perturbation method

Celine Scheidt and Jef Caers
(example provide by Thomas Hermans)

This repository contains a matlab implementation of the probability perturbation method (PPM). For theory, please consult the following two papers

History matching under training-image-based geological model constraints, J Caers. 
SPE journal 8 (3), 218-226

The probability perturbation method: a new look at Bayesian inverse modeling
J Caers, T Hoffman, Mathematical geology 38 (1), 81-100.

The matlab code provides an example implementation. PPM can be applied to any spatial inverse problem involving discrete variables (an extension to continuous was published by Lin Hu, termed extended PPM) with any forward model. It is difficult to write a generic code for any forward model since each forward model (simulator) has their own input an output. In PPMmain you will find the code written by Celine Scheidt. That code has been modified by Thomas Hermans (ULG, Belgium) for a completely different simulator. We hope that suffices for anyone to use this code and tailor it for their own needs.

PPMmain contains two folders

Matlab: all matlab files where the forward model is a streamline simulator 3dsl, the geostatistical simulator is SGEMS (sgems.sourceforge.net)

2DChannelmodel: a simple 2D example with a channel training image

PPM_HGS contains a 3D hydrogeology example create by Thomas Hermans of the ULG, Belgium.
