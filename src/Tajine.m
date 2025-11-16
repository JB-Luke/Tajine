classdef Tajine < handle
    %TAJINE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        measureSiteName
        outputFolder
        Recording
        InverseSweep
    end

    properties (Access=private)
        Log
    end

    methods
        function obj = Tajine(options)
            %TAJINE Construct an instance of this class
            %   Detailed explanation goes here

            arguments
                options.logger
                options.recording
                options.audiofile
            end

            parseConstructorArguments(obj,options);

            displayVersion(obj);

            % Set default values
            obj.measureSiteName = "untitled-measurement-site";
        end

        function obj = loadRecording(obj,inputFile)
            %LOADRECORDING Load audio from recording audio file
            obj.Recording = obj.Recording.load(inputFile);
        end

        function obj = loadInverseSweep(obj,inputFile)
            %LOADINVERSESWEEP 
            obj.InverseSweep = obj.InverseSweep.load(inputFile);
        end
        
    end

    methods (Access = private)

        function parseConstructorArguments(obj,options)
            if isfield(options,"logger")
                obj.Log = options.logger;
            else
                obj.Log = utils.Logger("info");
            end

            if isfield(options,"recording")
                obj.Recording = options.recording;
            else
                obj.Recording = Recording();
            end

            if isfield(options,"audiofile")
                obj.InverseSweep = options.audiofile;
            else
                obj.InverseSweep = AudioFile();
            end
        end

        function displayVersion(obj)
            %DISPLAYVERSION Diplay Tajine version
            obj.Log.info("Tajine "+runtimeVersionString());

            v = getVersion();
            if ~strcmp("v"+v.semver,v.gitTag)
                log = "Local version differs from git tag";
                obj.Log.warn(log);
                warning(log);
            end

            obj.Log.info(newline);
        end
    end
end