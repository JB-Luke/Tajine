function acouParProcess(irFile,outFolder,outName,options)
arguments
    irFile string
    outFolder string
    outName string
    options.mode string
end

irFileShort = ".." + extractAfter(irFile,pwd);

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


if ismac
    acouParFile = fullfile("external","AcouPar","mac","acou_par");
    command = sprintf('./%s --%s %s',acouParFile,options.mode,irFile);
elseif ispc
    acouParFile = fullfile("external","AcouPar","win","acou_par.exe");
    command = sprintf('.\\%s --%s %s',acouParFile,options.mode,irFile);
else
    error("Incompatible OS");
end

[status,cmdout] = system(command);

% If acoustic parameters extraction went correctly, move the file
if status == 0
    fprintf("acouPar analysed successfully %s\n",irFileShort);
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