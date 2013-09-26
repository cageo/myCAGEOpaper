%
% This function reads realizations in Gslib format and stores them in a
% matrix
%
% Author: Celine Scheidt
% Date: November 2007



function data = readgslib(filename,icol)
%% Input parameters:

%   - filename: Name of the file containing the realizations
%   - icol: realization index to return (optional)

%% Output parameters:

%   - data: matrix of dimensions [nx*ny*nz,nrealizations] containing the 
%           realizations (one column corresponds to one realization)  

    fid = fopen(filename, 'r');
    % T.H. Read the first line which contains the name and the size of the
    % grid. 'x' are skipped when reading
    tline = textscan(fid,'%s (%fx%fx%f) ',1);

    % dimensions of the grid    
    nx = tline{2};
    ny = tline{3};
    nz = tline{4};
    
    % T.H. Number of realizaions
    ncol = fscanf(fid, '%d\n', 1);
    
    % T.H. Read the header or name of the ncol realizations
    for i=1:ncol
        tline = fgetl(fid);
    end

    % T.H. Read in a matrix the realizations
    data  = fscanf(fid, '%f', [1 inf]);
    data = reshape(data,ncol,nx*ny*nz);
    data = data';

    if nargin == 2
        data = data(:,icol);
    end

fclose(fid);
end
