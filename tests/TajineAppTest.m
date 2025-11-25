classdef (TestTags = {'GUI','Unit','TajineApp'}) ...
    TajineAppTest < matlab.uitest.TestCase & matlab.mock.TestCase

    properties
        app

        mock
        behavior
    end

    properties (TestParameter)
        uiComponent = {
            'MeasureSiteNameEditField',...
            'PositionIDSpinner',...
            'PositionLabelEditField',...
            'AcquisitionNumberSpinner',...
            'AreaNameEditField'};

        newInputValue = {'site-name',uint32(2),"position-label",uint32(2),"area-label"};

        modelProperty = {
            'MeasureSiteName', ...
            'PositionId', ...
            'PositionLabel', ...
            'AcquisitionNo', ...
            'AreaLabel'};
    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
        function launchApp(tc)

            [tc.mock.recording,tc.behavior.recording] = ...
                tc.createMock(?interface.Recording,...
                'DefaultPropertyValues', ...
                struct( ...
                'PositionId',1, ...
                'PositionLabel','pos1', ...
                'AcquisitionNo',1, ...
                'AreaLabel','area1'));
            
            [tc.mock.model,tc.behavior.model] = ...
                tc.createMock(?interface.Tajine, ...
                'DefaultPropertyValues', ...
                struct( ...
                'Recording',tc.mock.recording));

            [tc.mock.uifilefolder,tc.behavior.uifilefolder] = ...
                tc.createMock(?interface.UIFileFolder);

            tc.app = TajineApp(tc.mock.model,tc.mock.uifilefolder);
            tc.addTeardown(@delete,tc.app)
        end
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function readDataTest(tc)
            % GIVEN
            measSiteName = 'site-name';
            positionId = 2;
            positionLabel = 'position-label';
            acquisitionNo = 2;
            areaLabel = 'area-label';

            tc.mock.model.MeasureSiteName = measSiteName;
            tc.mock.model.Recording.PositionId = positionId;
            tc.mock.model.Recording.PositionLabel = positionLabel;
            tc.mock.model.Recording.AcquisitionNo = acquisitionNo;
            tc.mock.model.Recording.AreaLabel = areaLabel;

            tc.addTeardown(@()tc.clearMockHistory(tc.mock.model))

            % WHEN
            tc.app.readData();

            % THEN
            tc.verifyEqual(tc.app.MeasureSiteNameEditField.Value,measSiteName);
            tc.verifyEqual(tc.app.PositionIDSpinner.Value,positionId);
            tc.verifyEqual(tc.app.PositionLabelEditField.Value,positionLabel);
            tc.verifyEqual(tc.app.AcquisitionNumberSpinner.Value,acquisitionNo);
            tc.verifyEqual(tc.app.AreaNameEditField.Value,areaLabel);
        end
    end

    methods (Test,ParameterCombination="sequential")
        function updateModelTest(tc,modelProperty,uiComponent,newInputValue)
            % GIVEN
            % parametrized 

            % WHEN
            tc.type(tc.app.(uiComponent),newInputValue)

            % THEN
            if strcmp(modelProperty,'MeasureSiteName')
                tc.verifyEqual(tc.mock.model.(modelProperty),newInputValue);
            else
                tc.verifyEqual(tc.mock.recording.(modelProperty),newInputValue);
            end
        end
    end

    methods(Test)

        function loadRecordingTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            fileName = 'testFile.txt';
            testDir = "testDir";
            fullfilepath = fullfile(testDir,fileName);
            when(withAnyInputs(tc.behavior.uifilefolder.chooseFile()), ...
                AssignOutputs(fileName,testDir));

            % WHEN
            tc.press(tc.app.RecordingLoadButton)

            % THEN
            tc.verifyCalled(tc.behavior.model.loadRecording(fullfilepath));
            tc.verifyEqual(tc.app.RecordingFileLabel.Text,fileName)
            tc.clearMockHistory(tc.mock.model)
        end

        function loadRecordingNothingTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            fileSelection = 0;
            folderSelection = 0;
            when(withAnyInputs(tc.behavior.uifilefolder.chooseFile()), ...
                AssignOutputs(fileSelection,folderSelection));
            orgRecFileLb = tc.app.RecordingFileLabel.Text;

            % WHEN
            tc.press(tc.app.RecordingLoadButton)

            % THEN
            tc.verifyNotCalled(withAnyInputs(tc.behavior.model.loadRecording));
            tc.verifyEqual(tc.app.RecordingFileLabel.Text,orgRecFileLb)

            tc.clearMockHistory(tc.mock.model)
        end

        function loadInverseSweepTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            fileName = 'testFile.txt';
            testDir = "testDir";
            fullfilepath = fullfile(testDir,fileName);
            when(withAnyInputs(tc.behavior.uifilefolder.chooseFile()), ...
                AssignOutputs(fileName,testDir));

            % WHEN
            tc.press(tc.app.InverseSweepLoadButton)

            % THEN
            tc.verifyCalled(tc.behavior.model.loadInverseSweep(fullfilepath));
            tc.verifyEqual(tc.app.InverseSweepFileLabel.Text,fileName)
            tc.clearMockHistory(tc.mock.model)
        end

        function loadInverseSweepNothingTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            fileSelection = 0;
            folderSelection = 0;
            when(withAnyInputs(tc.behavior.uifilefolder.chooseFile()), ...
                AssignOutputs(fileSelection,folderSelection));
            orgFileLb = tc.app.InverseSweepFileLabel.Text;

            % WHEN
            tc.press(tc.app.InverseSweepLoadButton)

            % THEN
            tc.verifyNotCalled(withAnyInputs(tc.behavior.model.loadInverseSweep));
            tc.verifyEqual(tc.app.InverseSweepFileLabel.Text,orgFileLb)

            tc.clearMockHistory(tc.mock.model)
        end

        function processTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            %

            % WHEN
            tc.press(tc.app.ProcessButton)

            % THEN
            tc.verifyCalled(withExactInputs(tc.behavior.model.process));
            tc.clearMockHistory(tc.mock.model)
        end

        function exportFiguresTest(tc)
            import matlab.mock.actions.*

            % GIVEN
            %

            % WHEN
            tc.press(tc.app.SaveFiguresButton)

            % THEN
            tc.verifyCalled(withExactInputs(tc.behavior.model.exportFigures));
            tc.clearMockHistory(tc.mock.model)
        end
    end
end