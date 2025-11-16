classdef AudioFile < handle
    %AUDIOFILE Interface of AudioFile

    properties(Abstract)
        FilePath    string
        Data        double
        Fs          double
    end

    properties (Abstract, Access=protected)
        Log
        AudioFileIO
    end

    methods(Abstract) 
        load(obj,inputFile)
    end
end