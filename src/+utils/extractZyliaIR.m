function ir = extractZyliaIR(recSweep,invSweep,preDly,irLength,ambiXConvPlugin)

fs = recSweep.Fs;

%% Convert Zylia signals to HOA Ambisonics with external plugin
rawData = recSweep.Data;
if size(rawData,2) ~= 19
    error("Expected Zylia number of channels to be 19")
end

% Zylia AmbiX conversion plugin requires 32 input channels
rawData = [rawData, zeros(length(rawData),32-19)];

% Buffering input data
buffer = 2^15;
ambiXConvPlugin.setMaxSamplesPerFrame(buffer);

src = dsp.SignalSource;
src.SamplesPerFrame = buffer;
src.Signal = rawData;

idx = 1;
ambiXData = zeros(size(rawData));
fprintf('Converting to 3rd order ambisonics...\n\n');
while(~isDone(src))
    rows = (idx-1)*buffer+1:idx*buffer;
    ambiXData(rows,:) = process(ambiXConvPlugin,src());
    idx = idx + 1;
end

% Remove empty channels (3rd orde ambisonics has 16 channels)
ambiXData = ambiXData(:,1:16);

%% Deconvolve
fprintf('Deconvolving...\n\n');
[ir.full,peakVal] = deconvolve(ambiXData,invSweep.Data);
w = ir.full(:,1);
[w_trim,peakIdx] = trimIR(w,fs,preDly,irLength);
ir.trimmed = [w_trim, trimIR(ir.full(:,2:end),fs,preDly,irLength,maxIdx=peakIdx)];

fprintf('Applied rescaling gain: %.2f dB to IR signal\n', ...
    20*log10(1/peakVal));

%% Energy signal
e = abs(ir.trimmed(:,1)).^2;

freq = 63;
b = (freq/fs)*ones(1,round(fs/freq));
eFilt = filter(b, 1, e);

% Portion of background noise signal per IR peak
window = 1:(preDly*0.85)*fs; 
eBackNoiseAvg = mean(e(window)); % Average of background noise

%% Plot
plotIR(ir,peakIdx,eFilt,eBackNoiseAvg,fs)

fprintf('\n✅ Impulse Responses generated.\n\n\n');

end

function plotIR(ir,peakIdx,eFilt,eBackNoiseAvg,fs)

% Extract W data
irFull = ir.full(:,1);
irTrim = ir.trimmed(:,1);

% Plot
plotWaveform(irFull(:,1),fs,figNum=2);
hold(gca,"on");

% Highlight selected Impulse Response
plot(peakIdx/fs,0,'Marker','o','MarkerSize',15,'LineWidth',2.5,'Color','red');
hold(gca,"off");

% Add the trimmed waveform to the figure
subplot(3,1,1,gca);
subplot(3,1,2);
plot((1:length(irTrim))/fs,irTrim);
title('Trimmed and rescaled IR of Monoaural microphone')

% Add the energy signal to the figure
subplot(3,1,3);
plot((1:length(irTrim))/fs,20*log10(eFilt)); hold on;

% Add a y value to put in evidence the background noise energy
% (this is useful to check if the IR is long enough)
yline(20*log10(eBackNoiseAvg)); hold off;
title('Energy of the IR and background noise');
xlabel('Time [s]');

end