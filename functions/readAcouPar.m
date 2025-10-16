function parTb = readAcouPar(dataFolder,options)
% It read acouPar txt files in given a folder and generates a unique table
arguments
    dataFolder string
    options.type
end

txtFiles = dir(dataFolder);
parTb = table;
for iFile = 1:length(txtFiles)
    if strcmp(txtFiles(iFile).name,".") ...
        || strcmp(txtFiles(iFile).name,"..")
        continue
    end
    filename = txtFiles(iFile).name;
    txtFile = fullfile(dataFolder,filename);

    opts = detectImportOptions(txtFile);
    opts.VariableNames = replace(opts.VariableNames,'.','_');
    rawData = readtable(txtFile,opts);

    parTb = transformTable(rawData,parTb,cellstr(filename),type=options.type);
end

end