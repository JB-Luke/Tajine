% --- Multi-channel audio preprocessing script ---
clear; close all; clc;

%% Input/output parameters 
inputFile = [pwd, '/170325/170325-T004.WAV']; % input audio file
invSweepFile = 'INV-ESS.wav';

outputFolder = 'Mausoleo-Teodorico'; % folder name - id of the measured env
probeLabel = 'p2-ground-2';

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

% Trim
preDly      = 0.250*fs;
irNewLen    = 4*fs;

%% Monoaural
irMono = fd_conv(recSweep(:,monoCH),invSweep);
plotWaveform(irMono,fs);    % plot deconvolved data

[peakVal, peakIdx] = max(abs(irMono));   % get value and index of peak

% Highlight the found max value in plot
hold(gca,"on");
plot(peakIdx/fs,0,'Marker','o','MarkerSize',15,'LineWidth',2.5,'Color','red');
hold(gca,"off");

% Get trim parameters, do the trimming & rescale
iStart = peakIdx - preDly;           % start index for IR trim
iStop  = iStart + irNewLen - 1;      % stop index for IR trim

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

% Export
if ~exist(fullfile(outputFolder,monoDir), 'dir')
    mkdir(fullfile(outputFolder,monoDir));
end
outFile = fullfile(outputFolder, monoDir, sprintf('%s-MONO.wav', probeLabel));
audiowrite(outFile, irMonoTrim, fs);
fprintf('Exported: %s\n', outFile);

disp('✅ Impulse Response correctly exported.');

% Compute acoustic parameters with acouPar
% command = './AcouPar --pu filename_WY.wav';
% status = system(command);


%% Utility functions
function ax = plotWaveform(audioData,fs)

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