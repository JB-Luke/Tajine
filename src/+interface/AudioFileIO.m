classdef AudioFileIO
% AUDIOFILEIO interface 
% Interface for the import/export of audio data
    methods (Abstract)
        [y,Fs] = fetchaudio(obj,varargin)
    end
    
end