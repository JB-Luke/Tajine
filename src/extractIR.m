function [ir,aFormat] = extractIR(recSweep,invSweep,transducers,preDly,irLength,pluginPath,options)
arguments
    recSweep
    invSweep
    transducers
    preDly
    irLength
    pluginPath
    options.Convert2BFormat = true
end

fs = recSweep.Fs;

%% Omni 
channels = transducers.omni.channels;
[ir.omni.full,peakValOmni] = deconvolve(recSweep.Data(:,channels),invSweep.Data);
[ir.omni.trimmed,peakIdxOmni] = trimIR(ir.omni.full,fs,preDly,irLength);

fprintf('Applied rescaling gain: %.2f dB to MONOAURAL signal\n', ...
    20*log10(1/peakValOmni));

en = abs(ir.omni.trimmed).^2;
noiseSignal = (preDly*0.85)*fs; % background noise signal before IR peak
enNoise = mean(en(1:noiseSignal));

freq = 63;
b = (freq/fs)*ones(1,round(fs/freq));
enNoiseFilt = filter(b, 1, en);

%% Binaural
channels = transducers.binaural.channels;
[ir.binaural.full,peakValBin] = deconvolve(recSweep.Data(:,channels),invSweep.Data);
ir.binaural.trimmed = trimIR(ir.binaural.full,fs,preDly,irLength,maxIdx=peakIdxOmni);

fprintf('Applied rescaling gain: %.2f dB to BINAURAL signal\n', ...
    20*log10(1/peakValBin));

%% B-format
% Convert A-Format to B-Format Ambisonics with external plugin
channels = transducers.bFormat.channels;

if options.Convert2BFormat
    aFormat = recSweep.Data(:,channels);

    % Load and setup plugin
    bformatConvPlugin = loadAudioPlugin(pluginPath);
    bformatConvPlugin.CoincidenceFilter = "off";
    bformatConvPlugin.Position = 'Endfire';
    bformatConvPlugin.setMaxSamplesPerFrame(16384);

    audioSrc = dsp.SignalSource(aFormat, SamplesPerFrame=16384);

    bFormat = [];
    while(~audioSrc.isDone)
        bFormat = [bFormat; bformatConvPlugin.process(audioSrc())];
    end
else
    aFormat = [];
    bFormat = recSweep.Data(:,channels);
end

% Deconvolve
[ir.bFormat.full,peakValBformat] = deconvolve(bFormat,invSweep.Data);
ir.bFormat.trimmed = trimIR(ir.bFormat.full,fs,preDly,irLength,maxIdx=peakIdxOmni);

fprintf('Applied rescaling gain: %.2f dB to B-FORMAT signal\n', ...
    20*log10(1/peakValBformat));

%% Plot

plotIR(ir,peakIdxOmni,enNoiseFilt,enNoise,fs)

fprintf('\n✅ Impulse Responses generated.\n\n\n');

end


function plotIR(ir,peakIdxMono,enNoiseFilt,enNoise,fs)

irFull = ir.omni.full;
irTrim = ir.omni.trimmed;

% Plot omni mic data
plotWaveform(irFull,fs,figNum=2);
hold(gca,"on");

% Highlight selected Impulse Response
plot(peakIdxMono/fs,0,'Marker','o','MarkerSize',15,'LineWidth',2.5,'Color','red');
hold(gca,"off");

% Add the trimmed waveform to the figure
subplot(3,1,1,gca);
subplot(3,1,2);
plot((1:length(irTrim))/fs,irTrim);
title('Trimmed and rescaled IR of Monoaural microphone')

% Add the energy signal to the figure
subplot(3,1,3);
plot((1:length(irTrim))/fs,20*log10(enNoiseFilt)); hold on;

% Add a y value to put in evidence the background noise energy
% (this is useful to check if the IR is long enough)
yline(20*log10(enNoise)); hold off;
title('Energy of the IR and background noise');
xlabel('Time [s]');

% Plot b-format elaborated IRs
plotWaveform(ir.bFormat.trimmed,fs,figNum=3);

end