%
% This function takes a facies realization (Gslib), attributes a constant
% zone value at each facies and outputs it in HGS format The corresponding
% parameters for each zone must be defined in the mprops file
%
% Author: Thomas Hermans
% Date: November 2012
%
function FaciesToZones(facies_file,Zone_name)

%% Input parameters:

%   - facies_file: File name of facies realization
%   - Zone_name: File name of permeability realization (prefix only)
%   - nx, ny, nz: Dimensions of the grid


    % Read the facies realization
    act = readgslib(facies_file,1);
    act_init = act;
    zone=[1:length(act)];
    
    % Attribute a constant value to each zone
    % T.H. Do once for each facies, find all value of the facies and
    % attrribute zone (facies +1)
    for i = 1:length(act_init)
        act(i) = act_init(i)+1;
    end

    % Write the realization in HGS Zone format
    % Write in Eclipse format
        fid = fopen([Zone_name], 'wt');
        for k = 1:length(act)
                    fprintf(fid,'%d \t %d',zone(k), act(k));
                    fprintf(fid,'\n');
        end
        % Close files
        fclose(fid);

end