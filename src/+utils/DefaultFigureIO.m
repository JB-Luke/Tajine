classdef DefaultFigureIO < interface.FigureIO
    methods 

        function saveto(~,varargin)
            saveas(varargin{:});
        end
    end

end