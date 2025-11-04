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

acquisitionId = unique(parTb(:,{'PointId','AcquisitionNo'}));

for iAcq = 1:height(acquisitionId)
    if iAcq == 1 
        appendPlot = false;
    else
        appendPlot = true;
    end
    pointId = acquisitionId{iAcq,'PointId'};
    acquisitionNo = acquisitionId{iAcq,'AcquisitionNo'};

    figureSet = createFigures(parTb,pointId,acquisitionNo,plotTitle, ...
        append=appendPlot,figureSet=figureSet);
end

end

function figureSet = createFigures(parTb,pointId,acquisitionNo,plotTitle,options)
arguments
    parTb
    pointId
    acquisitionNo
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

    transducerType = getTransducerType(param,paramSet);

    parTb_filt = filterParTb(parTb,param,pointId,acquisitionNo,transducerType);

    [yData,xData,unit] = getCurveData(parTb_filt);

    if ~isgraphics(figureSet(iPar))
        figureSet(iPar) = figure(Name=param);
    end

    plotParFig(xData,yData,figureSet(iPar),addPlot=append);

    acquisitionString = buildAcquisitionString(parTb_filt);
    applyGraphics(figureSet(iPar),unit,param,plotTitle,acquisitionString,addPlot=append);
end

    function transducerType = getTransducerType(param,paramSet)
        % Return the proper transducer type based on the parameter required
        if ismember(param,paramSet.mono)
            transducerType = "MONO";
        elseif ismember(param,paramSet.bin)
            transducerType = "BIN";
        elseif ismember(param,paramSet.bformat)
            transducerType = "BFormat";
        end
    end

    function acquisitionString = buildAcquisitionString(parTbRecord)
        if height(parTbRecord) > 1
            error("Expected a single row table")
        end
        acquisitionString = ...
            parTbRecord.PointId + "-" + ...
            parTbRecord.AreaId + "-" + ...
            string(parTbRecord.AcquisitionNo);               
    end
end

%% Utility functions
function tb_filt = filterByColumn(parTb,columnName,value)
if isstring(value)
    mask = strcmp(parTb.(columnName),value);
elseif isnumeric(value)
    mask = parTb.(columnName) == value;
else
    error("Value type not supported")
end

tb_filt = parTb(mask,:);
end

function [yData,xData,unit] = getCurveData(parTb)

xData = [31.5,63,125,250,500,1000,2000,4000,8000,16000];

column_mask = ["31_5","63","125","250","500",...
    "1000","2000","4000","8000","16000"];

yData = table2array(parTb(:,column_mask));

unit = parTb.Unit;
end

function parTb_filt = filterParTb(parTb,param,pointId, ...
    acquisitionNo,transducerType)
col2Filter = ["PointId", "AcquisitionNo", "TransducerType","Parameter"];
filterValues = {pointId, acquisitionNo, transducerType, param};


for iCol = 1:length(filterValues)
    parTb = filterByColumn(parTb,col2Filter(iCol),filterValues{iCol});
    if isempty(parTb)
        error("Specified filter (%s) gave no results.", col2Filter(iCol))
    end

end
parTb_filt = parTb;
if height(parTb_filt) > 1
    error("Multiple parameter found")
end

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

function applyGraphics(fig,unit,parName,plotTitle,acquisitionId,options)
arguments
    fig
    unit
    parName
    plotTitle
    acquisitionId
    options.addPlot = false
end

figure(fig);

grid on
xlim([125 8000]);
ylabel(unit)
xlabel("Freq. [Hz]")
title(parName + " - " + plotTitle);

if options.addPlot
    legendLabels = string(legend(gca).String);
    legendLabels(end) = acquisitionId;
    legend(legendLabels)
else
    legend(acquisitionId,'Interpreter','none')
end

end