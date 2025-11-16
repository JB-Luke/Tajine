classdef (TestTags = {'Model','Unit','AudioFile'}) ...
    AudioFileTest < matlab.unittest.TestCase & matlab.mock.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function constructorTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");
            [audioFileIOMock,audioFileIOBehavior] = tc.createMock(?interface.AudioFileIO);
            
            fs = 48000;
            nCh = 8;
            audioData = rand(5*fs,nCh);
            filePath = "file.wav";
            when(withAnyInputs(audioFileIOBehavior.fetchaudio()), ...
                AssignOutputs(audioData,fs))

            % WHEN
            audioFile = AudioFile(filePath,logger=logger, ...
                audioFileIO=audioFileIOMock);
            
            % THEN
            tc.verifyEqual(audioFile.Data, audioData)
            tc.verifyEqual(audioFile.FilePath,filePath)
            tc.verifyEqual(audioFile.Fs,fs)
        end      

        function loadTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");
            [audioFileIOMock,audioFileIOBehavior] = tc.createMock(?interface.AudioFileIO);
            when(withAnyInputs(audioFileIOBehavior.fetchaudio()), ...
                AssignOutputs([],0))

            fs = 48000;
            nCh = 8;
            audioData = rand(5*fs,nCh);
            filePath = "file.wav";            
            audioFile = AudioFile("",logger=logger, ...
                audioFileIO=audioFileIOMock);

            when(withAnyInputs(audioFileIOBehavior.fetchaudio()), ...
                AssignOutputs(audioData,fs));
            
            % WHEN
            audioFile.load(filePath);
            
            % THEN
            tc.verifyEqual(audioFile.FilePath,filePath)
            tc.verifyEqual(audioFile.Data, audioData)
            tc.verifyEqual(audioFile.Fs,fs)
        end    
    end
end