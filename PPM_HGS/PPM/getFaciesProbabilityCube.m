%
% This function returns the probability map corresponding to the given rD
% value in the PPM
%
% Author: Celine Scheidt
% Date: April 2011


function pAD = getFaciesProbabilityCube(rD,rd_regions,pA,facies_value)

%% Input parameters:
%   - rD: value of rD in the PPM
%   - rd_regions: map of the regions for local PPM (if global, it should be
%                 a map of ones).
%   - pA: prior probability of the facies
%   - facies_value: indicatior map of the facies

%% Output parameters:
%   - pAD: Probability map to be use to simulate next realization

    real_length = length(facies_value);

    pAD = zeros(real_length,1);
    for i = 1:real_length
        pAD(i) = (1-rD(rd_regions(i)))*facies_value(i) + rD(rd_regions(i))*pA;
    end
   
end