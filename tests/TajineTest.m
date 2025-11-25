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

        function defaultSiteTest(tc)
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

        function exportFiguresTest(tc)
            import matlab.unittest.constraints.*

            % GIVEN
            logger = utils.Logger("none");
            [figureIOmock,figureIOBehavior] = tc.createMock( ...
                ?interface.FigureIO);
            
            taj = Tajine(logger=logger,figureIO=figureIOmock);
            taj.OutputFolder = pwd;

            f1 = figure("Name","test1");
            f2 = figure("Name","test2");
            taj.figureSet = [f1 f2];
            tc.addTeardown(@()close([f1 f2]));

            % WHEN
            taj.exportFigures();

            % THEN
            figFolder = fullfile(taj.OutputFolder,"calcs","figures");
            tc.verifyThat(figFolder,IsFolder)

            figOutFile1 = fullfile(figFolder,"test1.fig");
            tc.verifyCalled(figureIOBehavior.saveto(f1,figOutFile1))

            figOutFile2 = fullfile(figFolder,"test2.fig");
            tc.verifyCalled(figureIOBehavior.saveto(f2,figOutFile2))
        end

        function exportFiguresPartialTest(tc)
            import matlab.unittest.constraints.*
            import matlab.mock.constraints.*

            % GIVEN
            logger = utils.Logger("none");
            [figureIOmock,figureIOBehavior] = tc.createMock( ...
                ?interface.FigureIO);
            
            taj = Tajine(logger=logger,figureIO=figureIOmock);

            taj.OutputFolder = pwd;
            figFolder = fullfile(taj.OutputFolder,"calcs","figures");
            tc.addTeardown(@()rmdir(fullfile(taj.OutputFolder,"calcs"),"s"));

            f1 = figure("Name","test1");
            taj.figureSet = [f1 gobjects];
            tc.addTeardown(@close,f1);

            % WHEN
            taj.exportFigures();

            % THEN
            tc.verifyThat(figFolder,IsFolder)
            tc.verifyThat(withAnyInputs(figureIOBehavior.saveto), ...
            WasCalled('WithCount',1))

            figOutFile1 = fullfile(figFolder,"test1.fig");
            tc.verifyCalled(figureIOBehavior.saveto(f1,figOutFile1))
        end
    end
end