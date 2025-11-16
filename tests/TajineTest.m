classdef (TestTags = {'Model','Unit','Tajine'}) TajineTest ...
        < matlab.unittest.TestCase & matlab.mock.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function untitledTest(tc)
            logger = utils.Logger("none");

            taj = Tajine(logger=logger);
            tc.verifyEqual(taj.MeasureSiteName, "untitled-measurement-site")
        end

        function loadRecordingTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");
            inputFile = "test.file";
            [recordingMock,recordingBehavior] = tc.createMock(?interface.Recording);

            taj = Tajine(logger=logger,recording=recordingMock);

            % WHEN
            taj.loadRecording(inputFile);

            % THEN
            tc.verifyCalled(recordingBehavior.load(inputFile))
        end

        function loadInverseFilterTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            logger = utils.Logger("none");
            inputFile = "test.file";
            [audiofileMock,audiofileBehavior] = tc.createMock(?AudioFile);

            fHandle = @(audiofileMock, inputFile) setValueInMock(audiofileMock, inputFile);

            when(audiofileBehavior.load(inputFile), ...
                Invoke(fHandle))

            function audiofileMock = setValueInMock(audiofileMock, inputFile)
                audiofileMock.FilePath = inputFile;
            end
            
            taj = Tajine(logger=logger,audiofile=audiofileMock);

            % WHEN
            taj.loadInverseSweep(inputFile);

            % THEN
            tc.verifyCalled(audiofileBehavior.load(inputFile))
            tc.verifyEqual(taj.InverseSweep.FilePath,inputFile)
        end
    end
end