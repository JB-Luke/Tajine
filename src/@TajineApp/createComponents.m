% Create UIFigure and components
function createComponents(app)

% Create UIFigure and hide until all components are created
app.UIFigure = uifigure('Visible', 'off');
app.UIFigure.Position = [100 100 443 573];
app.UIFigure.Name = 'MATLAB App';

% Create TajineLabel
app.TajineLabel = uilabel(app.UIFigure);
app.TajineLabel.HorizontalAlignment = 'center';
app.TajineLabel.FontSize = 24;
app.TajineLabel.FontWeight = 'bold';
app.TajineLabel.Position = [74 533 297 33];
app.TajineLabel.Text = 'Tajine';

% Create TabGroup
app.TabGroup = uitabgroup(app.UIFigure);
app.TabGroup.TabLocation = 'bottom';
app.TabGroup.Position = [1 1 443 521];

% Create InputTab
app.InputTab = uitab(app.TabGroup);
app.InputTab.Title = 'Input';

% Create RecordingPanel
app.RecordingPanel = uipanel(app.InputTab);
app.RecordingPanel.Title = 'Recording';
app.RecordingPanel.Position = [0 189 441 243];

% Create GridLayout
app.GridLayout = uigridlayout(app.RecordingPanel);
app.GridLayout.ColumnWidth = {'1x', 43, 57, '0.4x', 138, '1.08x'};
app.GridLayout.RowHeight = {'1x', 23, '1x', 22, 22, 22, 22, '1x'};

% Create RecordingFileLabel
app.RecordingFileLabel = uilabel(app.GridLayout);
app.RecordingFileLabel.Layout.Row = 2;
app.RecordingFileLabel.Layout.Column = [5 6];
app.RecordingFileLabel.Text = 'empty';

% Create PositionIDSpinnerLabel
app.PositionIDSpinnerLabel = uilabel(app.GridLayout);
app.PositionIDSpinnerLabel.HorizontalAlignment = 'right';
app.PositionIDSpinnerLabel.Layout.Row = 4;
app.PositionIDSpinnerLabel.Layout.Column = 3;
app.PositionIDSpinnerLabel.Text = 'Position ID';

% Create PositionIDSpinner
app.PositionIDSpinner = uispinner(app.GridLayout);
app.PositionIDSpinner.ValueChangedFcn = createCallbackFcn(app, @InputDataValueChanged, true);
app.PositionIDSpinner.Layout.Row = 4;
app.PositionIDSpinner.Layout.Column = 5;

% Create LabelEditFieldLabel
app.LabelEditFieldLabel = uilabel(app.GridLayout);
app.LabelEditFieldLabel.HorizontalAlignment = 'right';
app.LabelEditFieldLabel.Layout.Row = 5;
app.LabelEditFieldLabel.Layout.Column = 3;

% Create PositionLabelEditField
app.PositionLabelEditField = uieditfield(app.GridLayout, 'text');
app.PositionLabelEditField.ValueChangedFcn = createCallbackFcn(app, @InputDataValueChanged, true);
app.PositionLabelEditField.Layout.Row = 5;
app.PositionLabelEditField.Layout.Column = 5;

% Create NumberSpinnerLabel
app.NumberSpinnerLabel = uilabel(app.GridLayout);
app.NumberSpinnerLabel.HorizontalAlignment = 'right';
app.NumberSpinnerLabel.Layout.Row = 6;
app.NumberSpinnerLabel.Layout.Column = 3;
app.NumberSpinnerLabel.Text = 'Number';

% Create AcquisitionNumberSpinner
app.AcquisitionNumberSpinner = uispinner(app.GridLayout);
app.AcquisitionNumberSpinner.ValueChangedFcn = createCallbackFcn(app, @InputDataValueChanged, true);
app.AcquisitionNumberSpinner.Layout.Row = 6;
app.AcquisitionNumberSpinner.Layout.Column = 5;

% Create AreaEditFieldLabel
app.AreaEditFieldLabel = uilabel(app.GridLayout);
app.AreaEditFieldLabel.HorizontalAlignment = 'right';
app.AreaEditFieldLabel.Layout.Row = 7;
app.AreaEditFieldLabel.Layout.Column = 3;
app.AreaEditFieldLabel.Text = 'Area';

% Create AreaNameEditField
app.AreaNameEditField = uieditfield(app.GridLayout, 'text');
app.AreaNameEditField.ValueChangedFcn = createCallbackFcn(app, @InputDataValueChanged, true);
app.AreaNameEditField.Layout.Row = 7;
app.AreaNameEditField.Layout.Column = 5;

% Create RecordingLoadButton
app.RecordingLoadButton = uibutton(app.GridLayout, 'push');
app.RecordingLoadButton.ButtonPushedFcn = createCallbackFcn(app, @RecordingLoadButtonPushed, true);
app.RecordingLoadButton.Layout.Row = 2;
app.RecordingLoadButton.Layout.Column = [2 3];
app.RecordingLoadButton.Text = 'Load';

% Create MeasureSiteNameEditField
app.MeasureSiteNameEditField = uieditfield(app.InputTab, 'text');
app.MeasureSiteNameEditField.ValueChangedFcn = createCallbackFcn(app, @InputDataValueChanged, true);
app.MeasureSiteNameEditField.Position = [208 451 162 22];

% Create MeasurementSitenameEditFieldLabel
app.MeasurementSitenameEditFieldLabel = uilabel(app.InputTab);
app.MeasurementSitenameEditFieldLabel.HorizontalAlignment = 'right';
app.MeasurementSitenameEditFieldLabel.Position = [25 451 136 22];
app.MeasurementSitenameEditFieldLabel.Text = 'Measurement Site name';

% Create InversesweepPanel
app.InversesweepPanel = uipanel(app.InputTab);
app.InversesweepPanel.Title = 'Inverse sweep';
app.InversesweepPanel.Position = [2 90 441 100];

% Create GridLayout2
app.GridLayout2 = uigridlayout(app.InversesweepPanel);
app.GridLayout2.ColumnWidth = {'1x', 110, '1.02x', 182, '1x'};
app.GridLayout2.RowHeight = {'1x', 23, '1x'};

% Create InverseSweepLoadButton
app.InverseSweepLoadButton = uibutton(app.GridLayout2, 'push');
app.InverseSweepLoadButton.ButtonPushedFcn = createCallbackFcn(app, @InverseSweepLoadButtonPushed, true);
app.InverseSweepLoadButton.Layout.Row = 2;
app.InverseSweepLoadButton.Layout.Column = 2;
app.InverseSweepLoadButton.Text = 'Load';

% Create InverseSweepFileLabel
app.InverseSweepFileLabel = uilabel(app.GridLayout2);
app.InverseSweepFileLabel.Layout.Row = 2;
app.InverseSweepFileLabel.Layout.Column = [4 5];
app.InverseSweepFileLabel.Text = 'empty';

% Create ProcessButton
app.ProcessButton = uibutton(app.InputTab, 'push');
app.ProcessButton.ButtonPushedFcn = createCallbackFcn(app, @ProcessButtonPushed, true);
app.ProcessButton.Position = [173 31 100 23];
app.ProcessButton.Text = 'Process';

% Create SaveFiguresButton
app.SaveFiguresButton = uibutton(app.InputTab, 'push');
app.SaveFiguresButton.ButtonPushedFcn = createCallbackFcn(app, @SaveFiguresButtonPushed, true);
app.SaveFiguresButton.Position = [321 30 100 23];
app.SaveFiguresButton.Text = 'Save Figures';

% Show the figure after all components are created
app.UIFigure.Visible = 'on';
end