classdef Recording_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function loadTest(tc)
            fs = 48000;
            nCh = 8;
            audioData = rand(5*fs,nCh);
            readFcn = @(~) deal(audioData, fs); % Mocking audioread with funciton handle
            filePath = "file.wav";

            rec = Recording(readFcn = readFcn);
            rec = rec.load(filePath);
            tc.verifyEqual(rec.Data, audioData)
            tc.verifyEqual(rec.FilePath,filePath)
            tc.verifyEqual(rec.Fs,fs)
        end
    end
end