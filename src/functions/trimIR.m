function [irTrim,peakIdx] = trimIR(ir,fs,preDly,irDur,options)
% Trim the IR signal from its max peak value or specified location
arguments
    ir
    fs
    preDly
    irDur
    options.maxIdx
end

if isfield(options,'maxIdx')
    peakIdx = options.maxIdx;
else
    [~, peakIdx] = max(abs(ir));   % get value and index of peak
    if any(size(peakIdx) > 1)
        peakIdx = peakIdx(1);
    end
end

% Get trim parameters, do the trimming & 
preDlySmpl = preDly * fs;
irLenSmpl = irDur * fs;
iStart = peakIdx - preDlySmpl;
iStop  = iStart + irLenSmpl - 1;

irTrim = ir(iStart:iStop,:);

end