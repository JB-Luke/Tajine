% Copyright (c) 2025 Luca Battisti
% This file is part of the diaco project.
% Licensed under the BSD-3-Clause License. See the LICENSE file in the project root for details.

% --- Multi-channel audio preprocessing script ---
clear; close all; clc;

%% Input/output parameters 
inputFile = [pwd, '/170325/170325-T004.WAV']; % input audio file
invSweepFile = 'INV-ESS.wav';

outputFolder    = 'Mausoleo-Teodorico'; % folder name - id of the measured env
probeLabel      = 'p2-ground-2';

% Trim parameters
preDly      = 0.250;    % [s]
irTrimLen   = 4;        % [s]

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
pluginPath = '/Library/Audio/Plug-Ins/Components/Sennheiser AMBEO A-B format converter.component';
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

% Add the trimmed waveform to the figure
subplot(2,1,1,gca);
subplot(2,1,2);
plot((1:length(irMonoTrim))/fs,irMonoTrim)
xlabel('Time [s]');
title('Trimmed and rescaled IR of Monoaural microphone')

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
wy_signals = irBformatTrim(:,[1,2]);
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


%% Test plot

filename = "p2-ground-2-MONO.txt";
p2Tb = monoParTb(monoParTb.Filename == filename,:);
p2Tb_T30 = p2Tb(p2Tb.Parameter == "T30",:);
curveData = table2array(p2Tb_T30(:,...
    ["31_5","63","125","250","500","1000","2000","4000","8000","16000"]));
octaveBands = [31.5,63,125,250,500,1000,2000,4000,8000,16000];
figure
semilogx(octaveBands,curveData,'LineWidth',1.2)
ylim([-10,10])
grid on
ylabel(p2Tb_T30.Unit)
xlabel("Freq. [Hz]")
title("T30 - "+filename)

%% Export summarizing excel

outputExcelFile = fullfile(outputFolder,"calcs","calcs.xlsx");
writetable(monoParTb,outputExcelFile,'Sheet',1);
writetable(binParTb,outputExcelFile,'Sheet',2);


%% Utility functions
function [ir,peakVal] = deconvolve(recSweep,invSweep)

% Initialize
nChannels = size(recSweep,2);
invSweepLen = length(invSweep);
recSweepLen = length(recSweep);
irLen       = recSweepLen + invSweepLen - 1;
ir          = zeros(irLen,nChannels);

% Deconvolve 
for iCh = 1:nChannels
    ir(:,iCh) = fd_conv(recSweep(:,iCh),invSweep);
end

peakVal = max(abs(ir));
peakVal = max(peakVal);

% Rescale
ir = ir./peakVal;

end

function [irTrim,peakIdx] = trimIR(ir,fs,preDly,irDur)
% Trim the IR signal from its max peak value
[~, peakIdx] = max(abs(ir));   % get value and index of peak

if any(size(peakIdx) > 1)
    peakIdx = peakIdx(1);
end

% Get trim parameters, do the trimming & 
preDlySmpl = preDly * fs;
irLenSmpl = irDur * fs;
iStart = peakIdx - preDlySmpl;
iStop  = iStart + irLenSmpl - 1;

irTrim = ir(iStart:iStop,:);

end

function ax = plotWaveform(audioData,fs)
% Plot multichannel audio data waveforms
[nSamples,nChannels] = size(audioData);
maxAmp = max(max(abs(audioData))); % Get the maximum amplitude value

figure('Name','Waveforms','NumberTitle','off');
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

function outFile = exportAudio(audioData,fs,outFolder,outName)
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

outFile = fullfile(outFolder, sprintf('%s.wav', outName));
audiowrite(outFile, audioData, fs);

end

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

command = sprintf('./acou_par --%s %s',options.mode,irFile);
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

function parTb = transformTable(rawTb,concTb,probeName,options)
% convert acouPar raw output in a structured and manageble table
arguments
    rawTb table
    concTb table = table
    probeName cell = {}
    options.type string
end
    common_pars = {
        'Signal'
        'Noise'
        'strenGth'
        'C50'
        'C80'
        'D50'
        'ts'
        'EDT'
        'Tuser'
        'T20'
        'T30'
        };

    omni_pars = {
        'Peakiness'
        'Millisecs'
        'Impulsivs'
        };

    bin_pars = {
        'IACC'
        'Tau IACC'
        'w IACC'
        };

    common_unit = {
        'dB'
        'dB'
        'dB'
        'dB'
        'dB'
        '%'
        'ms'
        's'
        's'
        's'
        's'
        };

    omni_unit = {
        'dB'
        'dB'
        'dB'
        };

    bin_unit = {
        ''
        'ms'
        'ms'
        };

    if strcmp(options.type,"omni")
        pars = [common_pars; omni_pars];
        unit = [common_unit; omni_unit];
    elseif strcmp(options.type,"bin")
        pars = [common_pars; bin_pars];
        unit = [common_unit; bin_unit];
    else
        error("type not recognized")
    end

    bands = {'31_5', '63','125', '250', '500', ...
        '1000', '2000','4000','8000','16000','A','Lin'};

    bandNo = length(bands);
    parNo = length(pars);

    % Deal with exception values
    for iCol = 2:width(rawTb)
        if strcmp(rawTb{1,iCol},'--')
            varName = rawTb(1,iCol).Properties.VariableNames;
            rawTb.(varName{1,1}) = NaN;
        end
    end

    % Initialize new table
    varNames = [{'Filename', 'Parameter','Unit'}, bands];
    varTypes = cellstr([repmat("string", 1, 3), ...
        repmat("double",1,bandNo)]);

    parTb = table('Size', [0, length(varNames)], ...
        'VariableTypes', varTypes, 'VariableNames', varNames);

    if ~isempty(concTb)
        parTb = concTb;
    end
    if isempty(probeName)
        probeName = rawTb.Filename;
    end

    for iPar = 1:parNo
        parTb = [parTb;
            probeName, pars(iPar), unit(iPar),...
            num2cell(rawTb{:,2+(iPar-1)*bandNo:1+(iPar)*bandNo})];
    end
end

function parTb = readAcouPar(dataFolder,options)
% It read acouPar txt files in given a folder and generates a unique table
arguments
    dataFolder string
    options.type
end

txtFiles = dir(dataFolder);
parTb = table;
for iFile = 1:length(txtFiles)
    if strcmp(txtFiles(iFile).name,".") ...
        || strcmp(txtFiles(iFile).name,"..")
        continue
    end
    filename = txtFiles(iFile).name;
    txtFile = fullfile(dataFolder,filename);

    opts = detectImportOptions(txtFile);
    opts.VariableNames = replace(opts.VariableNames,'.','_');
    rawData = readtable(txtFile,opts);

    parTb = transformTable(rawData,parTb,cellstr(filename),type=options.type);
end

end