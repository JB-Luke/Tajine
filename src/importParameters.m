function paramTable = importParameters(outFolders)
% To build the parameter table all the .txt file are read from the calcs 
% folder. Each probe point are added one time (not appended to the table)

monoParTb = readAcouPar(outFolders.calcs.omni,type="omni");
binParTb = readAcouPar(outFolders.calcs.binaural,type="bin");
bFormatParTb = readAcouPar(outFolders.calcs.bFormat,type="wy");

paramTable = [monoParTb; binParTb; bFormatParTb];
fprintf("Acoustica parameters imported.\n");

matFile = fullfile(outFolders.calcs.root,"dataset.mat");
save(matFile,"paramTable");
fprintf("Exported dataset: ..%s\n",extractAfter(matFile,pwd));
fprintf('\n✅ Acoustic parameters imported.\n\n\n');

end