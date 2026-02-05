% Copyright (c) 2025 Luca Battisti
% This file is part of Tajine software.
% Licensed under the BSD-3-Clause License. See the LICENSE file in the project root for details.

function process(obj)
%% Input/output parameters 

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

outputFolder = fullfile(pwd,"test_dataset",obj.MeasureSiteName);
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
obj.OutputFolder = outputFolder;
outFolders = createOutFolders(outputFolder,transducers);

%% Read audio files

recSweep = obj.Recording;
invSweep = obj.InverseSweep;
fs = recSweep.Fs;

plotWaveform(recSweep.Data,recSweep.Fs,figNum=1);

fprintf("\n✅ Input Files loaded.\n\n\n");

%% Extract IRs
[ir,aFormat] = extractIR( ...
    recSweep, ...
    invSweep, ...
    transducers, ...
    preDly, ...
    irTrimLen, ...
    pluginPath, ...
    Convert2BFormat=false);

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
if isempty(obj.figureSet) || any(~isvalid(obj.figureSet))
    obj.figureSet = gobjects(12,1);
end

obj.figureSet = plotResults(parTb,obj.MeasureSiteName,obj.figureSet);

fprintf('✅ Plot generation complete.\n\n');

end