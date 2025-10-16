function [ir,peakVal] = deconvolve(recSweep,invSweep)

% Initialize
nChannels = size(recSweep,2);
invSweepLen = length(invSweep);
recSweepLen = length(recSweep);
irLen       = recSweepLen + invSweepLen - 1;
ir          = zeros(irLen,nChannels);

% Deconvolve 
for iCh = 1:nChannels
    ir(:,iCh) = fd_conv(recSweep(:,iCh),invSweep);
end

peakVal = max(abs(ir));
peakVal = max(peakVal);

% Rescale
ir = ir./peakVal;

end