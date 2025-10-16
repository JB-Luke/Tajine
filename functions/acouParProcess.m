function acouParProcess(irFile,outFolder,outName,options)
arguments
    irFile string
    outFolder string
    outName string
    options.mode string
end

if strcmp(options.mode,"omni")
    outLabel = "MONO";
    orgTxtFile = 'acoupar_omni.txt';
elseif strcmp(options.mode,"bin")
    outLabel = "BIN";
    orgTxtFile = 'acoupar_BIN.txt';
elseif strcmp(options.mode,"wy")
    outLabel = "BFormat";
    orgTxtFile = 'acoupar_WY.txt';
else
    error("AcouPar elaboration mode not recognized")
end


command = sprintf('./AcouPar/mac/acou_par --%s %s',options.mode,irFile);
[status,cmdout] = system(command);

% If acoustic parameters extraction went correctly, move the file
if status == 0
    fprintf("acouPar analysed successfully %s\n",irFile);
    if ~exist(outFolder, 'dir')
        mkdir(outFolder);
    end
    newFileName = sprintf('%s-%s.txt', outName,outLabel);
    newFilePath = fullfile(outFolder, newFileName);
    movefile(orgTxtFile,newFilePath)
else
    warning("acouPar failed to analyse %s\n\t with output: \t%s",irFile,cmdout)
end

end