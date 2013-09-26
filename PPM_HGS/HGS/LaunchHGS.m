%
% This function launches HGS for given facies realizations 
%
% Author: Thomas Hermans
% Date: November 2012


function LaunchHGS(InputGrok,InputMprops,InputDefault,Zone_Name,directory_simu,prefix_simu)
    
%% Input parameters:

%   - InputDeck: Full file name of the HGS grok file
%   - InputProp: Full file name of the HGS mprops file
%   - Zone_Name : Realization to be evaluated in zone HGS format
%   - directory_simu: Directory where the simulations will be performed
%   - Nreal: Number of simulations to perform
%   - prefix_simu: prefix of the simulation output files

%     if Nreal == 1
        outputfile = [directory_simu '/' prefix_simu];
        % Copy the HGS grok file and update it with the facies field and
        % Transform real into zones file for HGS
        Update_HGS_grok(InputGrok,outputfile,Zone_Name);
        copyfile(InputMprops,directory_simu);
        copyfile(InputDefault,directory_simu);
        % Create a file batch.pfx which contains the prefix of the grok
        % file
        fid = fopen([directory_simu '/batch.pfx'],'wt');
        fprintf(fid,prefix_simu);
        fclose(fid);
        % Launch HGS
        oldfolder=cd(directory_simu);
        system('grok_opt')
        system('hydro_opt')
        %system('hsplot_opt')
        cd(oldfolder);
end

 