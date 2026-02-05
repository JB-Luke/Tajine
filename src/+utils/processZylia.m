%% POST-PROCESSING OF ZYLIA MICROPHONE ACQUISITIONS %%

%% Loading

recSweep = gatherRecSweep();
if isempty(recSweep)
    fprintf("\nUser perform no file selection or an error occurred \n")
    return
end

invSweep = gatherInvSweep();

preDly = 1;
irTrimLen = 10;

if ismac
    pluginPath = '/Library/Audio/Plug-Ins/VST3/zylia-amb-plugin.vst3';
    % pluginPath = '/Library/Audio/Plug-Ins/Components/zylia-amb-plugin.component';
    % pluginPath = '/Library/Audio/Plug-Ins/VST/zylia-amb-plugin.vst';
elseif ispc
    pluginPath = 'C:\Program Files\Common Files\VST3\zylia-amb-plugin.vst3';
else
    error("Incompatible OS")
end

ambiXConvPlugin = loadAudioPlugin(pluginPath);
setSampleRate(ambiXConvPlugin,recSweep.Fs);

ir = utils.extractZyliaIR(recSweep,invSweep,preDly,irTrimLen,ambiXConvPlugin);

%% Export IR
[outpath,fullOutName] = fileparts(recSweep.FilePath);
irFileName = fullOutName+"-IR";
outputFolder = fullfile(outpath,"tajine-"+fullOutName);
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
outFile = exportAudio(ir.trimmed,recSweep.Fs,outputFolder,irFileName);

fprintf('Exported: %s\nin: %s\n\n',fullOutName,outputFolder);

fprintf('\n✅ Impulse Responses exported.\n\n\n');

%% Compute acoustic parameters with acouPar
% Export temporary W and WY IR files for AcouPar elaboration
irOmni = ir.trimmed(:,1);
irWY = ir.trimmed(:,1:2);
fs = recSweep.Fs;

irOmniFile = exportAudio(irOmni,fs,pwd,fullOutName+"-W");
irWYFile = exportAudio(irWY,fs,pwd,fullOutName+"-WY");

omniOutFolder = fullfile(outputFolder,"OMNI");
WYOutFolder = fullfile(outputFolder,"WY");
acouParProcess(irOmniFile,omniOutFolder,fullOutName,mode="omni");
acouParProcess(irWYFile,WYOutFolder,fullOutName,mode="wy");

fprintf('\n✅ Acoustic Parameters extracted with AcouPar.\n\n\n');

% Clean temporary generated files
delete(irOmniFile); 
delete(irWYFile); 

%% Import acoustic parameters (acouPar outputs)
txtFiles = dir(fullfile(omniOutFolder,'*.txt'));
omniTxtFile = fullfile(txtFiles.folder,txtFiles.name);
omniParTb = readAcouParTxt(omniTxtFile,"omni");

txtFiles = dir(fullfile(WYOutFolder,'*.txt'));
WYTxtFile = fullfile(txtFiles.folder,txtFiles.name);
WYParTb = readAcouParTxt(WYTxtFile,"wy");

parTb = [omniParTb; WYParTb];
fprintf("Acoustica parameters imported.\n");

matFileName = "dataset.mat";
matFile = fullfile(outputFolder,matFileName);
save(matFile,"parTb");
fprintf("Exported dataset: %s\nin: %s\n\n",matFileName,outputFolder);
fprintf('\n✅ Acoustic parameters imported.\n\n\n');

%% Export summarizing excel
xlsFileName = "calcs.xlsx";
outputExcelFile = fullfile(outputFolder,xlsFileName);
writetable(parTb,outputExcelFile,'Sheet',1);
fprintf('MS Excel file written in ..%s\nin: %s\n\n',xlsFileName,outputFolder);
fprintf('\n✅ Wrap-up Excel file generated.\n\n\n');

%% Generate  figures
figureSet = plotResults(parTb,fullOutName,gobjects(12),zyliaPlotSet=true);

%% Export figures
figOutFolder = fullfile(outputFolder,"figures");
if ~isfolder(figOutFolder)
    mkdir(figOutFolder);
end

for iFig = 1:length(figureSet)
    if ~ishghandle(figureSet(iFig)); continue; end
    figOutName = figureSet(iFig).Name;
    figOutFile = fullfile(figOutFolder,figOutName+".fig");
    saveas(figureSet(iFig),figOutFile);
end

%% Utility functions
function recording = gatherRecSweep()

[file,path] = uigetfile( ...
    fullfile(pwd,"*.*"), ...
    "Select Zylia Recording file...", 'MultiSelect','off');

if ~isnumeric(file)
    recording = Recording();
    recording.load(fullfile(path,file));
else
    recording = Recording.empty;
end

end


function invSweep = gatherInvSweep()

[file,path] = uigetfile( ...
    fullfile(pwd,"*.*"), ...
    "Select Zylia Recording file...", 'MultiSelect','off');

if ~isnumeric(file)
    invSweep = AudioFile();
    invSweep.load(fullfile(path,file));
else
    invSweep = AudioFile.empty;
end

end

function parTb = readAcouParTxt(txtFile,type)
acquisitionId = {sprintf('p1--1--%s',upper(type))};
opts = detectImportOptions(txtFile);
opts.VariableNames = replace(opts.VariableNames,'.','_');
rawData = readtable(txtFile,opts);

parTb = transformTable(rawData,table,acquisitionId,type=type);
end