function ax = plotWaveform(audioData,fs,options)
% Plot multichannel audio data waveforms
arguments
    audioData
    fs
options.figNum = []
end

[nSamples,nChannels] = size(audioData);
maxAmp = max(max(abs(audioData))); % Get the maximum amplitude value

if isempty(options.figNum)
    figure();
else
    figure(options.figNum);
end

for ch = 1:nChannels
    subplot(nChannels,1,ch);
    plot((1:nSamples)/fs, audioData(:,ch));    
    ylabel(sprintf('CH%i',ch));
    ylim([-maxAmp maxAmp]);
    if ch == nChannels
        xlabel('Time [s]');
    end
end

ax = gca;

end