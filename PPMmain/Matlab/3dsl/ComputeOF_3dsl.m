%
% This function computes the value of the objective function for a given realization

% Note:  The flow simulation is performed using 3dsl
%
% Author: Celine Scheidt
% Date: February 2011

function OF = ComputeOF_3dsl(WorkingDirectory,facies_file,... 
    SimulationDeck,response,facies_perms,snesim_input,PropResponse,...
    TS_distance,distance_type)

%% Input parameters:
%   - WorkingDirectory: Full path where simulations should be performed
%   - facies_file: Full path of the realization to be evaluated
%   - SimulationDeck: Full file name of the 3dsl input deck
%   - response: 2D or 3D array containing the responses observed at each
%               well
%   - facies_perms: vector containing the permeability values for each
%                   facies
%   - snesim_input: snesim input parameters
%   - PropResponse: Response to be read
%   - TS_distance: time-steps used to compute the distance
%   - distance_type: type of distance to use ('euclidean','cityblock',etc.)
%                    see help from pdist

%% Output parameters:
%   - OF: objective function for a given realization



%% 1. Evaluate the response for the given model (uses 3dsl)

% transform facies relazation in permeabilities for 3dsl (Eclipse Format)
perm_name = [WorkingDirectory '/PERMX' ];
FaciesToPerms(facies_file,perm_name,'PERMX',facies_perms,snesim_input.nx, snesim_input.ny, snesim_input.nz);

% Launch 3dsl
prefix_simu = '/3dsl';
Launch3dsl(SimulationDeck,WorkingDirectory,WorkingDirectory,1,prefix_simu,'/PERMX1');


%% 2. Read the output response

response_tot = response;
if length(size(response)) == 3  % if response is a 3D array
    Nreal = size(response,2);
    nb_wells = size(response,1);
    for i = 1:nb_wells
        response_tot(i,Nreal+1,:) = read_3dsl_wel([WorkingDirectory '/3dsl.P' num2str(i) '.wel'],PropResponse);
    end
else % if response is a 2D array
    nb_wells = 1;
    response_tot = vertcat(response_tot,read_3dsl_wel([WorkingDirectory '/3dsl.P1.wel'],PropResponse));
end

%% 3. Compute the objective function
OF = compute_OF_wells(nb_wells,response_tot,TS_distance,distance_type);
OF = OF';
end