classdef Tajine < interface.Tajine
    %TAJINE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        MeasureSiteName
        OutputFolder
        Recording
        InverseSweep

        figureSet
    end

    properties (Access=protected)
        Log
        FigureIO
    end

    methods
        process(obj);

        function obj = Tajine(options)
            %TAJINE Construct an instance of this class
            %   Detailed explanation goes here

            arguments
                options.logger
                options.recording
                options.audiofile
                options.figureIO
            end

            parseConstructorArguments(obj,options);

            displayVersion(obj);

            % Set default values
            obj.MeasureSiteName = "untitled-measurement-site";
        end

        function loadRecording(obj,inputFile)
            %LOADRECORDING Load audio from recording audio file
            obj.Recording.load(inputFile);
        end

        function loadInverseSweep(obj,inputFile)
            %LOADINVERSESWEEP 
            obj.InverseSweep.load(inputFile);
        end

        function exportFigures(obj)
            figOutFolder = fullfile(obj.OutputFolder,"calcs","figures");
            if ~isfolder(figOutFolder)
                mkdir(figOutFolder);
            end

            for iFig = 1:length(obj.figureSet)
                figHandle = obj.figureSet(iFig);
                if ~ishghandle(figHandle); continue; end
                figOutName = figHandle.Name;
                figOutFile = fullfile(figOutFolder,figOutName+".fig");
                obj.FigureIO.saveto(figHandle,figOutFile);
            end
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

            if isfield(options,"figureIO")
                obj.FigureIO = options.figureIO;
            else
                obj.FigureIO = utils.DefaultFigureIO();
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