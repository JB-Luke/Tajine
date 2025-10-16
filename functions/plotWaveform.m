function ax = plotWaveform(audioData,fs)
% Plot multichannel audio data waveforms
[nSamples,nChannels] = size(audioData);
maxAmp = max(max(abs(audioData))); % Get the maximum amplitude value

figure();
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