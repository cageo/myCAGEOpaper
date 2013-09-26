%
% This function writes a realization in a file (Gslib format)
%
% Author: Celine Scheidt
% Date: November 2007



function savegslib(facies_file, nx, ny, nz, val)
%% Input parameters:

%   - facies_file: File where the realization(s) will be writen
%   - nx, ny, nz: Dimension of the grid
%   - val: vector/matrix containing the realizations values (one column =
%          one realization)

    fid = fopen(facies_file, 'wt');
    fprintf(fid,'realization (%dx%dx%d)\n',nx,ny,nz);
    fprintf(fid,'%d\n',size(val,2));

    for i=1:size(val,2)
        fprintf(fid,'z%d\n',i);
    end

    for i=1:size(val,1)
        for j=1:size(val,2)
            fprintf(fid,'%f \t',val(i,j));
        end
        fprintf(fid,'\n');
    end

    fclose(fid);

end