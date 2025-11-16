classdef UIFileFolder
% UIFILEFOLDER interface 
% Interface to choose a file or a folder
    methods (Abstract)
        [file,folder,status] = chooseFile(obj,varargin)
        [file,location,indx] = placeFile(obj,varargin)
        selpath = chooseFolder(obj,varargin)
    end
    
end