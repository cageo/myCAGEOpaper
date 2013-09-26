%
% This function updates the 3dsl input deck with the desired permeability
% field.
%
% Author: Celine Scheidt
% Date: January 2008


function Update_3dsl_dat(InputDeck,OutputDeck,perm_file)

%% Input parameters:

%   - InputDeck: Full file name of the 3dsl input deck (which will be
%               updated)
%   - OutputDeck: Full file name of the 3dsl output deck (the one used
%                 for the simulation
%   - perm_file: Permeability file to include

    fid_r = fopen(InputDeck,'rt');
    fid_w = fopen([OutputDeck '.dat'],'w');
    
    data_line = '';
    
    while ~strcmp(data_line,'END RECURRENT') % while end of file not reached
        
        data_line = fgetl(fid_r);

        if strfind(data_line,'INCLUDE ='); % if an INCLUDE is found, add the desired permeability file
            data_line = fgetl(fid_r);
            fprintf(fid_w,['INCLUDE =' '\''' perm_file '\''  ']);
            fprintf(fid_w,'\n');
            fprintf(fid_w,'\n');
        else  % copy the current line 
            fprintf(fid_w,data_line);
            fprintf(fid_w,'\n');
        end
    
    end

    fclose(fid_r);
    fclose(fid_w);
end


