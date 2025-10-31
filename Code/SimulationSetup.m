classdef SimulationSetup < handle
    %SimulationSetup Class that handles simulation setup and running
    
    properties
        workingConditions = struct();
        electronKinetics = struct();
        gui = struct();
        output = struct();
    end
    
    methods
        function setup = SimulationSetup()
            % Constructor - set default values
            setup.workingConditions = struct(...
                'reducedField', logspace(-4,3,100), ...
                'electronTemperature', linspace(0.03, 10, 100), ...
                'excitationFrequency', 0, ...
                'gasPressure', 133.32, ...
                'gasTemperature', 300, ...
                'wallTemperature', 130, ...
                'extTemperature', 300, ...
                'surfaceSiteDensity', 1e19, ...
                'electronDensity', 1e16, ...
                'chamberLength', 1.0, ...
                'chamberRadius', 1.0);
            
            setup.electronKinetics = struct(...
                'isOn', true, ...
                'eedfType', 'boltzmann', ...
                'ionizationOperatorType', 'usingSDCS', ...
                'growthModelType', 'temporal', ...
                'includeEECollisions', true, ...
                'LXCatFiles', {{'Hydrogen/H2_elastic_LXCat.txt', 'Hydrogen/H2_rot_LXCat.txt'}}, ...
                'CARgases', {{'H2'}}, ...
                'gasProperties', struct(...
                    'mass', 'Databases/masses.txt', ...
                    'fraction', struct('H2', 1), ...
                    'harmonicFrequency', 'Databases/harmonicFrequencies.txt', ...
                    'anharmonicFrequency', 'Databases/anharmonicFrequencies.txt', ...
                    'rotationalConstant', 'Databases/rotationalConstants.txt', ...
                    'electricQuadrupoleMoment', 'Databases/quadrupoleMoment.txt', ...
                    'OPBParameter', 'Databases/OPBParameter.txt'), ...
                'stateProperties', struct('population', {{'H2(X)', 1.0}}), ...
                'numerics', struct(...
                    'energyGrid', struct(...
                        'variableGrid', true, ...
                        'firstEnergyStep', 1e-4, ...
                        'maxEnergy', 100, ...
                        'cellNumber', 400), ...
                    'maxPowerBalanceRelError', 1e-9, ...
                    'nonLinearRoutines', struct(...
                        'algorithm', 'mixingDirectSolutions', ...
                        'mixingParameter', 0.5, ...
                        'maxEedfRelError', 1e-9)));
            
            setup.gui = struct(...
                'isOn', true, ...
                'refreshFrequency', 1);
            
            setup.output = struct(...
                'isOn', true, ...
                'dataFormat', 'txt', ...
                'folder', 'H2Swarm', ...
                'dataSets', {{'log', 'eedf', 'swarmParameters', 'rateCoefficients', 'powerBalance', 'lookUpTable'}});
        end
        
        function saveToFile(setup, filename)
            % Save the current setup to a YAML file
            fid = fopen(filename, 'w');
            
            % Write working conditions
            fprintf(fid, 'workingConditions:\n');
            fields = fieldnames(setup.workingConditions);
            for i = 1:length(fields)
                value = setup.workingConditions.(fields{i});
                if isnumeric(value)
                    fprintf(fid, '  %s: %s\n', fields{i}, mat2str(value));
                else
                    fprintf(fid, '  %s: %s\n', fields{i}, value);
                end
            end
            
            % Write electron kinetics
            fprintf(fid, '\nelectronKinetics:\n');
            fields = fieldnames(setup.electronKinetics);
            for i = 1:length(fields)
                value = setup.electronKinetics.(fields{i});
                if isstruct(value)
                    fprintf(fid, '  %s:\n', fields{i});
                    subfields = fieldnames(value);
                    for j = 1:length(subfields)
                        subvalue = value.(subfields{j});
                        if isstruct(subvalue)
                            fprintf(fid, '    %s:\n', subfields{j});
                            subsubfields = fieldnames(subvalue);
                            for k = 1:length(subsubfields)
                                fprintf(fid, '      %s: %s\n', subsubfields{k}, num2str(subvalue.(subsubfields{k})));
                            end
                        elseif iscell(subvalue) && strcmp(subfields{j}, 'population')
                            % Special handling for population list
                            fprintf(fid, '    %s:\n', subfields{j});
                            for k = 1:2:length(subvalue)
                                fprintf(fid, '      - %s = %s\n', subvalue{k}, num2str(subvalue{k+1}));
                            end
                        elseif isnumeric(subvalue)
                            fprintf(fid, '    %s: %s\n', subfields{j}, mat2str(subvalue));
                        else
                            fprintf(fid, '    %s: %s\n', subfields{j}, subvalue);
                        end
                    end
                elseif iscell(value)
                    fprintf(fid, '  %s:\n', fields{i});
                    for j = 1:length(value)
                        fprintf(fid, '    - %s\n', value{j});
                    end
                else
                    fprintf(fid, '  %s: %s\n', fields{i}, value);
                end
            end
            
            % Write GUI and output settings
            fprintf(fid, '\ngui:\n');
            fields = fieldnames(setup.gui);
            for i = 1:length(fields)
                fprintf(fid, '  %s: %s\n', fields{i}, setup.gui.(fields{i}));
            end
            
            fprintf(fid, '\noutput:\n');
            fields = fieldnames(setup.output);
            for i = 1:length(fields)
                if iscell(setup.output.(fields{i}))
                    fprintf(fid, '  %s:\n', fields{i});
                    for j = 1:length(setup.output.(fields{i}))
                        fprintf(fid, '    - %s\n', setup.output.(fields{i}){j});
                    end
                else
                    fprintf(fid, '  %s: %s\n', fields{i}, setup.output.(fields{i}));
                end
            end
            
            fclose(fid);
        end
        
        function runSimulation(setup)
            % Create a temporary input file
            tempFile = 'temp_input.in';
            setup.saveToFile(tempFile);
            
            % Run the simulation
            lokibcl(tempFile);
            
            % Delete the temporary file
            delete(tempFile);
        end
    end
end 