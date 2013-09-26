%
% This function computes the value of the objective function for a given rD
%
% Author: Celine Scheidt
% Date: May 2011

function OF = ComputeOFgivenRD(rD,real0,WorkingDirectory,response,rand_seed,...
    PriorProba,snesim_input,Prj_name,facies_perms,SimulationDeck,PropResponse,...
    TS_distance,distance_type,rd_regions)

global count  % count the number of simulations performed
count = count +1;

% Input parameters:
%   - rD: perturbation parameter
%   - real0: initial realization for the PPM (or current best)
%   - WorkingDirectory: directory where inner loop is performed
%   - response: 2D or 3D array containing the responses observed at each
%               well
%   - rand_seed: random seed to use
%   - PriorProba: prior probability in the Training Image
%   - snesim_input: snesim input parameter
%   - Prj_name: Name of the project containing TI and well information
%   - facies_perms: vector containing the permeability values for
%                   each facies                 
%   - SimulationDeck: Full file name of the 3dsl input deck
%   - PropResponse: Response to be read
%   - TS_distance: time-steps used to compute the distance
%   - rd_regions: map of the regions (one for each rD) for local PPM

% Output parameters:
%   - OF: objective function for a given rD


% Creation of the directories where realizations and flow simulation will
% be performed
[statu, mess, messid] = mkdir([WorkingDirectory '/run' num2str(count)]);
directory_PPM = [WorkingDirectory '/run' num2str(count)];

%% 1. Compute the probability maps associated with each facies

nb_facies = length(unique(real0));
pAD = zeros(size(real0,1),nb_facies);

for i = 1:nb_facies
    pAD(:,i) = getFaciesProbabilityCube(rD,rd_regions,PriorProba(i),real0 == i-1);
end

%% 2.  Launch Snesim using pAD as a probability cube

parFile = [WorkingDirectory '/ParFile'];
% Save the probability cubes
for i = 1:nb_facies
    savegslib([directory_PPM '/probacube'], snesim_input.nx, snesim_input.ny, snesim_input.nz, pAD)
    geoeas2sgemsRgrid(parFile, [directory_PPM '/probacube'],[directory_PPM '/Proba_map_sgems'],'probacube',snesim_input);
end

% Launch Snesim with the given probability cubes
facies_file = [directory_PPM '/facies.gslib'];
LaunchSnesim(Prj_name,rand_seed,snesim_input,1,facies_file,PriorProba,[directory_PPM '/Proba_map_sgems'])

%% 3. Evaluate the response for the new model (uses 3dsl)

 OF = ComputeOF_3dsl(directory_PPM,facies_file,SimulationDeck,response,facies_perms,...
    snesim_input,PropResponse,TS_distance,distance_type);

end