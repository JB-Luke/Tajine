% Copyright (c) 2025 Luca Battisti
% This file is part of Tajine software.
% Licensed under the BSD-3-Clause License. See the LICENSE file in the project root for details.

% --- Multi-channel audio preprocessing script ---
testMode = true;

% Diplay version
disp("Tajine "+runtimeVersionString());

v = getVersion();
if ~strcmp("v"+v.semver,v.gitTag)
    warning("Local version differs from git tag")
end

fprintf("\n");

%% Input/output parameters 

siteName = "Mausoleo-Teodorico"; % String to identify the measurement site

% String to identify the measurement point in relation with the audiofile
% probeId = "p2-ground-floor-2";
probeId      = 'p3-first-floor-1'; 

addPlot = false; % set to true to add different measure point(s) to figures

% Input files
inputFile = fullfile(pwd,"test_dataset","170325(1)","170325-T001.WAV"); % input audio file
invSweepFile = fullfile(pwd,"test_dataset","INV-ESS.wav");

% Trim parameters
preDly      = 1; % s
irTrimLen   = 10; % s

% Transducers parameters & naming

%  Ambisonics B-Format microphone
bFormatCH = 1:4;
bFormatDir= "B-FORMAT";

% Binaural microphone
binCH = [5,6];
binDir = 'BINAURAL';

% Mono microphone
monoCH = 7;
monoDir = 'MONOAURAL';

if ismac
    pluginPath = '/Library/Audio/Plug-Ins/Components/Sennheiser AMBEO A-B format converter.component';
elseif ispc
    pluginPath = 'C:\Program Files\Common Files\VST3\Sennheiser AMBEO A-B format converter.vst3';
else
    error("Incompatible OS")
end

tajine = Tajine(siteName);  % instance of main object 
rec = Recording();
rec.Name = probeId;

if ~exist("figureSet","var")
    figureSet = gobjects(12,1);
end

%% Read audio files

rec = rec.load(inputFile);
fs = rec.Fs;

fprintf("\n");
invSweep = rec.load(invSweepFile);

plotWaveform(rec.Data,fs,figNum=1);

fprintf("\n✅ Input Files loaded.\n\n\n");

%% --- Post-Processing to get IR  ---
% Monoaural 
[irMono,peakValMono] = deconvolve(rec.Data(:,monoCH),invSweep.Data);
[irMonoTrim,peakIdxMono] = trimIR(irMono,fs,preDly,irTrimLen);

fprintf('Applied rescaling gain: %.2f dB to MONOAURAL signal\n', ...
    20*log10(1/peakValMono));

% Binaural
[irBin,peakValBin] = deconvolve(rec.Data(:,binCH),invSweep.Data);
irBinTrim = trimIR(irBin,fs,preDly,irTrimLen);

fprintf('Applied rescaling gain: %.2f dB to BINAURAL signal\n', ...
    20*log10(1/peakValBin));

% B-format
bformatConvPlugin = loadAudioPlugin(pluginPath);
bformatConvPlugin.CoincidenceFilter = "off";
bformatConvPlugin.Position = 'Endfire';

aFormat = rec.Data(:,bFormatCH);
bformatConvPlugin.setMaxSamplesPerFrame(length(rec.Data));
bFormat = process(bformatConvPlugin,aFormat);

[irBformat,peakValBin] = deconvolve(bFormat,invSweep.Data);
irBformatTrim = trimIR(irBformat,fs,preDly,irTrimLen);

% Plot mono mic data
plotWaveform(irMono,fs,figNum=2);
hold(gca,"on");

% Highlight selected Impulse Response
plot(peakIdxMono/fs,0,'Marker','o','MarkerSize',15,'LineWidth',2.5,'Color','red');
hold(gca,"off");

e = abs(irMonoTrim).^2;
noise_samples = (preDly*0.85)*fs; % close to the peak
e_noise = mean(e(1:noise_samples));

freq = 63;
b = (freq/fs)*ones(1,round(fs/freq));
e_filt = filter(b, 1, e);

% Add the trimmed waveform to the figure
subplot(3,1,1,gca);
subplot(3,1,2);
plot((1:length(irMonoTrim))/fs,irMonoTrim);
title('Trimmed and rescaled IR of Monoaural microphone')
subplot(3,1,3);
plot((1:length(irMonoTrim))/fs,20*log10(e_filt)); hold on;
% plot((1:noise_samples)/fs,e(1:noise_samples)); hold on
yline(20*log10(e_noise)); hold off;
title('Energy of the IR and background noise');
xlabel('Time [s]');

