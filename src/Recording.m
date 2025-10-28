classdef Recording
    %RECORDING Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Name        string
        FilePath    string
        Data        double
        Fs          double
    end

    properties (Access=private)
        ReadFcn function_handle
    end

    methods
        function obj = Recording(options)
            %RECORDING Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.readFcn (1,1)
            end

            if isfield(options,'readFcn')
                obj.ReadFcn = options.readFcn;
            else
                obj.ReadFcn = @audioread;
            end
        end

        function obj = load(obj,inputFile)
            %LOAD Summary of this method goes here
            %   Detailed explanation goes here
            fprintf("Loading audio file: %s\n", inputFile);
            
            [obj.Data, obj.Fs] = obj.ReadFcn(inputFile);
            obj.FilePath = inputFile;

            [nSamples, nChannels] = size(obj.Data);

            fprintf('Samples: %d\tChannels: %d\t Sample rate: %d Hz\n', ...
                nSamples, nChannels, obj.Fs);

        end
    end
end