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

    wy_pars = {
        'Jlf'
        'Jlfc'
        'Lj'
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

    wy_unit = {
        ''
        ''
        'dB'
        };

    if strcmp(options.type,"omni")
        pars = [common_pars; omni_pars];
        unit = [common_unit; omni_unit];
    elseif strcmp(options.type,"bin")
        pars = [common_pars; bin_pars];
        unit = [common_unit; bin_unit];
    elseif strcmp(options.type,"wy")
        pars = [common_pars; wy_pars];
        unit = [common_unit; wy_unit];
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