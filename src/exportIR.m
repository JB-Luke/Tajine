function outFile = exportIR(ir,aFormat,fs,outName,outFolders)
% Export impulse response

% Omni IR 
fullOutName = sprintf('%s-omni', outName);
audioData = ir.omni.trimmed;
outputFolder = outFolders.ir.omni;
outFile.omni = exportAudio(audioData,fs,outputFolder,fullOutName);
fprintf('Exported: %s\n', outFile.omni);

% Binaural IR
fullOutName = sprintf('%s-BIN', outName);
audioData = ir.binaural.trimmed;
outputFolder = outFolders.ir.binaural;
outFile.binaural = exportAudio(audioData,fs,outputFolder,fullOutName);
fprintf('Exported: %s\n', outFile.binaural);

% A-Format audio
if ~isempty(aFormat)
    aFormatOutFolder = fullfile(outputFolder,'A-Format');
    fullOutName = sprintf('%s-Aformat', outName);
    outFile.aFormat = exportAudio(aFormat,fs,aFormatOutFolder,fullOutName);
    fprintf('Exported: %s\n', outFile.aFormat);
else
    fprintf('No A-Format available for exporting.\n');
end

% B-Format IR
fullOutName = sprintf('%s-Bformat', outName);
audioData = ir.bFormat.trimmed;
outputFolder = outFolders.ir.bFormat;
outFile.bFormat = exportAudio(audioData,fs,outputFolder,fullOutName);
fprintf('Exported: %s\n', outFile.bFormat);

% B-Format IR - WY channels only
wyBformat = ir.bFormat.trimmed(:,[4,3]);
wyOutFolder = fullfile(outFolders.ir.root,"WY");
fullOutName = sprintf("%s-WY",outName);
outFile.wy = exportAudio(wyBformat,fs,wyOutFolder,fullOutName);

fprintf('\n✅ Impulse Responses exported.\n\n\n');

end