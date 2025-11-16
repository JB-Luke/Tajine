classdef DefaultAudioFileIO < interface.AudioFileIO
    
    methods
        function [y,Fs] = fetchaudio(~,varargin)
            [y,Fs] = audioread(varargin{:});
        end
    end
end