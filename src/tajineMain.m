% Copyright (c) 2025 Luca Battisti
% This file is part of Tajine software.
% Licensed under the BSD-3-Clause License. See the LICENSE file in the project root for details.

% --- Multi-channel audio preprocessing script ---

tajine = Tajine(); 

if ~exist("figureSet","var")
    figureSet = gobjects(12,1);
end

%% Input/output parameters 
measureSiteName = "Mausoleo-Teodorico"; % String to identify the measurement site

% String to identify the measurement point in relation with the audiofile
%
% The combination of pointId and acquisitionNo identifies a unique
% recording.
% areaId is employed to compute averages 

recInfo.positionId = 2; % Unique acquisition point (in space) identifier
recInfo.positionLabel = "ground1";
recInfo.acquisitionNo = 1;
recInfo.areaLabel = "ground_floor"; % underscore only is allowed between words

% acquisitionId = positionId + "-" + areaId + "-" + acquisitionNo;

% Input files
recFile = fullfile(pwd,"test_dataset","170325","170325-T004.WAV");
invSweepFile = fullfile(pwd,"test_dataset","INV-ESS.wav");

% Trim parameters
preDly      = 1; % s
irTrimLen   = 10; % s

% Transducers parameters & naming

%  Ambisonics B-Format microphone
transducers.bFormat.channels = 1:4;
transducers.bFormat.outDir= "B-FORMAT";

% Binaural microphone
transducers.binaural.channels = [5,6];
transducers.binaural.outDir = 'BINAURAL';

% Omni microphone
transducers.omni.channels = 7;
transducers.omni.outDir = 'OMNI';

if ismac
    pluginPath = '/Library/Audio/Plug-Ins/Components/Sennheiser AMBEO A-B format converter.component';
elseif ispc
    pluginPath = 'C:\Program Files\Common Files\VST3\Sennheiser AMBEO A-B format converter.vst3';
else
    error("Incompatible OS")
end

%% Set values to main object
tajine.measureSiteName = measureSiteName;

outputFolder = fullfile(pwd,"test_dataset",tajine.measureSiteName);
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
tajine.outputFolder = outputFolder;
outFolders = createOutFolders(outputFolder,transducers);

%% Read audio files
tajine.loadRecording(recFile); fprintf("\n");

tajine.loadInverseSweep(invSweepFile);

tajine.Recording = tajine.Recording.setInfo(recInfo);

recSweep = tajine.Recording;
invSweep = tajine.InverseSweep;
fs = recSweep.Fs;

plotWaveform(recSweep.Data,recSweep.Fs,figNum=1);

fprintf("\n✅ Input Files loaded.\n\n\n");

%% Extract IRs
[ir,aFormat] = extractIR(recSweep,invSweep,transducers,preDly,irTrimLen,pluginPath);

%% Export IRs
irFile = exportIR(ir,aFormat,fs,recSweep.AcquisitionString,outFolders);

%% Compute acoustic parameters with acouPar
computeParameters(irFile,recSweep.AcquisitionString,outFolders)
delete(irFile.wy); % Clean temporary generated WY B-Format output file

%% Import acoustic parameters (acouPar outputs)
parTb = importParameters(outFolders);

%% Export summarizing excel
outputExcelFile = fullfile(outputFolder,"calcs","calcs.xlsx");
writetable(parTb,outputExcelFile,'Sheet',1);
fprintf('MS Excel file written in ..%s\n',extractAfter(outputExcelFile,pwd));
fprintf('\n✅ Wrap-up Excel file generated.\n\n\n');

%% Plot
% Generate dedicated figures for each Acoustic parameter. 
% Add different curve for each probe
figureSet = plotResults(parTb,tajine.measureSiteName,figureSet);

fprintf('✅ Plot generation complete.\n\n');