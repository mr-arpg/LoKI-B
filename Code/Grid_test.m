classdef Grid < handle
  %Grid Class that defines a grid and its interactions with other objects
  %   Class that defines a grid and its interactions with other objects. A
  %   grid object stores three properties: the values of the grid at node 
  %   positions, the values of the grid at cell positions (middle point) and 
  %   the step of the grid. 
  %   Node values -> |     |     |     |     |     |     |     |
  %   Grid        -> o-----o-----o-----o-----o-----o-----o-----o
  %   Cell values ->    |     |     |     |     |     |     |
  
  properties
    node = [];              % values of the grid at node positions
    cell = [];              % values of the grid at cell positions (i.e. between two consecutive nodes)
    step = [];              % difference between the values at two consecutive nodes
    cellNumber = [];        % number of cells in the energy grid
    progressionRatio = 1.1; % geometric progression ratio (default > 1)
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
      grid.cellNumber = gridProperties.cellNumber;
      % Check if progressionRatio exists in gridProperties; if not, set a default value
      if isfield(gridProperties, 'progressionRatio')
        grid.progressionRatio = gridProperties.progressionRatio;
      else
        grid.progressionRatio = 1.1; % Default progression ratio
      end
      
      grid.computeGeometricGrid(gridProperties.maxEnergy);     % Use geometric progression for grid
      if isfield(gridProperties, 'smartGrid')
        grid.isSmart = true;
        grid.minEedfDecay = gridProperties.smartGrid.minEedfDecay;
        grid.maxEedfDecay = gridProperties.smartGrid.maxEedfDecay;
        grid.updateFactor = gridProperties.smartGrid.updateFactor;
      end
    end
    
    
    function computeGeometricGrid(grid, maxEnergy)
      % Compute the grid nodes and cells using a geometric progression
      grid.node = zeros(1, grid.cellNumber + 1); % Initialize node array
      grid.step = zeros(1, grid.cellNumber);     % Initialize step sizes
      
      % Define the first step size (u1)
      u1 = maxEnergy * (grid.progressionRatio - 1) / (grid.progressionRatio^grid.cellNumber - 1);
      
      % Compute nodes and steps using geometric progression
      grid.node(1) = 0; % Starting energy (minimum energy is 0)
      for n = 1:grid.cellNumber
          grid.step(n) = u1 * grid.progressionRatio^(n - 1);
          grid.node(n + 1) = grid.node(n) + grid.step(n);
      end
      
      % Compute cell values as midpoints between nodes
      grid.cell = 0.5 * (grid.node(1:end-1) + grid.node(2:end));
    end

    function updateMaxValue(grid, maxValue)
      % Resize the grid with a new maximum value
      grid.computeGeometricGrid(maxValue); % Recompute nodes using the new max value
      
      % Broadcast change in the grid
      notify(grid, 'updatedMaxEnergy1'); % update interpolations of collision cross-sections
      notify(grid, 'updatedMaxEnergy2'); % update operators of the Boltzmann equation
    end
  end
end
