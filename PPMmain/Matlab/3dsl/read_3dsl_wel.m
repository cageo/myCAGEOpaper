%
% This function reads 3dsl output files (.wel) and returns the values of
% the desired property
%
% Author: Celine Scheidt
% Date: January 2008


function data = read_3dsl_wel(inputfile,prop)

%% Input parameters:

%   - inputfile: Name of the file to read
%   - prop: Properties that should be returned

%% Output parameters:

%   - data: vector of the output response (as a function of time)


    fid = fopen(inputfile,'r');
    for i=1:4
        tline = fgetl(fid);
    end

    data = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', [25 inf]);

    switch prop
        case 'TS'
            data = data(1,:);
        case 'TIME'
            data = data(2,:);
        case 'BHP'
            data = data(3,:);
        case 'OIL'
            data = data(4,:);
        case 'GAS'
            data = data(5,:);
        case 'WAT'
            data = data(6,:);
        case 'GOR'
            data = data(7,:);
        case 'WCUT'
            data = data(8,:);
        case 'OIL_cumul'
            data = data(12,:);
        case 'GAS_cumul'
            data = data(13,:);
        case 'WAT_cumul'
            data = data(14,:);
        case 'HOIL'
            data = data(18,:);
        case 'HGAS'
            data = data(19,:);
        case 'HWAT'
            data = data(20,:);
        case 'HGOR'
            data = data(21,:);
        case 'HWCUT'
            data = data(22,:);
        otherwise
            error(['UNABLE TO READ PROPERTY: ' prop]);
    end

    fclose(fid);

end