%
% This function launches 3dsl for given permeability realizations 
%
% Author: Celine Scheidt
% Date: January 2008


function Launch3dsl(InputDeck,directory_simu,directory_perms,Nreal,prefix_simu,perm_name)
    
%% Input parameters:

%   - InputDeck: Full file name of the 3dsl input deck (the perm file to read will
%               be updated)
%   - directory_simu: Directory where the simulations will be performed
%   - directory_perms: Directory containing the permeability files
%   - Nreal: Number of simulations to perform
%   - prefix_simu: prefix of the simulation output files
%   - perm_name: prefix of the permeability files

    if Nreal == 1
        perm_file = [directory_perms perm_name '.out'];
        outputfile = [directory_simu prefix_simu];
        % Copy the 3dsl deck and update it with the permeability field
        Update_3dsl_dat(InputDeck,outputfile,perm_file);
        % Launch 3dsl
        dos(['set RLM_LICENSE= 28000@ERE-PCServ &&"D:/Softwares/studioSL-7.0/studiosl/modules/ext/3dsl-win-i86-2012.05.11.exe" "' outputfile '" > 3dsl.tmp']);
        % delete unecessary files
        delete([outputfile '.amg'])
        delete([outputfile '.zne'])
        delete([outputfile '.wcc'])
        delete([outputfile '.mbs'])
        delete([outputfile '.eco'])
        delete([outputfile '.idx'])
        delete([outputfile '.rvs'])
        %delete([outputfile '_ecl23dsl.out'])
    else      
        for i = 1:Nreal
            perm_file = [directory_perms perm_name num2str(i) '.out'];
            outputfile = [directory_simu prefix_simu num2str(i)];
            % Copy the 3dsl deck and update it with the permeability field
            Update_3dsl_dat(InputDeck,outputfile,perm_file);
            % Launch 3dsl
            dos(['set RLM_LICENSE= 28000@ERE-PCServ &&"D:/Softwares/studioSL-7.0/studiosl/modules/ext/3dsl-win-i86-2012.05.11.exe" "' outputfile '" > 3dsl.tmp']);
            % delete unecessary files
            delete([outputfile '.amg'])
            delete([outputfile '.zne'])
            delete([outputfile '.wcc'])
            delete([outputfile '.mbs'])
            delete([outputfile '.eco'])
            delete([outputfile '.idx'])
            delete([outputfile '.rvs'])
            %delete([outputfile '_ecl23dsl.out'])
        end
    end
end

 