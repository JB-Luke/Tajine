classdef AudioFile < interface.AudioFile
    %AUDIOFILE It represents audio data from a generic file

    properties
        FilePath    string
        Data        double
        Fs          double
    end

    properties (Access=protected)
        Log
        AudioFileIO
    end

    methods
        function obj = AudioFile(inputFile,options)
            %AUDIOFILEDATA Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                inputFile           string = string.empty(0,1)
                options.logger 
                options.audioFileIO
            end

            if isfield(options,'logger')
                obj.Log = options.logger;
            else
                obj.Log = utils.Logger("info");
            end

            if isfield(options,'audioFileIO')
                obj.AudioFileIO = options.audioFileIO;
            else
                obj.AudioFileIO = utils.DefaultAudioFileIO();
            end

            if ~isempty(inputFile)
                obj.load(inputFile);
            end
        end

        function load(obj,inputFile)
            %LOAD Summary of this method goes here
            %   Detailed explanation goes here
            arguments
                obj
                inputFile
            end
            
            log = sprintf("Loading audio file: %s\n", inputFile);
            obj.Log.info(log);

            [obj.Data, obj.Fs] = obj.AudioFileIO.fetchaudio(inputFile);
            obj.FilePath = inputFile;

            [nSamples, nChannels] = size(obj.Data);

            log = sprintf("Samples: %d\tChannels: %d\t "+ ...
                "Sample rate: %d Hz\n", nSamples, nChannels, obj.Fs);
            obj.Log.info(log);

        end
    end
end