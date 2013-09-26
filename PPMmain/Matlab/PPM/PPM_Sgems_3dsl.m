%
% This function performs the outer loop of the PPM procedure
%
% Author: Celine Scheidt
% Date: May 2011


function [outer_opt inner_opt ofmin nbsimu] = PPM_Sgems_3dsl(obj,nitr,x0,OF_x0,WorkingDirectory,obs_response,rand_seed,...
    PriorProba,snesim_input,Prj_name,facies_perms,SimulationDeck,PropResponse,TS_distance,...
    distance_type,rd_regions)


global count;  % number of inner loops of the PPM
count = 0;

%% Input parameters:
%   - obj: maximum objective function for convergence
%   - nitr: maximum number of outer loops
%   - x0: initial realization for the PPM
%   - OF_x0: OF at the initial realization
%   - WorkingDirectory: directory where PPM is performed
%   - obs_response: response to match
%   - rand_seed: random seed to use
%   - PriorProba: prior probability in the Training Image
%   - snesim_input: snesim input parameter
%   - Prj_name: Name of the project containing TI and well information
%   - facies_perms: vector containing the permeability values for
%                   each facies                 
%   - SimulationDeck: Full file name of the 3dsl input deck
%   - PropResponse: Response to be read
%   - TS_distance: time-steps used to compute the distance
%   - distance_type
%   - rd_regions: map of the regions (one for each rD) for local PPM
%          (optional: if not provided, global PPM is applied

%% Output parameters:
%   - outer_opt: index of the outer loop where best model is obtained
%   - inner_opt: index of the inner loop where best model is obtained



% Initialization of parameters

outer_opt = 0;  % outer loop index with optimal OF
inner_opt = 0;  % inner loop index with optimal OF
of_opt = Inf;   % optimal objective function value
nbsimu = 1; % to account for initial simulation

if nargin < 18  % If regions are not provided --> Global PPM
    rd_regions = ones(snesim_input.nx*snesim_input.ny*snesim_input.nz,1);
end

npara = length(unique(rd_regions));

rand('state',rand_seed);
rand('seed',rand_seed);
rand_vals = round(rand(1,nitr)*1000000);  % definition of random seeds

if OF_x0 < obj
    fprintf('Initial realization is already HM \n')
    return
end

% Ensure that if PPM is done per regions, the data given contains the
% reference data per regions 
if npara > 1
   if length(size(response)) == 2
       error('Local PPM cannot be performed using distance.  Please give as input the data to be matched and not the responses for the initial models');
   elseif size(response,2) > 1
       error('Local PPM cannot be performed using distance.  Please give as input the data to be matched and not the responses for the initial models');
   elseif size(response,1) ~= npara
       error('The number of regions in the PPM is different than the number of wells.');
   end
end
   
% parameters for brent optimization 
ax = 0; % minimal value for rD
bx = repmat(0.5,1,npara); % starting value for rD
cx = repmat(1,1,npara);   % maximal value for rD

fval_opt = sum(OF_x0);  % current objective function (for x0)
fval_regions = OF_x0;

for iter = 1:nitr  % outer loop
    fprintf('\n');
    fprintf('OUTER LOOP %i.\n',iter);
    directory_results = ['/iter' num2str(iter)];  % creation of directory for outer loop
    [statu, mess, messid] = mkdir([WorkingDirectory directory_results]);  
   
  % Function to be optimized in the PPM procedure (it will be called in
  % the function brentpara below)
   head_objfun = @(rD) ComputeOFgivenRD(rD,x0,[WorkingDirectory directory_results],obs_response,rand_vals(iter),...
                       PriorProba,snesim_input,Prj_name,facies_perms,SimulationDeck,PropResponse,...
                       TS_distance,distance_type,rd_regions);
%                              
   
   fval_opt_old = fval_opt;
   fval_regions_old = fval_regions;
    
    
    %% Optimization procedure on rD to minimize head_objfun
    %   - rD_opt and fval_opt represent the optimal values for the current inner loop
    %   - rD_all and OF_all represent all the values of rD and the corresponding OF tested during the optimization 
    %       (Note that those include rD = 0, where no simulations were performed)
    
    [rD_opt,fval_opt,rD_all,OF_all,OF_regions]= brentpara(ax,bx,cx,0.001,npara,fval_regions,obj,head_objfun);
    
    % Save OF values for each rD tested
    savePPM_OFvals([WorkingDirectory directory_results '\OF values'],rD_all,OF_all,OF_regions,npara);
    nbsimu = nbsimu + size(OF_all,2) - 1;
    
    % Find the best OF value for the inner loop
    run_opt = find(OF_all == min(OF_all))-1;
    run_opt = run_opt(1);
    
    if fval_opt < of_opt  % if OF has decreased, update the indices
       outer_opt = iter;
       inner_opt = run_opt;
       of_opt = fval_opt;
    end

    fval_regions = OF_regions(:,run_opt+1);
    
    fprintf('OBJ___=%f\n', min(OF_all));
    ofmin = min(OF_all);
    
    if min(OF_all) < obj  % if the best OF found is less that the given threshold (obj), then STOP
        fprintf('updated\n');
        break;
    else 
        fprintf('declined\n');
        if run_opt == 0  % if the inner loop did not manage to improve the OF of the previous iteration, keep x0 and fval_opt as in the previous inner loop
            fval_opt = fval_opt_old;
            fval_regions = fval_regions_old; 
        else  % update x0 (i.e. the realization having the best OF)
            x0 = readgslib([WorkingDirectory directory_results '/run' num2str(run_opt) '/facies.gslib'],1);
        end
        count = 0;
    end
end
end