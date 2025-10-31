% --- LoKI_GUI.m ---
classdef LoKI_GUI < handle
    %LoKI_GUI Class that provides a user-friendly interface for LoKI setup

    properties
        Setup;      % Struct holding the simulation setup data
        Fig;        % Main figure handle
        UIControls; % Struct to hold handles to UI controls for easy access/update
    end

    methods
        function gui = LoKI_GUI(inputFile)
            % Constructor
            if nargin < 1 || isempty(inputFile)
                gui.initializeDefaultSetup(); % Initialize with defaults if no file provided
            else
                % Placeholder: Implement loading from an existing file
                try
                    % gui.Setup = gui.parseInputFile(inputFile); % You'd need to implement parseInputFile
                    gui.initializeDefaultSetup(); % For now, still use defaults
                    fprintf('Note: Loading from file not yet implemented. Using default setup.\n');
                catch ME
                    warning('Error loading input file: %s. Using default setup.', '%s', ME.message);
                    gui.initializeDefaultSetup();
                end
            end
            gui.UIControls = struct(); % Initialize empty struct for control handles
            gui.createGUI();
            gui.populateGUIFromSetup(); % Populate GUI fields with Setup data
        end

        function initializeDefaultSetup(gui)
            % Initialize the Setup struct with default values (mirroring the input file)
            gui.Setup = struct();

            % Working Conditions [cite: 1, 2, 3, 4]
            gui.Setup.workingConditions.reducedField = '10'; % Store as string initially
            gui.Setup.workingConditions.electronTemperature = 'linspace(0.03, 5, 100)'; % Store as string
            gui.Setup.workingConditions.excitationFrequency = 0;
            gui.Setup.workingConditions.gasPressure = 133.32;
            gui.Setup.workingConditions.gasTemperature = 300;
            gui.Setup.workingConditions.wallTemperature = 130;
            gui.Setup.workingConditions.extTemperature = 300;
            gui.Setup.workingConditions.surfaceSiteDensity = 1e19;
            gui.Setup.workingConditions.electronDensity = 1e19;
            gui.Setup.workingConditions.chamberLength = 1.0;
            gui.Setup.workingConditions.chamberRadius = 1.0;

            % Electron Kinetics [cite: 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
            gui.Setup.electronKinetics.isOn = true;
            gui.Setup.electronKinetics.eedfType = 'boltzmann'; % 'boltzmann' or 'prescribedEedf'
            gui.Setup.electronKinetics.ionizationOperatorType = 'conservative'; % 'conservative', 'oneTakesAll', etc.
            gui.Setup.electronKinetics.growthModelType = 'temporal'; % 'temporal' or 'spatial'
            gui.Setup.electronKinetics.includeEECollisions = true;
            gui.Setup.electronKinetics.LXCatFiles = {'Hydrogen/H2_elastic_LXCat.txt'}; % Cell array of strings
            gui.Setup.electronKinetics.CARgases = {'H2'}; % Cell array of strings
            
            % Gas Properties [cite: 5]
            gui.Setup.electronKinetics.gasProperties.mass = 'Databases/masses.txt';
            gui.Setup.electronKinetics.gasProperties.fraction = {'H2 = 1'}; % Cell array of strings
            gui.Setup.electronKinetics.gasProperties.harmonicFrequency = 'Databases/harmonicFrequencies.txt';
            gui.Setup.electronKinetics.gasProperties.anharmonicFrequency = 'Databases/anharmonicFrequencies.txt';
            gui.Setup.electronKinetics.gasProperties.rotationalConstant = 'Databases/rotationalConstants.txt';
            gui.Setup.electronKinetics.gasProperties.electricQuadrupoleMoment = 'Databases/quadrupoleMoment.txt';
            gui.Setup.electronKinetics.gasProperties.OPBParameter = 'Databases/OPBParameter.txt';
            
            % State Properties [cite: 5]
            gui.Setup.electronKinetics.stateProperties.population = {'H2(X) = 1.0'}; % Cell array of strings
            
            % Numerics
            gui.Setup.electronKinetics.numerics.energyGrid.variableGrid = true;
            gui.Setup.electronKinetics.numerics.energyGrid.firstEnergyStep = 4e-4;
            gui.Setup.electronKinetics.numerics.energyGrid.maxEnergy = 10;
            gui.Setup.electronKinetics.numerics.energyGrid.cellNumber = 200;
            gui.Setup.electronKinetics.numerics.maxPowerBalanceRelError = 1e-9;
            gui.Setup.electronKinetics.numerics.nonLinearRoutines.algorithm = 'mixingDirectSolutions';
            gui.Setup.electronKinetics.numerics.nonLinearRoutines.mixingParameter = 0.7;
            gui.Setup.electronKinetics.numerics.nonLinearRoutines.maxEedfRelError = 1e-9;

            % GUI (from input file, maybe solver specific?) [cite: 13, 14]
            gui.Setup.gui.isOn = true;
            gui.Setup.gui.refreshFrequency = 1;

            % Output [cite: 14]
            gui.Setup.output.isOn = true;
            gui.Setup.output.dataFormat = 'txt'; % 'txt', 'hdf5', 'hdf5+txt'
            gui.Setup.output.folder = 'H2Swarm_elastic';
            gui.Setup.output.dataSets = {'log', 'eedf', 'swarmParameters', 'rateCoefficients', 'powerBalance', 'lookUpTable'}; % Cell array
        end

        function createGUI(gui)
            % Create the main figure
            iconPath = 'icon.png'; % Relative or absolute path to your icon
            if ~isfile(iconPath)
                warning('Icon file not found: %s. Using default icon.', iconPath);
                iconPath = ''; % Use default if not found
            end

            gui.Fig = uifigure('Name', 'LoKI BCL', ...
                             'Position', [100, 100, 850, 650], ...
                             'NumberTitle', 'off', ...
                             'Resize', 'on', ... % Allow resizing
                             'Icon', iconPath); % <-- SET THE ICON HERE
                      

            % Main grid layout
            mainGrid = uigridlayout(gui.Fig, [2, 1]);
            mainGrid.RowHeight = {'1x', 'fit'}; % Tabs take most space, buttons at bottom

            % Create tabs
            tabGroup = uitabgroup(mainGrid);
            tabGroup.Layout.Row = 1;
            tabGroup.Layout.Column = 1;

            % --- Working Conditions Tab ---
            workingTab = uitab(tabGroup, 'Title', 'Working Conditions', 'Scrollable', 'on');
            gui.createWorkingConditionsPanel(workingTab);

            % --- Electron Kinetics Tab ---
            kineticsTab = uitab(tabGroup, 'Title', 'Electron Kinetics', 'Scrollable', 'on');
            gui.createElectronKineticsPanel(kineticsTab);

            % --- Numerics Tab ---
            numericsTab = uitab(tabGroup, 'Title', 'Numerics', 'Scrollable', 'on');
            gui.createNumericsPanel(numericsTab);

            % --- Output Settings Tab ---
            outputTab = uitab(tabGroup, 'Title', 'Output Settings', 'Scrollable', 'on');
            gui.createOutputPanel(outputTab);

            % --- Button Panel ---
            buttonPanel = uipanel(mainGrid, 'BorderType', 'none');
            buttonPanel.Layout.Row = 2;
            buttonPanel.Layout.Column = 1;
            buttonGrid = uigridlayout(buttonPanel, [1, 4]);
            % Add some padding/spacing if needed
            buttonGrid.ColumnWidth = {'1x', 'fit', 'fit', 'fit'}; % Push buttons to right
            buttonGrid.Padding = [10 10 10 10];
            buttonGrid.ColumnSpacing = 10;

            % Load Button (Placeholder)
            uibutton(buttonGrid, 'Text', 'Load Settings', ...
                'ButtonPushedFcn', @gui.loadSettings, 'Enable', 'off'); % Disabled for now

            % Save Button
            uibutton(buttonGrid, 'Text', 'Save Input File', ...
                'ButtonPushedFcn', @gui.saveInputFile);

            % Run Button
            uibutton(buttonGrid, 'Text', 'Generate & Run', ...
                     'FontWeight', 'bold', ...
                     'ButtonPushedFcn', @gui.runSimulation);
        end

        function createWorkingConditionsPanel(gui, parent)
            % Use grid layout for better alignment and resizing
            grid = uigridlayout(parent, [11, 3]); % Adjust rows as needed
            grid.ColumnWidth = {'fit', '1x', 'fit'}; % Label, Edit, Browse/Unit
            grid.RowHeight = repmat({'fit'}, 1, 11);
            grid.Padding = [10 10 10 10];
            grid.RowSpacing = 5;
            grid.ColumnSpacing = 10;

            row = 1;
            % Reduced Field [cite: 1]
            uilabel(grid, 'Text', 'Reduced Field (Td):');
            gui.UIControls.workingConditions.reducedField = uieditfield(grid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.reducedField', evt.Value));
            uilabel(grid, 'Text', '(e.g., 10 or logspace(1,2,10))'); % Hint

            row = row + 1;
            % Electron Temperature [cite: 1]
            uilabel(grid, 'Text', 'Electron Temperature (eV):');
            gui.UIControls.workingConditions.electronTemperature = uieditfield(grid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.electronTemperature', evt.Value));
            uilabel(grid, 'Text', '(e.g., 1.5 or linspace(0.1, 5, 20))'); % Hint

            row = row + 1;
            % Excitation Frequency [cite: 1]
            uilabel(grid, 'Text', 'Excitation Frequency (Hz):');
            gui.UIControls.workingConditions.excitationFrequency = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.excitationFrequency', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

            row = row + 1;
            % Gas Pressure [cite: 1]
            uilabel(grid, 'Text', 'Gas Pressure (Pa):');
            gui.UIControls.workingConditions.gasPressure = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.gasPressure', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

            row = row + 1;
            % Gas Temperature [cite: 1]
            uilabel(grid, 'Text', 'Gas Temperature (K):');
            gui.UIControls.workingConditions.gasTemperature = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.gasTemperature', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

            row = row + 1;
            % Wall Temperature [cite: 2]
            uilabel(grid, 'Text', 'Wall Temperature (K):');
            gui.UIControls.workingConditions.wallTemperature = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.wallTemperature', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

             row = row + 1;
            % External Temperature [cite: 2]
            uilabel(grid, 'Text', 'External Temperature (K):');
            gui.UIControls.workingConditions.extTemperature = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.extTemperature', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

            row = row + 1;
            % Surface Site Density [cite: 2]
            uilabel(grid, 'Text', 'Surface Site Density (m^-2):');
            gui.UIControls.workingConditions.surfaceSiteDensity = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.surfaceSiteDensity', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

            row = row + 1;
            % Electron Density [cite: 3]
            uilabel(grid, 'Text', 'Electron Density (m^-3):');
            gui.UIControls.workingConditions.electronDensity = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.electronDensity', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

            row = row + 1;
            % Chamber Length [cite: 3]
            uilabel(grid, 'Text', 'Chamber Length (m):');
            gui.UIControls.workingConditions.chamberLength = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.chamberLength', evt.Value));
            uilabel(grid, 'Text', ''); % Hint

            row = row + 1;
            % Chamber Radius [cite: 3]
            uilabel(grid, 'Text', 'Chamber Radius (m):');
            gui.UIControls.workingConditions.chamberRadius = uieditfield(grid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'workingConditions.chamberRadius', evt.Value));
            uilabel(grid, 'Text', ''); % Hint
        end

        function createElectronKineticsPanel(gui, parent)
            % Main grid for electron kinetics panel
            grid = uigridlayout(parent, [4, 1]);
            grid.RowHeight = {'fit', 'fit', 'fit', '1x'}; % Last row takes remaining space
            grid.Padding = [5 5 5 5];
            grid.RowSpacing = 10;

            % --- General Settings Panel ---
            generalPanel = uipanel(grid, 'Title', 'General Kinetics Settings');
            generalPanel.Layout.Row = 1;
            generalGrid = uigridlayout(generalPanel, [5, 2]); % Rows, Columns
            generalGrid.ColumnWidth = {'fit', '1x'};
            generalGrid.RowHeight = repmat({'fit'}, 1, 5);
            generalGrid.Padding = [10 10 10 10];
            generalGrid.RowSpacing = 5;

            row = 1;
            % Is On [cite: 4]
            gui.UIControls.electronKinetics.isOn = uicheckbox(generalGrid, 'Text', 'Enable Electron Kinetics', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.isOn', evt.Value));
            gui.UIControls.electronKinetics.isOn.Layout.Column = [1, 2]; % Span columns

            row = row + 1;
            % EEDF Type [cite: 4]
            uilabel(generalGrid, 'Text', 'EEDF Type:');
            gui.UIControls.electronKinetics.eedfType = uidropdown(generalGrid, 'Items', {'boltzmann', 'prescribedEedf'}, 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.eedfType', evt.Value));

            row = row + 1;
            % Ionization Operator Type [cite: 5]
            uilabel(generalGrid, 'Text', 'Ionization Operator:');
            gui.UIControls.electronKinetics.ionizationOperatorType = uidropdown(generalGrid, 'Items', {'conservative', 'oneTakesAll', 'equalSharing', 'usingSDCS'}, 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.ionizationOperatorType', evt.Value));

            row = row + 1;
            % Growth Model Type [cite: 5]
            uilabel(generalGrid, 'Text', 'Growth Model:');
            gui.UIControls.electronKinetics.growthModelType = uidropdown(generalGrid, 'Items', {'temporal', 'spatial'}, 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.growthModelType', evt.Value));

            row = row + 1;
            % Include e-e Collisions [cite: 5]
            gui.UIControls.electronKinetics.includeEECollisions = uicheckbox(generalGrid, 'Text', 'Include e-e Collisions', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.includeEECollisions', evt.Value));
            gui.UIControls.electronKinetics.includeEECollisions.Layout.Column = [1, 2];

            % --- Files and Gases Panel ---
            filesPanel = uipanel(grid, 'Title', 'Cross Sections & Gases');
            filesPanel.Layout.Row = 2;
            filesGrid = uigridlayout(filesPanel, [2, 3]); % Rows, Columns
            filesGrid.ColumnWidth = {'1x', 'fit', 'fit'}; % List, Add, Remove
            filesGrid.RowHeight = {'fit', 'fit'};
            filesGrid.Padding = [10 10 10 10];
            filesGrid.RowSpacing = 5;
            filesGrid.ColumnSpacing = 5;

            % LXCat Files [cite: 5]
            uilabel(filesGrid, 'Text', 'LXCat Files:');
            gui.UIControls.electronKinetics.LXCatFiles = uilistbox(filesGrid, 'Multiselect', 'on');
            gui.UIControls.electronKinetics.LXCatFiles.Layout.Row = 1;
            gui.UIControls.electronKinetics.LXCatFiles.Layout.Column = 1;
            uibutton(filesGrid, 'Text', 'Add', 'ButtonPushedFcn', @(src,evt) gui.addListItem('electronKinetics.LXCatFiles', true)); % true = file browse
            uibutton(filesGrid, 'Text', 'Remove', 'ButtonPushedFcn', @(src,evt) gui.removeListItem('electronKinetics.LXCatFiles'));

            % CAR Gases [cite: 6]
            uilabel(filesGrid, 'Text', 'CAR Gases:');
            gui.UIControls.electronKinetics.CARgases = uilistbox(filesGrid, 'Multiselect', 'on');
            gui.UIControls.electronKinetics.CARgases.Layout.Row = 2;
            gui.UIControls.electronKinetics.CARgases.Layout.Column = 1;
            uibutton(filesGrid, 'Text', 'Add', 'ButtonPushedFcn', @(src,evt) gui.addListItem('electronKinetics.CARgases', false)); % false = text input dialog
            uibutton(filesGrid, 'Text', 'Remove', 'ButtonPushedFcn', @(src,evt) gui.removeListItem('electronKinetics.CARgases'));

            % --- Gas Properties Panel ---
            gasPropsPanel = uipanel(grid, 'Title', 'Gas Properties', 'Scrollable', 'on');
            gasPropsPanel.Layout.Row = 3;
            gasPropsGrid = uigridlayout(gasPropsPanel, [7, 3]); % Rows, Columns
            gasPropsGrid.ColumnWidth = {'fit', '1x', 'fit'}; % Label, Edit, Browse
            gasPropsGrid.RowHeight = repmat({'fit'}, 1, 7);
            gasPropsGrid.Padding = [10 10 10 10];
            gasPropsGrid.RowSpacing = 5;
            gasPropsGrid.ColumnSpacing = 10;

            % Mass File
            uilabel(gasPropsGrid, 'Text', 'Mass File:');
            gui.UIControls.electronKinetics.gasProperties.mass = uieditfield(gasPropsGrid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.gasProperties.mass', evt.Value));
            uibutton(gasPropsGrid, 'Text', 'Browse...', 'ButtonPushedFcn', @(src,evt) gui.browseFile('electronKinetics.gasProperties.mass'));

            row = row + 1;
            % Fractions
            uilabel(gasPropsGrid, 'Text', 'Gas Fractions:');
            gui.UIControls.electronKinetics.gasProperties.fraction = uilistbox(gasPropsGrid, 'Multiselect', 'on');
            gui.UIControls.electronKinetics.gasProperties.fraction.Layout.Row = row;
            gui.UIControls.electronKinetics.gasProperties.fraction.Layout.Column = 1;
            uibutton(gasPropsGrid, 'Text', 'Add', 'ButtonPushedFcn', @(src,evt) gui.addListItem('electronKinetics.gasProperties.fraction', false));
            uibutton(gasPropsGrid, 'Text', 'Remove', 'ButtonPushedFcn', @(src,evt) gui.removeListItem('electronKinetics.gasProperties.fraction'));

            row = row + 1;
            % Harmonic Frequency File
            uilabel(gasPropsGrid, 'Text', 'Harmonic Frequency File:');
            gui.UIControls.electronKinetics.gasProperties.harmonicFrequency = uieditfield(gasPropsGrid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.gasProperties.harmonicFrequency', evt.Value));
            uibutton(gasPropsGrid, 'Text', 'Browse...', 'ButtonPushedFcn', @(src,evt) gui.browseFile('electronKinetics.gasProperties.harmonicFrequency'));

            row = row + 1;
            % Anharmonic Frequency File
            uilabel(gasPropsGrid, 'Text', 'Anharmonic Frequency File:');
            gui.UIControls.electronKinetics.gasProperties.anharmonicFrequency = uieditfield(gasPropsGrid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.gasProperties.anharmonicFrequency', evt.Value));
            uibutton(gasPropsGrid, 'Text', 'Browse...', 'ButtonPushedFcn', @(src,evt) gui.browseFile('electronKinetics.gasProperties.anharmonicFrequency'));

            row = row + 1;
            % Rotational Constant File
            uilabel(gasPropsGrid, 'Text', 'Rotational Constant File:');
            gui.UIControls.electronKinetics.gasProperties.rotationalConstant = uieditfield(gasPropsGrid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.gasProperties.rotationalConstant', evt.Value));
            uibutton(gasPropsGrid, 'Text', 'Browse...', 'ButtonPushedFcn', @(src,evt) gui.browseFile('electronKinetics.gasProperties.rotationalConstant'));

            row = row + 1;
            % Electric Quadrupole Moment File
            uilabel(gasPropsGrid, 'Text', 'Electric Quadrupole Moment File:');
            gui.UIControls.electronKinetics.gasProperties.electricQuadrupoleMoment = uieditfield(gasPropsGrid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.gasProperties.electricQuadrupoleMoment', evt.Value));
            uibutton(gasPropsGrid, 'Text', 'Browse...', 'ButtonPushedFcn', @(src,evt) gui.browseFile('electronKinetics.gasProperties.electricQuadrupoleMoment'));

            row = row + 1;
            % OPB Parameter File
            uilabel(gasPropsGrid, 'Text', 'OPB Parameter File:');
            gui.UIControls.electronKinetics.gasProperties.OPBParameter = uieditfield(gasPropsGrid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.gasProperties.OPBParameter', evt.Value));
            uibutton(gasPropsGrid, 'Text', 'Browse...', 'ButtonPushedFcn', @(src,evt) gui.browseFile('electronKinetics.gasProperties.OPBParameter'));

            % --- State Properties Panel ---
            statePropsPanel = uipanel(grid, 'Title', 'State Properties');
            statePropsPanel.Layout.Row = 4;
            statePropsGrid = uigridlayout(statePropsPanel, [1, 3]);
            statePropsGrid.ColumnWidth = {'fit', '1x', 'fit'};
            statePropsGrid.RowHeight = {'1x'};
            statePropsGrid.Padding = [10 10 10 10];

            uilabel(statePropsGrid, 'Text', 'State Populations:');
            gui.UIControls.electronKinetics.stateProperties.population = uilistbox(statePropsGrid, ...
                'Multiselect', 'on', ...
                'Items', {});
            gui.UIControls.electronKinetics.stateProperties.population.Layout.Row = 1;
            gui.UIControls.electronKinetics.stateProperties.population.Layout.Column = 2;

            btnGrid = uigridlayout(statePropsGrid, [2, 1]);
            btnGrid.Layout.Row = 1;
            btnGrid.Layout.Column = 3;
            btnGrid.RowHeight = {'fit', 'fit'};
            btnGrid.Padding = [0 0 0 0];

            uibutton(btnGrid, 'Text', 'Add', 'ButtonPushedFcn', @(src,evt) gui.addListItem('electronKinetics.stateProperties.population', false));
            uibutton(btnGrid, 'Text', 'Remove', 'ButtonPushedFcn', @(src,evt) gui.removeListItem('electronKinetics.stateProperties.population'));

        end

        function createNumericsPanel(gui, parent)
            % Main grid for numerics panel
            grid = uigridlayout(parent, [2, 1]); % Energy Grid, Non-Linear Routines
            grid.RowHeight = {'fit', 'fit'};
            grid.Padding = [5 5 5 5];

            % --- Energy Grid Panel ---
            energyGridPanel = uipanel(grid, 'Title', 'Energy Grid Configuration');
            energyGridPanel.Layout.Row = 1;
            energyGridGrid = uigridlayout(energyGridPanel, [5, 2]); % Rows, Columns
            energyGridGrid.ColumnWidth = {'fit', '1x'};
            energyGridGrid.RowHeight = repmat({'fit'}, 1, 5);
            energyGridGrid.Padding = [10 10 10 10];
            energyGridGrid.RowSpacing = 5;

            row = 1;
            % Variable Grid [cite: 9]
            gui.UIControls.electronKinetics.numerics.energyGrid.variableGrid = uicheckbox(energyGridGrid, 'Text', 'Use Variable Energy Grid', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.energyGrid.variableGrid', evt.Value));
            gui.UIControls.electronKinetics.numerics.energyGrid.variableGrid.Layout.Column = [1, 2];

            row = row + 1;
            % First Energy Step [cite: 9]
            uilabel(energyGridGrid, 'Text', 'First Energy Step (eV):');
            gui.UIControls.electronKinetics.numerics.energyGrid.firstEnergyStep = uieditfield(energyGridGrid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.energyGrid.firstEnergyStep', evt.Value));

            row = row + 1;
            % Max Energy [cite: 10]
            uilabel(energyGridGrid, 'Text', 'Max Energy (eV):');
            gui.UIControls.electronKinetics.numerics.energyGrid.maxEnergy = uieditfield(energyGridGrid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.energyGrid.maxEnergy', evt.Value));

            row = row + 1;
            % Cell Number [cite: 10]
            uilabel(energyGridGrid, 'Text', 'Energy Cell Number:');
            gui.UIControls.electronKinetics.numerics.energyGrid.cellNumber = uieditfield(energyGridGrid, 'numeric', 'Limits', [1, Inf], 'ValueDisplayFormat', '%.0f', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.energyGrid.cellNumber', evt.Value));

            row = row + 1;
            % Max Power Balance Rel Error [cite: 12]
            uilabel(energyGridGrid, 'Text', 'Max Power Bal. Rel. Error:');
            gui.UIControls.electronKinetics.numerics.maxPowerBalanceRelError = uieditfield(energyGridGrid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.maxPowerBalanceRelError', evt.Value));

            % --- Non-Linear Routines Panel ---
            nonLinearPanel = uipanel(grid, 'Title', 'Non-Linear Routines');
            nonLinearPanel.Layout.Row = 2;
            nonLinearGrid = uigridlayout(nonLinearPanel, [3, 2]); % Rows, Columns
            nonLinearGrid.ColumnWidth = {'fit', '1x'};
            nonLinearGrid.RowHeight = repmat({'fit'}, 1, 3);
            nonLinearGrid.Padding = [10 10 10 10];
            nonLinearGrid.RowSpacing = 5;

            row = 1;
            % Algorithm [cite: 12]
            uilabel(nonLinearGrid, 'Text', 'Non-Linear Algorithm:');
            gui.UIControls.electronKinetics.numerics.nonLinearRoutines.algorithm = uidropdown(nonLinearGrid, 'Items', {'mixingDirectSolutions', 'temporalIntegration'}, 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.nonLinearRoutines.algorithm', evt.Value));

            row = row + 1;
            % Mixing Parameter [cite: 12]
            uilabel(nonLinearGrid, 'Text', 'Mixing Parameter:');
            gui.UIControls.electronKinetics.numerics.nonLinearRoutines.mixingParameter = uieditfield(nonLinearGrid, 'numeric', 'Limits', [0, 1], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.nonLinearRoutines.mixingParameter', evt.Value));

            row = row + 1;
            % Max EEDF Rel Error [cite: 12]
            uilabel(nonLinearGrid, 'Text', 'Max EEDF Rel. Error:');
            gui.UIControls.electronKinetics.numerics.nonLinearRoutines.maxEedfRelError = uieditfield(nonLinearGrid, 'numeric', 'Limits', [0, Inf], 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'electronKinetics.numerics.nonLinearRoutines.maxEedfRelError', evt.Value));

        end

        function createOutputPanel(gui, parent)
             grid = uigridlayout(parent, [4, 3]); % Rows, Columns
             grid.ColumnWidth = {'fit', '1x', 'fit'}; % Label, Control, Browse
             grid.RowHeight = {'fit', 'fit', 'fit', '1x'}; % Controls, Listbox takes rest
             grid.Padding = [10 10 10 10];
             grid.RowSpacing = 5;
             grid.ColumnSpacing = 10;

             row = 1;
             % Is On [cite: 14]
             gui.UIControls.output.isOn = uicheckbox(grid, 'Text', 'Enable Output', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'output.isOn', evt.Value));
             gui.UIControls.output.isOn.Layout.Column = [1, 3]; % Span columns

             row = row + 1;
             % Data Format [cite: 14]
             uilabel(grid, 'Text', 'Data Format:');
             gui.UIControls.output.dataFormat = uidropdown(grid, 'Items', {'txt', 'hdf5', 'hdf5+txt'}, 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'output.dataFormat', evt.Value));

             row = row + 1;
             % Output Folder [cite: 14]
             uilabel(grid, 'Text', 'Output Folder:');
             gui.UIControls.output.folder = uieditfield(grid, 'text', 'ValueChangedFcn', @(src, evt) gui.updateField(src, 'output.folder', evt.Value));
             uibutton(grid, 'Text', 'Browse...', 'ButtonPushedFcn', @gui.browseFolder);

             row = row + 1;
             % Data Sets [cite: 14]
             uilabel(grid, 'Text', 'Data Sets to Save:');
             uilabel(grid, 'Text', ''); % Spacer
             uilabel(grid, 'Text', ''); % Spacer
             gui.UIControls.output.dataSets = uilistbox(grid, 'Items', {'inputs', 'log', 'eedf', 'swarmParameters', 'rateCoefficients', 'powerBalance', 'lookUpTable'}, 'Multiselect', 'on');
             gui.UIControls.output.dataSets.Layout.Row = row;
             gui.UIControls.output.dataSets.Layout.Column = [1, 3]; % Span columns
             % Note: Items are hardcoded now, could be dynamic based on solver capabilities
        end

        function populateGUIFromSetup(gui)
            % Populate all UI controls with values from gui.Setup
            % --- Top-level fields (e.g., workingConditions, electronKinetics, output) ---
            topLevelFields = fieldnames(gui.UIControls);
            for i = 1:length(topLevelFields)
                sectionName = topLevelFields{i}; % e.g., 'workingConditions'

                % --- Second-level fields (controls directly under the section) ---
                controlsInSection = fieldnames(gui.UIControls.(sectionName));
                for j = 1:length(controlsInSection)
                    controlName = controlsInSection{j}; % e.g., 'reducedField' or 'numerics'

                    control = gui.UIControls.(sectionName).(controlName);

                    % Check if this is a nested structure of controls (like 'numerics')
                    if isstruct(control)
                        % --- Third-level fields (e.g., under 'numerics') ---
                         subSectionName = controlName; % e.g., 'numerics'
                         controlsInSubSection = fieldnames(gui.UIControls.(sectionName).(subSectionName));
                         for k = 1:length(controlsInSubSection)
                             subControlName = controlsInSubSection{k}; % e.g., 'maxPowerBalanceRelError' or 'energyGrid'
                             subControl = gui.UIControls.(sectionName).(subSectionName).(subControlName);

                             if isstruct(subControl)
                                  % --- Fourth-level fields (e.g., under 'energyGrid' or 'nonLinearRoutines') ---
                                  subSubSectionName = subControlName; % e.g., 'energyGrid'
                                  controlsInSubSubSection = fieldnames(gui.UIControls.(sectionName).(subSectionName).(subSubSectionName));
                                  for l = 1:length(controlsInSubSubSection)
                                      subSubControlName = controlsInSubSubSection{l}; % e.g., 'variableGrid'
                                      subSubControl = gui.UIControls.(sectionName).(subSectionName).(subSubSectionName).(subSubControlName);
                                      dataPath = sprintf('%s.%s.%s.%s', sectionName, subSectionName, subSubSectionName, subSubControlName);
                                      gui.setControlValue(subSubControl, dataPath);
                                  end
                             else % Control is at third level (e.g., 'maxPowerBalanceRelError')
                                 dataPath = sprintf('%s.%s.%s', sectionName, subSectionName, subControlName);
                                 gui.setControlValue(subControl, dataPath);
                             end
                         end
                    else % Control is at second level (e.g., 'reducedField')
                        dataPath = sprintf('%s.%s', sectionName, controlName);
                        gui.setControlValue(control, dataPath);
                    end
                end
            end

            % Special handling for list boxes (setting Items source and Value)
            % These paths need to match your gui.Setup structure exactly
            try
                gui.UIControls.electronKinetics.LXCatFiles.Items = gui.Setup.electronKinetics.LXCatFiles;
                gui.UIControls.electronKinetics.LXCatFiles.Value = {}; % Clear selection initially
            catch ME
                 warning('Error setting LXCatFiles list: %s', '%s', ME.message);
            end
            try
                 gui.UIControls.electronKinetics.CARgases.Items = gui.Setup.electronKinetics.CARgases;
                 gui.UIControls.electronKinetics.CARgases.Value = {}; % Clear selection initially
            catch ME
                 warning('Error setting CARgases list: %s', '%s', ME.message);
            end
            try
                gui.UIControls.electronKinetics.gasProperties.fraction.Items = gui.Setup.electronKinetics.gasProperties.fraction;
                gui.UIControls.electronKinetics.gasProperties.fraction.Value = {}; % Clear selection initially
            catch ME
                 warning('Error setting gas fractions list: %s', '%s', ME.message);
            end
            try
                gui.UIControls.electronKinetics.stateProperties.population.Items = gui.Setup.electronKinetics.stateProperties.population;
                gui.UIControls.electronKinetics.stateProperties.population.Value = {}; % Clear selection initially
            catch ME
                 warning('Error setting state populations list: %s', '%s', ME.message);
            end
             try
                 % For output datasets, 'Items' are likely fixed, just set the selected 'Value'
                 gui.UIControls.output.dataSets.Value = gui.Setup.output.dataSets;
             catch ME
                 warning('Error setting dataSets list value: %s', '%s', ME.message);
             end
        end

        function setControlValue(gui, control, dataPath)
             % Helper function to get value from Setup and set control value
             try
                 value = gui.getNestedField(gui.Setup, dataPath);
                 if isempty(value) && ~ischar(value) % Allow empty char, but skip if truly empty/not found
                      fprintf('Debug: No value found for %s in Setup struct.\n', dataPath);
                      return;
                 end

                 if isa(control, 'matlab.ui.control.ListBox')
                     % For list boxes, we need to set Items first
                     if strcmp(dataPath, 'electronKinetics.LXCatFiles') || strcmp(dataPath, 'electronKinetics.CARgases') || ...
                        strcmp(dataPath, 'electronKinetics.gasProperties.fraction') || strcmp(dataPath, 'electronKinetics.stateProperties.population')
                         control.Items = value;
                         control.Value = {}; % Clear selection initially
                     else
                         % For other list boxes, just set the value
                         control.Value = value;
                     end
                 elseif isa(control, 'matlab.ui.control.DropDown')
                     % Items set separately, here we set the selected value
                     control.Value = value;
                 elseif isa(control, 'matlab.ui.control.CheckBox')
                     control.Value = logical(value); % Ensure its logical
                 elseif isa(control, 'matlab.ui.control.NumericEditField')
                     if isnumeric(value)
                         control.Value = value;
                     else % Handle non-numeric stored value if necessary
                         numVal = str2double(value);
                         control.Value = ifelse(isnan(numVal), 0, numVal); % Default to 0 if conversion fails
                         warning('Non-numeric value found for numeric field %s. Attempted conversion.', dataPath);
                     end
                 elseif isa(control, 'matlab.ui.control.EditField') % Text edit field
                     if isnumeric(value)
                         control.Value = num2str(value);
                     elseif ischar(value) || isstring(value)
                         control.Value = value;
                     elseif islogical(value)
                         control.Value = ifelse(value,'true','false');
                     else
                         % Try to convert other types (like arrays) to string
                         try
                             control.Value = mat2str(value);
                         catch
                             control.Value = ''; % Fallback
                             warning('Could not convert value for %s to string.', dataPath);
                         end
                     end
                 else
                     fprintf('Debug: Control type for %s not explicitly handled in setControlValue.\n', dataPath);
                 end
             catch ME
                 warning('Error setting control value for path %s: %s', dataPath, ME.message);
             end
        end


        % --- Callback Functions ---

        function updateField(gui, control, fieldPath, value)
            % Update a field in the Setup struct using dot notation path

            % Check if the control supports BackgroundColor for visual feedback
            supportsBackgroundColor = isa(control, 'matlab.ui.control.EditField') || ...
                                      isa(control, 'matlab.ui.control.NumericEditField'); % Add other types if they support it

            if supportsBackgroundColor
                originalColor = control.BackgroundColor; % Store original color
            end

             try
                % Handle specific types if necessary (e.g., numeric conversion)
                currentValue = gui.getNestedField(gui.Setup, fieldPath);
                 % --- Type Conversion Logic ---
                 % Check if the target field in Setup is numeric
                 if isnumeric(currentValue) && ~isa(value, 'logical') % Don't convert logicals to numeric
                     if ischar(value) || isstring(value) % Handle text input for numeric fields
                         numericValue = str2double(value);
                         if isnan(numericValue)
                             error('Invalid numeric input: "%s"', value);
                         end
                         value = numericValue; % Use the converted value
                     elseif ~isnumeric(value) % If it's neither string nor numeric (e.g., unexpected type)
                          error('Expected numeric or string input for numeric field, got %s', class(value));
                     end
                 % Add elseif blocks here if other specific type conversions are needed
                 end
                 % --- End Type Conversion ---

                 % Set the nested field in the Setup struct
                 gui.setNestedField(fieldPath, value);

                 % Provide visual feedback if supported
                 if supportsBackgroundColor
                     control.BackgroundColor = [0.9, 1.0, 0.9]; % Greenish tint on success
                     drawnow; % Ensure color update is visible briefly
                     pause(0.1);
                     control.BackgroundColor = originalColor; % Restore original color
                 end

             catch ME
                 warning('Error updating field "%s": %s', fieldPath, ME.message);
                 % Indicate error on the control if supported
                 if supportsBackgroundColor
                    control.BackgroundColor = [1.0, 0.8, 0.8]; % Reddish tint on error
                 else
                    % Alternative feedback for unsupported controls (e.g., brief message)
                    origTooltip = control.Tooltip;
                    control.Tooltip = sprintf('Error: %s', ME.message);
                    pause(1.5); % Show tooltip briefly
                    control.Tooltip = origTooltip;
                 end
                 % Optional: Restore the previous valid value from gui.Setup to the control
                 % try
                 %    previousValue = gui.getNestedField(gui.Setup, fieldPath);
                 %    control.Value = previousValue; % Revert UI (careful with control types)
                 % catch % Ignore errors during revert
                 % end
                 return; % Stop further processing if update failed
             end

             % Optional: Re-enable/disable controls based on the change
             if strcmp(fieldPath, 'electronKinetics.numerics.energyGrid.variableGrid')
                 gui.toggleEnergyStepEnable(~value);
             end
        end

        function setNestedField(gui, fieldPath, value)
            % Sets a value in a nested struct using a dot-separated path string
            parts = strsplit(fieldPath, '.');
            s = gui.Setup; % Start with the main struct

            % Traverse the structure except for the last part
            for i = 1:length(parts)-1
                if isfield(s, parts{i})
                    s = s.(parts{i});
                else
                    % If a field doesnt exist, maybe create it (careful!)
                     error('Field "%s" not found in path "%s"', parts{i}, fieldPath);
                    % Alternatively, create nested structs if needed:
                    % s.(parts{i}) = struct();
                    % s = s.(parts{i});
                end
            end

            % Set the value of the final field
            % Use eval to set the nested field dynamically (use with caution)
             assignCmd = sprintf('gui.Setup.%s = value;', fieldPath);
             eval(assignCmd);
            % Alternative (safer if possible):
            % s.(parts{end}) = value; % This only works if 's' points to the correct sub-struct
            % To make the alternative work, you need to pass sub-structs by reference,
            % which MATLAB doesnt do directly for structs. Handle classes would work.
            % Or reconstruct the assignment.
        end

        function value = getNestedField(gui, startStruct, fieldPath)
             % Gets a value from a nested struct using a dot-separated path string
             parts = strsplit(fieldPath, '.');
             currentValue = startStruct;
             try
                 for i = 1:length(parts)
                     currentValue = currentValue.(parts{i});
                 end
                 value = currentValue;
             catch ME
                 warning('Could not retrieve field: %s', fieldPath);
                 value = []; % Return empty or default if not found
             end
         end

         function toggleEnergyStepEnable(gui, shouldEnable)
             % Example function to enable/disable related controls
              control = gui.UIControls.electronKinetics.numerics.energyGrid.firstEnergyStep;
              label = findobj(control.Parent, 'Text', 'First Energy Step (eV):'); % Find associated label
              if shouldEnable
                  control.Enable = 'on';
                  if ~isempty(label)
                      label.Enable = 'on';
                  end
              else
                  control.Enable = 'off';
                  if ~isempty(label)
                      label.Enable = 'off';
                  end
              end
          end

        function addListItem(gui, fieldPath, browseFile)
             listBox = gui.getNestedField(gui.UIControls, fieldPath);
             currentItems = listBox.Items;

             newItem = '';
             if browseFile
                 [file, path] = uigetfile('*.*', ['Select file for ', fieldPath]);
                 if isequal(file, 0) || isequal(path, 0)
                     return; % User cancelled
                 end
                 newItem = fullfile(path, file);
             else
                 prompt = {['Enter new item for ', fieldPath, ':']};
                 dlgtitle = 'Add List Item';
                 dims = [1 50];
                 answer = inputdlg(prompt, dlgtitle, dims);
                 if isempty(answer)
                     return; % User cancelled
                 end
                 newItem = answer{1};
             end

             if ~isempty(newItem) && ~ismember(newItem, currentItems)
                 newItems = [currentItems; {newItem}];
                 listBox.Items = newItems;
                 % Update the Setup struct as well
                 gui.setNestedField(fieldPath, newItems);
             end
         end

         function removeListItem(gui, fieldPath)
             listBox = gui.getNestedField(gui.UIControls, fieldPath);
             selectedIndex = listBox.Value; % This might be indices if Multiselect is 'on'

             if isempty(selectedIndex)
                 uialert(gui.Fig, 'No item selected to remove.', 'Selection Error');
                 return;
             end

             currentItems = listBox.Items;
             currentItems(selectedIndex) = []; % Remove selected items
             listBox.Items = currentItems;
              listBox.Value = {}; % Clear selection

             % Update the Setup struct as well
             gui.setNestedField(fieldPath, currentItems);
         end

        function browseFolder(gui, ~, ~)
             folderPath = uigetdir(pwd, 'Select Output Folder'); % Start in current directory
             if ~isequal(folderPath, 0)
                 % Update the edit field and the setup struct
                 control = gui.UIControls.output.folder;
                 control.Value = folderPath;
                 gui.setNestedField('output.folder', folderPath); % Update setup directly
             end
         end

        function browseFile(gui, fieldPath)
             [file, path] = uigetfile('*.*', 'Select File'); % Allow any file type
             if ~isequal(file, 0) && ~isequal(path, 0)
                 % Update the edit field and the setup struct
                 fullPath = fullfile(path, file);
                 control = gui.getNestedField(gui.UIControls, fieldPath);
                 control.Value = fullPath;
                 gui.setNestedField(fieldPath, fullPath); % Update setup directly
             end
         end

        function loadSettings(gui, ~, ~)
            % Placeholder for loading settings from a file
            [file, path] = uigetfile('*.txt;*.setup', 'Load LoKI Setup File');
            if isequal(file, 0) || isequal(path, 0)
                return; % User cancelled
            end
            inputFile = fullfile(path, file);
            try
                % gui.Setup = gui.parseInputFile(inputFile); % Implement this
                gui.populateGUIFromSetup(); % Update UI
                uialert(gui.Fig, ['Settings loaded from ', file], 'Load Successful');
            catch ME
                uialert(gui.Fig, ['Error loading file: ', ME.message], 'Load Error');
            end
        end

        function saveInputFile(gui, ~, ~)
            % Save the current setup to a file
            defaultName = ['LoKI_Setup_', datestr(now,'yyyymmdd_HHMMSS'), '.txt'];
             startPath = gui.Setup.output.folder; % Suggest saving in output folder
             if ~isfolder(startPath)
                 startPath = pwd; % Fallback to current directory
             end
            [file, path] = uiputfile('*.txt', 'Save LoKI Input File As', fullfile(startPath, defaultName));

            if isequal(file, 0) || isequal(path, 0)
                uialert(gui.Fig, 'File save cancelled.', 'Cancelled');
                return; % User cancelled
            end

            outputFile = fullfile(path, file);
            try
                gui.generateInputFile(outputFile);
                uialert(gui.Fig, ['Input file saved successfully: ', outputFile], 'Save Successful');
            catch ME
                uialert(gui.Fig, ['Error saving file: ', ME.message], 'Save Error');
            end
        end


        function generateInputFile(gui, filename)
             % Generates the text input file from the gui.Setup struct
             fid = fopen(filename, 'w');
             if fid == -1
                 error('Cannot open file "%s" for writing.', filename);
             end
             fprintf(fid, '%% LoKI Input File generated by LoKI_GUI on %s %%\n\n', datestr(now));

             % Use recursion or explicit handling for nested structs
             sections = fieldnames(gui.Setup);
             for i = 1:length(sections)
                 sectionName = sections{i};
                 fprintf(fid, '%s:\n', sectionName); % Section header
                 gui.writeStructContent(gui.Setup.(sectionName), '  ', fid); % Indent content
                 fprintf(fid, '\n'); % Blank line between sections
             end

             fclose(fid);
             fprintf('Input file generated: %s\n', filename);
         end

         function writeStructContent(gui, s, indent, fid)
            % Helper function to recursively write struct content to file
            fields = fieldnames(s);
            for i = 1:length(fields)
                fieldName = fields{i};
                value = s.(fieldName);

                if isstruct(value)
                    fprintf(fid, '%s%s:\n', indent, fieldName);
                    gui.writeStructContent(value, [indent, '  '], fid); % Recurse with more indent
                elseif iscell(value) % Handle lists (cell arrays)
                    fprintf(fid, '%s%s:\n', indent, fieldName);
                    for j = 1:length(value)
                        fprintf(fid, '%s  - %s\n', indent, gui.formatValue(value{j}));
                    end
                elseif islogical(value)
                    if value
                        fprintf(fid, '%s%s: true\n', indent, fieldName);
                    else
                        fprintf(fid, '%s%s: false\n', indent, fieldName);
                    end
                elseif isnumeric(value)
                    if isscalar(value)
                        fprintf(fid, '%s%s: %s\n', indent, fieldName, num2str(value));
                    else
                        fprintf(fid, '%s%s: %s\n', indent, fieldName, mat2str(value));
                    end
                elseif ischar(value) || isstring(value)
                    fprintf(fid, '%s%s: %s\n', indent, fieldName, value);
                else
                    warning('Unhandled value type for field %s: %s', fieldName, class(value));
                end
            end
        end

         function strValue = formatValue(~, value)
             % Format different value types for the output file
             if ischar(value) || isstring(value)
                 strValue = char(value); % Ensure it's char, handle strings/expressions
             elseif isnumeric(value)
                 if isscalar(value)
                     strValue = num2str(value, '%.8g'); % Format numbers nicely
                 else
                     strValue = mat2str(value); % Use mat2str for arrays/vectors
                 end
             elseif islogical(value) % Should be handled before calling formatValue
                 if value
                     strValue = 'true';
                 else
                     strValue = 'false';
                 end
             else
                 strValue = ''; % Fallback for unknown types
             end
         end

        function runSimulation(gui, ~, ~)
            % 1. Generate the input file (e.g., to a temporary location or specific output)
                
             tempInputFile = fullfile(['Input' filesep 'loki_run_' datestr(now,'yyyymmdd_HHMMSSFFF') '.txt']);
             try
                 gui.generateInputFile(tempInputFile);
             catch ME
                 uialert(gui.Fig, ['Error generating temporary input file: ', ME.message], 'Run Error');
                 return;
             end

            % 2. thanks gpt! Call the actual LoKI Boltzmann solver
             %    This is where you link to your solver code.
             %    You might need to pass the path to the generated input file.
             fprintf('--- Running Simulation (Conceptual) ---\n');
             fprintf('Using input file: %s\n', tempInputFile);
             fprintf('Setup details:\n');
             disp(gui.Setup); % Display current setup in console for debugging

             % try
                 % --- Replace this with the actual call to your solver ---
                 % Example: status = run_loki_solver(tempInputFile);
                 lokibcl(tempInputFile(7:end)); % Placeholder for success
                 % Run the simulation
                 
            
                
                 
                 

             % catch ME
             %     uialert(gui.Fig, ['Error occurred during simulation: ', ME.message], 'Simulation Runtime Error');
             % end

             % Optional: Clean up temporary file
             % delete(tempInputFile);
             fprintf('--- Simulation Finished ---\n');
         end
    end % methods
end % classdef