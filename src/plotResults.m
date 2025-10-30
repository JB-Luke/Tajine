function figureSet = plotResults(parTb,plotTitle,figureSet)
%%PLOTRESULTS set generation %
% It generates a set figure given a specific table and a set of filters.
%
% The figures show the main ISO 3382-1:2009 acoustic parameters 
arguments
    parTb              % parameter table
    plotTitle
    figureSet
end

probeIdSuffix.mono = "-MONO.txt";
probeIdSuffix.bin = "-BIN.txt";
probeIdSuffix.bformat = "-BFormat.txt";

filenames = parTb.Filename;
probeIdSet = getProbeIdSet(filenames,probeIdSuffix);

for iProbe = 1:length(probeIdSet)
    if iProbe == 1 
        append = false;
    else
        append = true;
    end

    figureSet = createFigures(parTb,probeIdSet(iProbe),probeIdSuffix,plotTitle,append=append,figureSet=figureSet);
end

    function probeIdSet = getProbeIdSet(filenames,probeIdSuffix)
        % Extract unique probeId from the parameter table
        % parameter table filenames contains transducer suffix '-MONO.txt', 
        % '-BIN.txt', 'BFormat'
        for iStr = 1:length(filenames)
            if endsWith(filenames(iStr),probeIdSuffix.mono)
                probeIdSet(iStr) = extractBefore(filenames(iStr),probeIdSuffix.mono);
            elseif endsWith(filenames(iStr),probeIdSuffix.bin)
                probeIdSet(iStr) = extractBefore(filenames(iStr),probeIdSuffix.bin);
            elseif endsWith(filenames(iStr),probeIdSuffix.bformat)
                probeIdSet(iStr) = extractBefore(filenames(iStr),probeIdSuffix.bformat);
            end
        end

        probeIdSet = unique(probeIdSet);
    end

end

function figureSet = createFigures(parTb,probeId,probeIdSuffix,plotTitle,options)
arguments
    parTb
    probeId
    probeIdSuffix
    plotTitle
    options.figureSet
    options.append = false
end

if isfield(options,'figureSet')
    figureSet = options.figureSet;
else
    figureSet = figure();
end

append = options.append;

paramSet.mono = ["C50","C80","D50","ts","EDT","T30"];
paramSet.bin = ["IACC", "Tau IACC", "w IACC"];
paramSet.bformat = ["Jlf", "Jlfc", "Lj"];

allParam = struct2array(paramSet);

for iPar = 1:length(allParam)
    param = allParam(iPar);

    fullProbeId = getFullProbeId(probeId,param,paramSet,probeIdSuffix);

    [yData,xData,unit] = filterParTb(parTb,fullProbeId,param);

    if ~isgraphics(figureSet(iPar))
        figureSet(iPar) = figure(Name=param);
    end

    plotParFig(xData,yData,figureSet(iPar),addPlot=append);

    applyGraphics(figureSet(iPar),unit,param,plotTitle,probeId,addPlot=append);
end

    function fullProbeId = getFullProbeId(probeId,param,paramSet,suffix)
        % Rebuild the full probeId string to locate parameters based on the
        % transducer. E.g.: monoaural parameters are plot from omni
        % transducer only
        if ismember(param,paramSet.mono)
            fullProbeId = probeId + suffix.mono;
        elseif ismember(param,paramSet.bin)
            fullProbeId = probeId + suffix.bin;
        elseif ismember(param,paramSet.bformat)
            fullProbeId = probeId + suffix.bformat;
        end
    end

end

%% Utility functions
function tb_filt = filterByPoint(parTb,pointID)
mask = strcmp(parTb.Filename,pointID);
tb_filt = parTb(mask,:);
end

function tb_filt = filterByParameter(parTb,param)
mask = strcmp(parTb.Parameter,param);
tb_filt = parTb(mask,:);
end

function [yData,xData,unit] = getCurveData(parTb)

xData = [31.5,63,125,250,500,1000,2000,4000,8000,16000];

column_mask = ["31_5","63","125","250","500",...
    "1000","2000","4000","8000","16000"];

yData = table2array(parTb(:,column_mask));

unit = parTb.Unit;
end

function [yData,xData,unit] = filterParTb(parTb,pointID,param)

% Filter by point ID
parTb_filt1 = filterByPoint(parTb,pointID);

if isempty(parTb_filt1)
    error("Specified point ID not found")
end
if size(unique(parTb_filt1.Filename))>1
    error("Multiple point ID found")
end

% Filter by Parameter
parTb_filt2 = filterByParameter(parTb_filt1,param);
if isempty(parTb_filt2)
    warning("Specified parameter not found in the table")
end
if height(parTb_filt2.Filename)>1
    error("Multiple parameter found")
end

% Extract curve data
[yData,xData,unit] = getCurveData(parTb_filt2);
end

function plotParFig(xData,yData,fig,options)
arguments
    xData
    yData
    fig
    options.addPlot = false
end

figure(fig);

if options.addPlot
    hold on;
end

semilogx(xData,yData,'LineWidth',1.3,'Marker','square'); hold off;
xlim([xData(1),xData(end)])
xticks(xData)

end

function applyGraphics(fig,unit,parName,plotTitle,probeLabel,options)
arguments
    fig
    unit
    parName
    plotTitle
    probeLabel
    options.addPlot = false
end

figure(fig);

grid on
ylabel(unit)
xlabel("Freq. [Hz]")
title(parName + " - " + plotTitle);

if options.addPlot
    legendLabels = string(legend(gca).String);
    legendLabels(end) = probeLabel;
    legend(legendLabels)
else
    legend(probeLabel)
end

end