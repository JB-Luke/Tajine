classdef Tajine < handle
    %TAJINE Interface of the tajine object (main model)

    properties (Abstract)
        MeasureSiteName
        OutputFolder
        Recording
        InverseSweep
    end

    properties (Abstract, Access=protected)
        Log
    end

    methods(Abstract)
        loadRecording(obj,inputFile)
        loadInverseSweep(obj,inputFile)
        process(obj)
    end    
end