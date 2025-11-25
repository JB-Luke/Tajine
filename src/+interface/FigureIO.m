classdef FigureIO < handle
    %FIGUREIO Interface
    % Interface for the import/export of figures
    methods (Abstract)
        saveto(obj,varargin)
    end
    
end