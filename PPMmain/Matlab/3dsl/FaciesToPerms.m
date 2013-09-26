%
% This function takes a facies realization (Gslib), attributes a constant
% permeability value at each facies and outputs it in Eclipse format
%
% Author: Celine Scheidt
% Date: January 2008
%
function FaciesToPerms(facies_file,perm_file,prop_name,facies_perms,nx,ny,nz)

%% Input parameters:

%   - facies_file: File name of facies realization
%   - perm_file: File name of permeability realization (prefix only)
%   - prop_name: Keyword for Eclipse - (PERMX, PERMY, PORO, etc.)
%   - facies_perms: Vector containing the property (constant) values for each facies
%   - nx, ny, nz: Dimensions of the grid


    % Read the facies realization
    act = readgslib(facies_file);
    act_init = act;
    
    % Attribute a constant value to each facies
    for i = 1:length(unique(act))
        act(act_init == i-1) = facies_perms(i);
    end

    % Write each realization in Eclipse format
    for l = 1:size(act,2)
    % Write in Eclipse format
        fid = fopen([perm_file num2str(l) '.out'], 'wt');
        fprintf(fid,prop_name);
        fprintf(fid,'\n');

        for k = nz-1:-1:0
            for j = ny-1:-1:0
                for i = 1:nx
                    index = i+j*nx+k*nx*ny;
                    fprintf(fid,'%f \t',act(index,l));
                    fprintf(fid,'\n');
                end
            end
        end

        % Close files
        fprintf(fid,'/');
        fclose(fid);
    end

end