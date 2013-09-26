%
% This function transform a grid from gslib format to sgems format
%
% Requires geoeas2sgems.exe and qt-mt334.dll
% 
% Author: Celine Scheidt
% Date: Sept. 2008


function geoeas2sgemsRgrid (parFile, file_in, file_out,rgrid_name,snesim_input)
    
   % Write the inputfile 
   file = fopen(parFile,'w');
   fprintf(file,[file_in '\n']);    % file containing the geoeas object
   fprintf(file,[file_out '\n']);   % name of output file
   fprintf(file,[rgrid_name '\n']);  % name of the object
   fprintf(file,'1 \n');          % type of object: pointset (0), grid (1)
   fprintf(file,'0 \n');          % If pointset: 2D (0) or 3D (1)
   fprintf(file,[num2str(snesim_input.nx) ' ' num2str(snesim_input.ny) ' ' num2str(snesim_input.nz) '\n']);       % number of gridblocks: nx ny nz
   fprintf(file,[num2str(snesim_input.dx) ' ' num2str(snesim_input.dy) ' ' num2str(snesim_input.dz) '\n']);       % gridblock size: dx dy dz
   fprintf(file,[num2str(0) ' ' num2str(0) ' ' num2str(0) '\n']);       % grid origin: x0 y0 z0
   fprintf(file,'1\n');           % number of realizations
   fprintf(file,'-1\n');    % property no_data_value  
   fclose(file);
   
   dos(['Sgems\geoeas2sgems ' parFile ' > geoeas2sgemsRgrid.out']);
end
