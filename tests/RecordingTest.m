classdef (TestTags = {'Model','Recording'}) ...
    RecordingTest < matlab.unittest.TestCase & matlab.mock.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test,TestTags = {'Unit'})
        % Test methods

        function AcquisitionStringTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");
            audioFileIOMock = tc.createMock(?interface.AudioFileIO);

            rec = Recording(logger=logger, audioFileIO=audioFileIOMock);
            
            rec.PositionId = 1;
            rec.PositionLabel = "box1";
            rec.AcquisitionNo = 1;

            % WHEN/THEN
            tc.verifyEqual(rec.AcquisitionString,"p1-box1-1");
        end

        function AcquisitionStringAreaTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");
            audioFileIOMock = tc.createMock(?interface.AudioFileIO);

            rec = Recording(logger=logger, audioFileIO=audioFileIOMock);

            rec.PositionId = 1; 
            rec.PositionLabel = "box1";
            rec.AcquisitionNo = 1;
            rec.AreaLabel = "gallery";

            % WHEN/THEN
            tc.verifyEqual(rec.AcquisitionString,...
                "p1-box1-1-gallery")
        end

        function setInfoTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");
            audioFileIOMock = tc.createMock(?interface.AudioFileIO);

            rec = Recording(logger=logger, audioFileIO=audioFileIOMock);

            info.positionId = uint32(1); 
            info.positionLabel = "box1";
            info.acquisitionNo = uint32(1);
            info.areaLabel = "gallery";

            % WHEN
            rec = rec.setInfo(info);

            % THEN
            tc.verifyEqual(rec.PositionId,info.positionId)
            tc.verifyEqual(rec.PositionLabel,info.positionLabel)
            tc.verifyEqual(rec.AcquisitionNo,info.acquisitionNo)
            tc.verifyEqual(rec.AreaLabel,info.areaLabel)
        end
    end

    methods (Test,TestTags = {'Integration'})
        function RecordingAudioFileTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");

            testFile = "file.wav";
            fs = 48000;
            nCh = 8;
            audioData = rand(5*fs,nCh);
            audiowrite(testFile,audioData,fs);
            tc.addTeardown(@delete,testFile)

            % WHEN
            rec = Recording(testFile,logger=logger);

            % THEN
            tc.verifyEqual(rec.FilePath,...
                testFile)
        end

    end
end