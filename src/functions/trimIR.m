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