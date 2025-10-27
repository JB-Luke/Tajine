% Copyright (c) 2025 Luca Battisti
% This file is part of Tajine software.
% Licensed under the BSD-3-Clause License. See the LICENSE file in the project root for details.

% --- Multi-channel audio preprocessing script ---
clear; close all; clc;

addpath(genpath("functions"));
addpath(genpath("AcouPar"));

disp("Tajine "+runtimeVersionString);

v = getVersion();
if ~strcmp("v"+v.semver,v.gitTag)
    warning("Local version differs from git tag")
end

%% Input/output parameters 
inputFile = fullfile(pwd,'170325','170325-T004.WAV'); % input audio file
invSweepFile = 'INV-ESS.wav';

outputFolder    = 'Mausoleo-Teodorico'; % folder name - id of the measured env
probeLabel      = 'p2-ground-floor-2';

% Trim parameters
preDly      = 0.5;    % [s]
irTrimLen   = 8;        % [s]

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

% Create output folders
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

irOutFolder = fullfile(outputFolder,'IRs');
if ~exist(irOutFolder, 'dir')
    mkdir(irOutFolder);
end

calcsOutFolder = fullfile(outputFolder,'calcs');
if ~exist(calcsOutFolder, 'dir')
    mkdir(calcsOutFolder);
end

aFormatOutFolder = fullfile(outputFolder,'A-Format');

%% Read audio files
disp(['Loading input multichannel file: ' inputFile]);
[recSweep, fs] = audioread(inputFile);  
[nSamples, nChannels] = size(recSweep);

fprintf('Samples: %d, Channels: %d, Sample rate: %d Hz\n', nSamples, nChannels, fs);

disp(['Loading inverse sweep file: ' invSweepFile]);
[invSweep,~] = audioread(invSweepFile);

plotWaveform(recSweep,fs);

disp('✅ Input Files loaded.');

%% --- Post-Processing to get IR  ---
% Monoaural 
[irMono,peakValMono] = deconvolve(recSweep(:,monoCH),invSweep);
[irMonoTrim,peakIdxMono] = trimIR(irMono,fs,preDly,irTrimLen);

fprintf('Applied rescaling gain: %.2f dB to MONOAURAL signal\n', ...
    20*log10(1/peakValMono));

% Binaural
[irBin,peakValBin] = deconvolve(recSweep(:,binCH),invSweep);
irBinTrim = trimIR(irBin,fs,preDly,irTrimLen);

fprintf('Applied rescaling gain: %.2f dB to BINAURAL signal\n', ...
    20*log10(1/peakValBin));

% B-format
bformatConvPlugin = loadAudioPlugin(pluginPath);
bformatConvPlugin.CoincidenceFilter = "off";
bformatConvPlugin.Position = 'Endfire';

aFormat = recSweep(:,bFormatCH);
bformatConvPlugin.setMaxSamplesPerFrame(length(recSweep));
bFormat = process(bformatConvPlugin,aFormat);

[irBformat,peakValBin] = deconvolve(bFormat,invSweep);
irBformatTrim = trimIR(irBformat,fs,preDly,irTrimLen);

% Plot mono mic data
plotWaveform(irMono,fs);
hold(gca,"on");

% Highlight selected Impulse Response
plot(peakIdxMono/fs,0,'Marker','o','MarkerSize',15,'LineWidth',2.5,'Color','red');
hold(gca,"off");

e = abs(irMonoTrim).^2;
noise_samples = (preDly*0.95)*fs; % close to the peak
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
plotWaveform(irBformatTrim,fs);

disp('✅ Impulse Responses generated.');

%% Export
irMonoOutFolder = fullfile(irOutFolder,monoDir);
outName = sprintf('%s-MONO', probeLabel);
outMonoFile = exportAudio(irMonoTrim,fs,irMonoOutFolder,outName);
fprintf('Exported: %s\n', outMonoFile);

irBinOutFolder = fullfile(irOutFolder,binDir);
outName = sprintf('%s-BIN', probeLabel);
outBinFile = exportAudio(irBinTrim,fs,irBinOutFolder,outName);
fprintf('Exported: %s\n', outBinFile);

outName = sprintf('%s-Aformat', probeLabel);
outAformatFile = exportAudio(aFormat,fs,aFormatOutFolder,outName);
fprintf('Exported: %s\n', outAformatFile);

bFormatOutFolder = fullfile(irOutFolder,bFormatDir);
outName = sprintf('%s-Bformat', probeLabel);
outBformatFile = exportAudio(bFormat,fs,bFormatOutFolder,outName);
fprintf('Exported: %s\n', outBformatFile);

disp('✅ Impulse Responses correctly exported.');

%% Compute acoustic parameters with acouPar
% --- Monoaural ---
calcsMonoOutFolder = fullfile(calcsOutFolder,monoDir);
if ~exist(calcsMonoOutFolder, 'dir')
    mkdir(calcsMonoOutFolder);
end
acouParProcess(outMonoFile,calcsMonoOutFolder,probeLabel,mode="omni");

% --- Binaural ---
calcsBinOutFolder = fullfile(calcsOutFolder,binDir);
if ~exist(calcsBinOutFolder, 'dir')
    mkdir(calcsBinOutFolder);
end
acouParProcess(outBinFile,calcsBinOutFolder,probeLabel,mode="bin");

% --- B-Format ---
% WY ambix data is required for lateral fraction extraction with AcouPar
wy_signals = irBformatTrim(:,[2,1]);
wyFileName = sprintf("%s-WY",probeLabel);
wyFile = exportAudio(wy_signals,fs,pwd,wyFileName);

calcsBformatOutFolder = fullfile(calcsOutFolder,bFormatDir);
if ~exist(calcsBformatOutFolder, 'dir')
    mkdir(calcsBformatOutFolder);
end
acouParProcess(wyFile,calcsBformatOutFolder,probeLabel,mode="wy");

delete(wyFile);

disp('✅ Acoustic Parameters extracted with AcouPar.');

%% Read acouPar outputs

monoParTb = readAcouPar(calcsMonoOutFolder,type="omni");
binParTb = readAcouPar(calcsBinOutFolder,type="bin");
bFormatParTb = readAcouPar(calcsBformatOutFolder,type="wy");

%% Test plot
filename = "p2-ground-floor-2";
param = "Lj";

pointTb = bFormatParTb(contains(bFormatParTb.Filename,filename),:);
p2Tb_param = pointTb(pointTb.Parameter == param,:);
curveData = table2array(p2Tb_param(:,...
    ["31_5","63","125","250","500","1000","2000","4000","8000","16000"]));
octaveBands = [31.5,63,125,250,500,1000,2000,4000,8000,16000];
figure
semilogx(octaveBands,curveData,'LineWidth',1.2)
% ylim([-10,10])
grid on
ylabel(p2Tb_param.Unit)
xlabel("Freq. [Hz]")
title(param + " - " + filename)

%% Export summarizing excel

outputExcelFile = fullfile(outputFolder,"calcs","calcs.xlsx");
writetable(monoParTb,outputExcelFile,'Sheet',1);
writetable(binParTb,outputExcelFile,'Sheet',2);
writetable(bFormatParTb,outputExcelFile,'Sheet',3);