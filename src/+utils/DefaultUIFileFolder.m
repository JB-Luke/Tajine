classdef DefaultUIFileFolder < interface.UIFileFolder
    
    methods
        function [file,folder,status] = chooseFile(~,varargin)
            [file,folder,status] = uigetfile(varargin{:});
        end

        function [file,location,indx] = placeFile(~,varargin)
            [file,location,indx] = uiputfile(varargin{:});
        end

        function selpath = chooseFolder(~,varargin)
            selpath = uigetdir(varargin{:});
        end
    end
end