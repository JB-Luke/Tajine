classdef TajineApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        TabGroup                  matlab.ui.container.TabGroup
        InputTab                  matlab.ui.container.Tab
        ProcessButton             matlab.ui.control.Button
        InversesweepPanel         matlab.ui.container.Panel
        GridLayout2               matlab.ui.container.GridLayout
        InverseSweepFileLabel     matlab.ui.control.Label
        InverseSweepLoadButton    matlab.ui.control.Button
        MeasurementSitenameEditFieldLabel  matlab.ui.control.Label
        MeasureSiteNameEditField  matlab.ui.control.EditField
        RecordingPanel            matlab.ui.container.Panel
        GridLayout                matlab.ui.container.GridLayout
        RecordingLoadButton       matlab.ui.control.Button
        AreaNameEditField         matlab.ui.control.EditField
        AreaEditFieldLabel        matlab.ui.control.Label
        AcquisitionNumberSpinner  matlab.ui.control.Spinner
        NumberSpinnerLabel        matlab.ui.control.Label
        PositionLabelEditField    matlab.ui.control.EditField
        LabelEditFieldLabel       matlab.ui.control.Label
        PositionIDSpinner         matlab.ui.control.Spinner
        PositionIDSpinnerLabel    matlab.ui.control.Label
        RecordingFileLabel        matlab.ui.control.Label
        ProcessTab                matlab.ui.container.Tab
        TajineLabel               matlab.ui.control.Label
    end

    properties (SetAccess = private)
        model

        uifilefolder
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, model, uifilefolder)
            arguments
                app
                model = Tajine()
                uifilefolder interface.UIFileFolder = utils.DefaultUIFileFolder()
            end

            app.model = model;
            app.uifilefolder = uifilefolder;

            app.TajineLabel.Text = "Tajine v"+getVersion().semver;

            app.UIFigure.Name = "Tajine";

            app.readData();
        end

         % Value changed function: AreaEditField, LabelEditField, 
        % ...and 3 other components
        function InputDataValueChanged(app, event)
             app.model.MeasureSiteName = app.MeasureSiteNameEditField.Value;
             app.model.Recording.PositionId = app.PositionIDSpinner.Value;
             app.model.Recording.PositionLabel = app.PositionLabelEditField.Value;
             app.model.Recording.AcquisitionNo = app.AcquisitionNumberSpinner.Value;
             app.model.Recording.AreaLabel = app.AreaNameEditField.Value;
        end

        % Button pushed function: RecordingLoadButton
        function RecordingLoadButtonPushed(app, event)
            [file,path] = app.uifilefolder.chooseFile( ...
                fullfile(pwd,"*.*"), ...
                "Select Recording file...", 'MultiSelect','off');

            if ~isnumeric(file)
                app.model.loadRecording(fullfile(path,file));
                app.RecordingFileLabel.Text = file;
            end
        end

        % Button pushed function: InverseSweepLoadButton
        function InverseSweepLoadButtonPushed(app, event)
            [file,path] = app.uifilefolder.chooseFile( ...
                fullfile(pwd,"*.*"), ...
                "Select Inverse Sweep file...", 'MultiSelect','off');

            if ~isnumeric(file)
                app.model.loadInverseSweep(fullfile(path,file));
                app.InverseSweepFileLabel.Text = file;
            end
        end

        % Button pushed function: ProcessButton
        function ProcessButtonPushed(app, event)
            app.model.process();
        end
    end

    methods % View
        function readData(app)
            app.MeasureSiteNameEditField.Value = app.model.MeasureSiteName;
            app.PositionIDSpinner.Value = double(app.model.Recording.PositionId);
            app.PositionLabelEditField.Value = app.model.Recording.PositionLabel;
            app.AcquisitionNumberSpinner.Value = double(app.model.Recording.AcquisitionNo);
            app.AreaNameEditField.Value = app.model.Recording.AreaLabel;
        end

    end

    % Component initialization
    methods (Access = private)
        createComponents(app)
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = TajineApp(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end