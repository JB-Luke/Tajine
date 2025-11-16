classdef Recording < AudioFile
    %RECORDING Summary of this class goes here
    %   Detailed explanation goes here

    properties
        PositionId      uint32 {mustBePositive} = uint32.empty(0,1)
        PositionLabel   string {mustBeNonzeroLengthText} = string.empty(0,1)
        AcquisitionNo   uint32 {mustBePositive} = uint32.empty(0,1)
        AreaLabel       string                  = string.empty(0,1)
    end

    properties (Dependent)
        AcquisitionString
    end

    methods
        function obj = Recording(inputFile,options)
            %RECORDING Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                inputFile           string = string.empty(0,1)
                options.logger 
                options.audioFileIO
            end

            opts = [fieldnames(options) struct2cell(options)]';
            opts = opts(:)';
            
            obj@AudioFile(inputFile,opts{:})
        end

        function value = get.AcquisitionString(obj)

            value = "p" + num2str(obj.PositionId) + "-" ...
                + obj.PositionLabel + "-" ...
                + num2str(obj.AcquisitionNo);

            areaLb = obj.AreaLabel;
            if ~isempty(areaLb) && ~ismissing(areaLb) ...
                    && strlength(areaLb) > 1
                value = value + "-" + areaLb;
            end
        end

        function obj = setInfo(obj,info)
            %SETINFO Assign recording informations to properties
            obj.PositionId      = info.positionId;
            obj.PositionLabel   = info.positionLabel;
            obj.AcquisitionNo   = info.acquisitionNo;
            obj.AreaLabel       = info.areaLabel;
        end
    end
end