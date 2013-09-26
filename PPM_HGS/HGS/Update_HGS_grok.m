%
% This function updates the HGS input grok file with the desired facies
%
% Author: Thomas Hermans
% Date: November 2012


function Update_HGS_grok(InputDeck,OutputDeck,Zone_Name)

%% Input parameters:

%   - InputDeck: Full file name of the HGS input grok (which will be
%               updated)
%   - OutputDeck: Full file name of the HGS output grok file (the one used
%                 for the simulation
%   - real: zone file with facies to create and to include


    fid_r = fopen(InputDeck,'rt');
    fid_w = fopen([OutputDeck '.grok'],'w');
    
    data_line = '';
    ifindit=0;
    
    while ~strcmp(data_line,'!END OF GROK FILE') % while end of file not reached
        
        data_line = fgetl(fid_r);
        fprintf(fid_w,data_line);
        fprintf(fid_w,'\n');
        if strfind(data_line,'read zones from file'); % we find the position of the zone file in the grok file
            data_line = fgetl(fid_r);
            fprintf(fid_w,'Zone');
            fprintf(fid_w,'\n');
        end
    
    end

    fclose(fid_r);
    fclose(fid_w);
end


