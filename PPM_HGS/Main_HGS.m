
%% This script applies PPM to an example of a 3D
%% alluvial aquifer. We create a set of nrnew history matched models.

% Note that in this example, we use snesim (in Sgems) to create
% realizations and Hydrogeosphere for flow simulations

% Author: Thomas Hermans (based on the code of Celine Scheidt)
% Date: October 2012

% Load the data that will be used for history matching, i.e. data to match
clear all
close all
clc
load 'C:/Users/ULg/Documents/Thèse/Stanford/PPM/PPM/Synthetic3/Response2fit.mat' %Still to create

WorkingDirectory = 'C:/Users/ULg/Documents/Thèse/Stanford/PPM/PPM/Synthetic3';
cd(WorkingDirectory);


%% 1. Definition of the input parameters
%%%%%%%%%%%%%%%%%%%%%%%
% MPS (snesim) inputs %
%%%%%%%%%%%%%%%%%%%%%%%

Prj_name = [WorkingDirectory '/Sgems_project.prj'];  % Sgems project containing the TI and the hard data (wells)
Nreal = 1;  % Number of initial realizations
snesim_input.nx = 136;
snesim_input.ny = 58;
snesim_input.nz = 24;
snesim_input.dx = 1;
snesim_input.dy = 1;
snesim_input.dz = 0.5;
% T.H. Name of the Training Image
% The property name is "facies"
snesim_input.TIname =  'TI';
% T.H. Size of the template to calculate probability
snesim_input.range_max = 35; % template size
snesim_input.range_med = 35;
snesim_input.range_min = 10;
% T.H. maximum number of nodes to build the search tree 
snesim_input.maxcondval = 150;
PriorProba = [0.58 0.2 0.22]; % prior probability of each facies
SoftProba_file = [WorkingDirectory '/SoftProba.gslib'] ;% File containing soft data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation (HGS) inputs %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% T.H. this is done through the GROK file for HGS, if properties are
% defined in mprops file it has to be defined, too
% the array size is defined to avoid error during simulation
SimulationDeck = [WorkingDirectory '/synthetic.grok'];
SimulationProp = [WorkingDirectory '/synthetic.mprops'];
SimulationArraySize = [WorkingDirectory '/array_sizes.default'];
PropResponse = 'H';  % response studied is the piezometric level H

%% 2. Apply PPM 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the fit criteria for a model to be matched %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

of_max = 0.025; % Maximum objective function value for a model to be considered as history matched
nrnew = 50; % Number of history matched models to create
outer_loop = zeros(1,nrnew); % index of the outer loop where best model is obtained
inner_loop = zeros(1,nrnew); % index of the inner loop where best model is obtained
final_OF = zeros(1,nrnew); % Objective function after convergence of PPM
NbSimu = zeros(1,nrnew); % total number of simulation per Hm model

for i = 24:nrnew
    
    % T.H. Generate a random seed between 1 and 1000 for initial model
    rand_seed = round(rand(1)*1000);
    % T.H. Create a directory to store the results for one loop
    directory_PPM = [WorkingDirectory '/PPM' num2str(i)];
    mkdir(directory_PPM); 
    parFile = [WorkingDirectory '/ParFile'];
    % Generate initial realization which is conditionned to hard data, soft
    % data (ERT probability maps) and the training image
    facies_file = [directory_PPM '/RealInit.gslib'];
    % T.H. Need only the input parameters to run a simulation in Sgems
    % Enter SoftProba as a file
    geoeas2sgemsRgrid(parFile, SoftProba_file,[WorkingDirectory '/Proba_map_sgems'],'probacube',snesim_input);
    % Hard data in grid "wells", property facies, see example to modify
    % LaunchSnesim
    fprintf('Generate initial realization for simulation %d with Sgems \n',i)
    LaunchSnesim(Prj_name,rand_seed,snesim_input,1,facies_file,PriorProba,[WorkingDirectory '/Proba_map_sgems'])
    % T.H. read the initial realization and stock it in a matrix
    real0 = readgslib(facies_file,1);

    % Compute objective function for the initial model
    disp('Compute the objective function for the initial model')
    OF_x0 = ComputeOF_HGS(directory_PPM,facies_file,SimulationDeck,SimulationProp,SimulationArraySize,piezo,...
        PropResponse);

    % Apply PPM
    disp('Starting optimization using the Probability Perturbation Method')
    [outer_loop(i) inner_loop(i) final_OF(i) NbSimu(i)] = PPM_Sgems_HGS(of_max,10,real0,OF_x0,directory_PPM,piezo,rand_seed,...
            PriorProba,snesim_input,Prj_name,SimulationDeck,SimulationProp,SimulationArraySize,PropResponse,SoftProba_file);
    fprintf('History matching of model %d is done \n', i)
 end 
save HM_Synthetic1
%% 3. Read the results 
% To change according to what we want
% 
% 
% WWPR_PPM =[]; %
% for i = 1:nrnew
%     if outer_loop(i) == 0 
%         WWPR_PPM = vertcat(WWPR_PPM,read_3dsl_wel([WorkingDirectoryPI '/PPM' num2str(i) '/3dsl.P1.wel'],PropResponse));
%     else
%         WWPR_PPM = vertcat(WWPR_PPM,read_3dsl_wel([WorkingDirectoryPI '/PPM' num2str(i) '/iter' num2str(outer_loop(i)) '/run' num2str(inner_loop(i)) '/3dsl.P1.wel'],PropResponse));
%     end
% end
% 
% figure
% axes('FontSize',13)
% plot(TIME,WWPR,'-','Color',[0.8 0.8 0.8],'LineWidth',2)
% hold on
% plot(TIME,WWPR_PPM,'-b','LineWidth',3)
% plot(TIME,WWPR_ref,'-or','LineWidth',3,'MarkerFaceColor','r')
% xlabel('TIME (days)','FontSize',14)
% ylabel('Water Rate (stb/day)','FontSize',14)


