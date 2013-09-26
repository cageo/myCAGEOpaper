%
% This function writes the objective functions values for each rD in a file
%
% Author: Celine Scheidt
% Date: May 2011

function savePPM_OFvals(filename,rD_all,OF_all,OF_wells,npara)


%% Input parameters:
%   - filename: Name of the file where values are written
%   - rD_all: vector containing all the rD values tested
%   - OF_all: vector containing the corresponding objective function values
%   - OF_wells: vector containing the corresponding objective function
%               values per region (1 row is 1 region)
%   - npara: number of regions


 fid = fopen(filename,'wt');

 
 if npara == 1
     fprintf(fid,'rD values: \t');
     for i=1:size(rD_all,2)
        fprintf(fid,'%f \t',rD_all(i));
     end
     fprintf(fid,' \n');
     fprintf(fid,'OF values: \t');
     for i=1:size(rD_all,2)         
         fprintf(fid,'%f \t',OF_all(i));
     end
 else
     
    nb_iter = length(rD_all)/npara;
    for j = 1:npara
         fprintf(fid,'rD%i \t\t',j);
     end
     fprintf(fid,' \n');
     for j = 1:npara
         fprintf(fid,'OF wells rD%i \t',j);
     end
     fprintf(fid,'OF total');
     fprintf(fid,' \n');
     
     for i = 1:nb_iter    
         for j = 1:npara
             fprintf(fid,'%f \t',rD_all((i-1)*npara + j));
         end
         fprintf(fid,' \n');
         for j = 1:npara
         fprintf(fid,'%f \t',OF_wells(j,i));
         end
         fprintf(fid,'%f \t',OF_all(i));
         fprintf(fid,' \n');
         fprintf(fid,' \n');
     end
 end
 fclose(fid);
 
end
    