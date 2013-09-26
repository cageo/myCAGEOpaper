
%% This script applies PPM to an example of a 2D
%% set of simple channel models. We create a set of 5 history matched models.

% Note that in this example, we use snesim (in Sgems) to create
% realizations and 3dsl for the flow simulations

% Author: Celine Scheidt
% Date: June 2012



% define the working directory. 
load '2DChannelModel/InitialsModels.mat'

WorkingDirectory = '2DChannelModel/';


%% Definition of the input parameters

% MPS (snesim) inputs
Prj_name = [WorkingDirectory 'Sgems_project.prj'];  % Sgems project containing the TI and the hard data (wells)
Nreal = 100;  % Number of initial realizations
snesim_input.nx = 80;
snesim_input.ny = 80;
snesim_input.nz = 1;
snesim_input.dx = 1;
snesim_input.dy = 1;
snesim_input.dz = 1;
snesim_input.TIname =  'TI16';
snesim_input.range_max = 50; % template size
snesim_input.range_med = 35;
snesim_input.range_min = 10;
snesim_input.maxcondval = 60;
PriorProba = [0.7 0.3]; % prior probability of each facies

% Simulation (3dsl) inputs
facies_perms = [1 100]; % permeability value per facies (constant)
SimulationDeck = [WorkingDirectory '/3dsl.dat'];
PropResponse = 'WAT';  % response studied is the water rate

%% 2. Apply PPM 

of_max = 8; % Maximum objective function value for a model to be considered as history matched

outer_loop = zeros(1,nrnew); % index of the outer loop where best model is obtained
inner_loop = zeros(1,nrnew); % index of the inner loop where best model is obtained
final_OF = zeros(1,nrnew); % Objective function after convergence of PPM
NbSimu = zeros(1,nrnew); % total number of simulation per Hm model

for i = 1:nrnew
    
    rand_seed = round(rand(1)*1000);
    directory_PPM = [WorkingDirectoryPI '/PPM' num2str(i)];
    mkdir(directory_PPM); 
   
    % Generate initial realization which is conditionned to the probability
    % map issued from the post-image
    facies_file = [directory_PPM '/RealInit.gslib'];
    LaunchSnesim(Prj_name,rand_seed,snesim_input,1,facies_file,PriorProba)
    real0 = readgslib(facies_file,1);

    % Compute objective function for the initial model
    OF_x0 = ComputeOF_3dsl(directory_PPM,facies_file,SimulationDeck,WWPR_ref,facies_perms,...
        snesim_input,PropResponse,TS_distance,distance_type);

    % Apply PPM
    [outer_loop(i) inner_loop(i) final_OF(i) NbSimu(i)] = PPM_Sgems_3dsl(of_max,10,real0,OF_x0,directory_PPM,WWPR_ref,rand_seed,...
            PriorProba,snesim_input,Prj_name,facies_perms,SimulationDeck,PropResponse,TS_distance,distance_type);

end 

%% 3. Read the results

WWPR_PPM =[]; %
for i = 1:nrnew
    if outer_loop(i) == 0 
        WWPR_PPM = vertcat(WWPR_PPM,read_3dsl_wel([WorkingDirectoryPI '/PPM' num2str(i) '/3dsl.P1.wel'],PropResponse));
    else
        WWPR_PPM = vertcat(WWPR_PPM,read_3dsl_wel([WorkingDirectoryPI '/PPM' num2str(i) '/iter' num2str(outer_loop(i)) '/run' num2str(inner_loop(i)) '/3dsl.P1.wel'],PropResponse));
    end
end

figure
axes('FontSize',13)
plot(TIME,WWPR,'-','Color',[0.8 0.8 0.8],'LineWidth',2)
hold on
plot(TIME,WWPR_PPM,'-b','LineWidth',3)
plot(TIME,WWPR_ref,'-or','LineWidth',3,'MarkerFaceColor','r')
xlabel('TIME (days)','FontSize',14)
ylabel('Water Rate (stb/day)','FontSize',14)


