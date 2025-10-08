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

% Create output folder if it does not exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
if ~exist(fullfile(outputFolder,'IRs'), 'dir')
    mkdir(fullfile(outputFolder,'IRs'));
end
if ~exist(fullfile(outputFolder,'calcs'), 'dir')
    mkdir(fullfile(outputFolder,'calcs'));
end

%% Read audio files
disp(['Loading input multichannel file: ' inputFile]);
[recSweep, fs] = audioread(inputFile);  
[nSamples, nChannels] = size(recSweep);

fprintf('Samples: %d, Channels: %d, Sample rate: %d Hz\n', nSamples, nChannels, fs);

disp(['Loading inverse sweep file: ' invSweepFile]);
[invSweep,~] = audioread(invSweepFile);

plotWaveform(recSweep,fs);

% Ask user confirmation before proceeding
choice = questdlg('Do you want to continue with processing?', ...
                  'Confirmation', ...
                  'Yes','No','Yes');

% Handle response
switch choice
    case 'Yes'
        disp('✅ Proceeding with processing...');
    case 'No'
        disp('❌ Processing aborted by user.');
        return   % stop script here
end


%% --- Processing Parameters ---

% Deconvolution

invSweepLen = length( invSweep );
recSweepLen = length( recSweep );
irLen       = recSweepLen + invSweepLen - 1;
ir          = zeros( irLen, nChannels );    % pre-allocate matrix for IRs

% Monoaural
irMono = fd_conv(recSweep(:,monoCH),invSweep);
plotWaveform(irMono,fs);    % plot deconvolved data

[peakVal, peakIdx] = max(abs(irMono));   % get value and index of peak

% Highlight the found max value in plot
hold(gca,"on");
plot(peakIdx/fs,0,'Marker','o','MarkerSize',15,'LineWidth',2.5,'Color','red');
hold(gca,"off");

% Get trim parameters, do the trimming & rescale
preDlySmpl = preDly * fs;
irLenSmpl = irTrimLen * fs;
iStart = peakIdx - preDlySmpl;           % start index for IR trim
iStop  = iStart + irLenSmpl - 1;      % stop index for IR trim

irMonoTrim = irMono(iStart:iStop);
irMonoTrim = irMonoTrim/peakVal;

log = sprintf('Applied rescaling gain: %.2f dB',20*log10(1/peakVal));
disp(log);

% Add the trimmed waveform to the figure
subplot(2,1,1,gca);
subplot(2,1,2);
plot((1:length(irMonoTrim))/fs,irMonoTrim)
xlabel('Time [s]');
title('Trimmed and rescaled IR of Monoaural microphone')

% Ask user confirmation before proceeding
choice = questdlg('Do you want to continue with processing?', ...
                  'Confirmation', ...
                  'Yes','No','Yes');

% Handle response
switch choice
    case 'Yes'
        disp('✅ Proceeding with processing...');
    case 'No'
        disp('❌ Processing aborted by user.');
        return   % stop script here
end

%% Export
if ~exist(fullfile(outputFolder,'IRs',monoDir), 'dir')
    mkdir(fullfile(outputFolder,'IRs',monoDir));
end

outIRFile = fullfile(outputFolder, 'IRs', monoDir, sprintf('%s-MONO.wav', probeLabel));
audiowrite(outIRFile, irMonoTrim, fs);
fprintf('Exported: %s\n', outIRFile);

disp('✅ Impulse Response correctly exported.');

%% Compute acoustic parameters with acouPar
command = sprintf('./acou_par --omni %s',outIRFile);
status = system(command);

% If acoustic parameters extraction went correctly, move the file
if status == 0
    if ~exist(fullfile(outputFolder,'calcs',monoDir), 'dir')
        mkdir(fullfile(outputFolder,'calcs',monoDir));
    end
    acouParFileDst = fullfile(outputFolder, 'calcs', monoDir, sprintf('%s-MONO.txt', probeLabel));
    movefile('acoupar_omni.txt',acouParFileDst)
end

%% Read acouPar outputs and generate excel
parentFolder = fullfile(outputFolder,"calcs","MONOAURAL");
acouParFiles = dir(parentFolder);

acouParTb = table;
for iFile = 1:length(acouParFiles)
    if strcmp(acouParFiles(iFile).name,".") || strcmp(acouParFiles(iFile).name,"..")
        continue
    end
    filename = acouParFiles(iFile).name;
    acouParFile = fullfile(parentFolder,filename);
    opts = detectImportOptions(acouParFile);
    opts.VariableNames = replace(opts.VariableNames,'.','_');
    rawAcouData = readtable(acouParFile,opts);

    acouParTb = transformTable(rawAcouData,acouParTb,cellstr(filename));
end

%% Test plot
p2Tb = acouParTb(acouParTb.Filename == "p1-ground-1-MONO.txt",:);
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
writetable(acouParTb,outputExcelFile,'Sheet',1);


%% Utility functions
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


function parTb = transformTable(rawTb,concTb,probeName)
% convert acouPar raw output in a structured and manageble table
arguments
    rawTb table
    concTb table = table
    probeName cell = {}
end
    acouPars = {
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
        'Peakiness'
        'Millisecs'
        };

    unit = {
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
        'dB'
        'dB'
        'dB'
        };
    bands = {'31_5', '63','125', '250', '500', ...
        '1000', '2000','4000','8000','16000','A','Lin'};

    bandNo = length(bands);
    parNo = length(acouPars);

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
            probeName, acouPars(iPar), unit(iPar),...
            num2cell(rawTb{:,2+(iPar-1)*bandNo:1+(iPar)*bandNo})];
    end
end