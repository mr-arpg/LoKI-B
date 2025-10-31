classdef Grid < handle
    %Grid Class that defines a grid with a non-uniform or uniform energy grid
    %   Non-uniform energy grid uses a geometric progression of step sizes.
    %   Uniform energy grid uses a constant step size.
    
    properties
        node = [];              % values of the grid at node positions
        cell = [];              % values of the grid at cell positions (middle point)
        energyStep = [];        % step values between consecutive nodes
        cellNumber = [];        % total number of cells in the energy grid
        variableGrid = false;   % whether to use variable grid (default: false)
        ratio = 1.1;            % ratio 'a' for geometric progression (default > 1)
        minEnergy = 0;          % minimum energy (default: 0)
        maxEnergy = [];         % maximum energy (user-defined)
        firstEnergyStep = [];   % first energy step (required if variableGrid is true)
        isSmart = false;        % smart properties of the energy grid (deactivated by default)
        minEedfDecay = [];      % minimum number of decades of decay for the EEDF
        maxEedfDecay = [];      % maximum number of decades of decay for the EEDF
        updateFactor = [];      % percentage factor to update the maximum value of the energy grid
    end
    
    events
        updatedMaxEnergy1
        updatedMaxEnergy2
    end

    methods
        function grid = Grid(gridProperties)
            % Constructor for Grid class
            
            % Set default or input properties
            grid.cellNumber = gridProperties.cellNumber;
            grid.maxEnergy = gridProperties.maxEnergy;
            
            % Check if variableGrid is provided and set it
            if isfield(gridProperties, 'variableGrid')
                grid.variableGrid = gridProperties.variableGrid;
            end
            
            % If variableGrid is true, firstEnergyStep must be provided
            if grid.variableGrid
                if ~isfield(gridProperties, 'firstEnergyStep')
                    error('firstEnergyStep must be provided when variableGrid is true.');
                end
                grid.firstEnergyStep = gridProperties.firstEnergyStep;
                
                % Perform self-diagnostic test
                grid.selfDiagnosticTest();                
                % Compute the progression ratio 'a'
                grid.computeProgressionRatio();
                % Compute the nodes using geometric progression
                grid.computeGeometricGrid();
            
            else
                % Compute the nodes using constant energy step
                grid.computeUniformGrid();
            end
            
        end

        function computeProgressionRatio(grid)
            % Define the function F(a) for solving progression ratio 'a'
            F = @(a) exp(log((grid.maxEnergy / grid.firstEnergyStep) * ...
                (a - 1) + 1) / (grid.cellNumber)) - a;
            
            % Use fzero to solve for progression ratio 'a'
            options = optimset('Display', 'iter'); % show iterations
            solution = fzero(F, [1+1E-15, 3], options); %default: 1+1E-15
            
            grid.ratio = solution;  % MATLAB's built-in root-finding method

            % Check if the solution is valid
            if grid.ratio <= 1
                error('Invalid progression ratio "a". Ensure that maxEnergy and firstEnergyStep are consistent.');
            end
        end
        
        function selfDiagnosticTest(grid)
            % Self-diagnostic test to ensure the progression ratio 'a' is valid
            if grid.variableGrid
                % Check if the total sum of steps would exceed maxEnergy
                if grid.firstEnergyStep * grid.cellNumber >= grid.maxEnergy
                    error(['Invalid progression ratio "a" (>= 1). Ensure that maxEnergy and firstEnergyStep are consistent. ' ...
                           'Consider using a smaller value for firstEnergyStep.']); 
                end
                
                % Check stability condition for the entire grid
                % We want to ensure that for any step m, u_m > 3/4 * delta_u_{m+1}
                % This is equivalent to checking that the ratio 'a' satisfies:
                % a < 4/3 for all steps
                
                % % Compute the maximum allowed ratio based on the stability condition
                % maxAllowedRatio = 4/3;
                % 
                % % Estimate the required ratio based on the grid parameters
                % estimatedRatio = (grid.maxEnergy ./ grid.firstEnergyStep).^(1/grid.cellNumber);
                % 
                % if estimatedRatio >= maxAllowedRatio
                %     error(['Stability condition violated: Estimated ratio (%.4f) exceeds maximum allowed ratio (%.4f). ' ...
                %           'Consider using a larger firstEnergyStep or more cells.'], ...
                %           estimatedRatio, maxAllowedRatio);
                % end
                % 
                % % Additional check for numerical stability
                % % Ensure that the ratio doesn't lead to too large steps at high energies
                % maxStep = grid.firstEnergyStep .* estimatedRatio.^(grid.cellNumber-1);
                % if any(maxStep > grid.maxEnergy/10)
                %     error(['Numerical stability warning: Maximum step size (%.4f) is too large compared to maxEnergy (%.4f). ' ...
                %           'Consider using more cells or a smaller firstEnergyStep.'], ...
                %           max(maxStep), max(grid.maxEnergy));
                % end
            end
        end

        function computeGeometricGrid(grid)
            % Compute node and cell values for a non-uniform geometric progression grid
            grid.node = zeros(1, grid.cellNumber + 1); % Initialize node array
            grid.energyStep = zeros(1, grid.cellNumber); % Initialize step sizes
            
            % Define the first step size (u1)
            u1 = grid.firstEnergyStep;
            
            % Compute nodes and steps using geometric progression
            grid.node(1) = 0; % Starting energy
            for n = 1:grid.cellNumber
                grid.energyStep(n) = u1 * grid.ratio^(n - 1);
                grid.node(n + 1) = grid.node(n) + grid.energyStep(n);
            end

            % Compute cell values as midpoints between nodes
            grid.cell = 0.5 * (grid.node(1:end-1) + grid.node(2:end));
        end

        function computeUniformGrid(grid)
            % Compute node and cell values for a uniform energy grid
            grid.node = linspace(0, grid.maxEnergy, grid.cellNumber + 1); % Uniformly spaced nodes
            grid.energyStep = diff(grid.node); % Constant step sizes
            
            % Compute cell values as midpoints between nodes
            grid.cell = 0.5 * (grid.node(1:end-1) + grid.node(2:end));
        end

        function updateMaxValue(grid, maxValue)
            % Resize the grid with a new maximum value and recompute the nodes
            grid.maxEnergy = maxValue;
            if grid.variableGrid
                grid.computeProgressionRatio();
                grid.computeGeometricGrid();
            else
                grid.computeUniformGrid();
            end
            
            % Broadcast changes
            notify(grid, 'updatedMaxEnergy1'); % update interpolations of collision cross-sections
            notify(grid, 'updatedMaxEnergy2'); % update operators of the Boltzmann equation
        end

        function cellNumber = findCellNumber(grid, energy)
            % Calculate the cell number for a given energy value
            if energy < grid.node(1) || energy > grid.node(end)
                error('Energy value is outside the grid range.');
            end
            
            if grid.variableGrid
                % For variable grid, use the geometric progression formula
                u1 = grid.energyStep(1);
                a = grid.ratio;
                cellNumber = floor(log(energy / u1 * (a - 1) + 1) / log(a) + 1);
            else
                % For uniform grid, use linear interpolation
                cellNumber = floor(energy / (grid.maxEnergy / grid.cellNumber));
            end
        end
    end
end