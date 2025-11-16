classdef DefaultUIFileFolder < interface.UIFileFolder
    
    methods
        function [file,folder,indx] = chooseFile(~,varargin)
            [file,folder,indx] = uigetfile(varargin{:});
        end

        function [file,location,indx] = placeFile(~,varargin)
            [file,location,indx] = uiputfile(varargin{:});
        end

        function selpath = chooseFolder(~,varargin)
            selpath = uigetdir(varargin{:});
        end
    end
end