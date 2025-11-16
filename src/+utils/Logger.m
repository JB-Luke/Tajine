classdef Logger < handle
    %LOGGER Essential logger tool

    properties
        Level {mustBeMember(Level,["debug","info","warn","error","none"])} = "info"
        FileID = 1
    end

    methods
        function obj = Logger(level, file)
            if nargin >= 1, obj.Level = level; end
            if nargin >= 2, obj.FileID = file; end
        end

        function log(obj, level, msg)
            levels = ["debug","info","warn","error","none"];
            if find(levels==level) >= find(levels==obj.Level)
                fprintf(obj.FileID,"[%s] %s: %s\n", ...
                    datestr(now,'HH:MM:SS'), upper(level), msg);
            end
        end

        function info(obj,msg),  obj.log("info",msg);  end
        function warn(obj,msg),  obj.log("warn",msg);  end
        function error(obj,msg), obj.log("error",msg); end
        function debug(obj,msg), obj.log("debug",msg); end
    end
end