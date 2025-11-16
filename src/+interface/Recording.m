classdef Recording < interface.AudioFile
    %RECORDING Recording interface

    properties(Abstract)
        PositionId      uint32 {mustBePositive} 
        PositionLabel   string {mustBeNonzeroLengthText} 
        AcquisitionNo   uint32 {mustBePositive}
        AreaLabel       string
    end

    properties (Abstract, Dependent)
        AcquisitionString
    end

    methods(Abstract)        
        obj = setInfo(obj,info)
    end
end