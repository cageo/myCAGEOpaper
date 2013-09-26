prefix = 'HGSSimul';
piezo = zeros(9,1);
for i=1:9
    inputfile = [prefix 'o.observation_well_flow.P' num2str(i) '.dat'];
    piezo(i)=read_HGS_well(inputfile,'H');
end
piezo