% Plot b-format elaborated IRs
plotWaveform(irBformatTrim,fs,figNum=3);

fprintf('\n✅ Impulse Responses generated.\n\n\n');

%% Export
% Create output folders
outputFolder = fullfile(pwd,"test_dataset",tajine.site_name);

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

irOutFolder = fullfile(outputFolder,'IRs');
if ~exist(irOutFolder, 'dir')
    mkdir(irOutFolder);
end

aFormatOutFolder = fullfile(outputFolder,'A-Format');

% Export data
irMonoOutFolder = fullfile(irOutFolder,monoDir);
outName = sprintf('%s-MONO', probeId);
outMonoFile = exportAudio(irMonoTrim,fs,irMonoOutFolder,outName);
fprintf('Exported: %s\n', outMonoFile);

irBinOutFolder = fullfile(irOutFolder,binDir);
outName = sprintf('%s-BIN', probeId);
outBinFile = exportAudio(irBinTrim,fs,irBinOutFolder,outName);
fprintf('Exported: %s\n', outBinFile);

outName = sprintf('%s-Aformat', probeId);
outAformatFile = exportAudio(aFormat,fs,aFormatOutFolder,outName);
fprintf('Exported: %s\n', outAformatFile);

bFormatOutFolder = fullfile(irOutFolder,bFormatDir);
outName = sprintf('%s-Bformat', probeId);
outBformatFile = exportAudio(bFormat,fs,bFormatOutFolder,outName);
fprintf('Exported: %s\n', outBformatFile);

fprintf('\n✅ Impulse Responses exported.\n\n\n');

%% Compute acoustic parameters with acouPar
calcsOutFolder = fullfile(outputFolder,'calcs');
if ~exist(calcsOutFolder, 'dir')
    mkdir(calcsOutFolder);
end

% --- Monoaural ---
calcsMonoOutFolder = fullfile(calcsOutFolder,monoDir);
if ~exist(calcsMonoOutFolder, 'dir')
    mkdir(calcsMonoOutFolder);
end
acouParProcess(outMonoFile,calcsMonoOutFolder,probeId,mode="omni");

% --- Binaural ---
calcsBinOutFolder = fullfile(calcsOutFolder,binDir);
if ~exist(calcsBinOutFolder, 'dir')
    mkdir(calcsBinOutFolder);
end
acouParProcess(outBinFile,calcsBinOutFolder,probeId,mode="bin");

% --- B-Format ---
% WY ambix data is required for lateral fraction extraction with AcouPar
wy_signals = irBformatTrim(:,[2,1]);
wyFileName = sprintf("%s-WY",probeId);
wyFile = exportAudio(wy_signals,fs,pwd,wyFileName);

calcsBformatOutFolder = fullfile(calcsOutFolder,bFormatDir);
if ~exist(calcsBformatOutFolder, 'dir')
    mkdir(calcsBformatOutFolder);
end
acouParProcess(wyFile,calcsBformatOutFolder,probeId,mode="wy");

delete(wyFile);

fprintf('\n✅ Acoustic Parameters extracted with AcouPar.\n\n\n');

%% Read acouPar outputs
% To build the parameter table all the .txt file are read from the calcs 
% folder. Each probe point are added one time (not appended to the table)
monoParTb = readAcouPar(calcsMonoOutFolder,type="omni");
binParTb = readAcouPar(calcsBinOutFolder,type="bin");
bFormatParTb = readAcouPar(calcsBformatOutFolder,type="wy");

parTb = [monoParTb; binParTb; bFormatParTb];
matFile = fullfile(calcsOutFolder,"dataset.mat");
save(matFile,"parTb");
fprintf("Exported dataset: ..%s\n",extractAfter(matFile,pwd));
fprintf('\n✅ Matlab dataset file exported.\n\n\n');

%% Export summarizing excel

outputExcelFile = fullfile(outputFolder,"calcs","calcs.xlsx");
writetable(monoParTb,outputExcelFile,'Sheet',1);
writetable(binParTb,outputExcelFile,'Sheet',2);
writetable(bFormatParTb,outputExcelFile,'Sheet',3);
fprintf('MS Excel file written in ..%s\n',extractAfter(outputExcelFile,pwd));
fprintf('\n✅ Wrap-up Excel file generated.\n\n\n');

%% Plot
% Generate dedicated figures for each Acoustic parameter. 
% Add different curve for each probe

figureSet = plotResults(parTb,siteName,figureSet);

fprintf('✅ Plot generation complete.\n\n');