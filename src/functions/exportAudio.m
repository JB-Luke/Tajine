function outFile = exportAudio(audioData,fs,outFolder,outName)
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

outFile = fullfile(outFolder, sprintf('%s.wav', outName));
audiowrite(outFile, audioData, fs);

end