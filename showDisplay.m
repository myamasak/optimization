classdef showDisplay < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes_2                       matlab.ui.control.UIAxes
        OptimizationselectionDropDownLabel  matlab.ui.control.Label
        OptimizationselectionDropDown  matlab.ui.control.DropDown
        ProblemselectionDropDownLabel  matlab.ui.control.Label
        ProblemselectionDropDown       matlab.ui.control.DropDown
    end

    
    properties (Access = private)
        %        load Runs10D.mat
    end
    
    
    methods (Access = public)
        
        function plotFunction(app)
            load('Runs10D.mat')
            load('Runs30D.mat')
            %Dimension-related declarations
            dimensions = [10, 30];
            %Runs for both dimensions
            allRuns = {runs10D, runs30D};  
            
            
            selOpt = app.OptimizationselectionDropDown.Value;
            selProblem = app.ProblemselectionDropDown.Value;
            
            switch selProblem
                case 'Sphere Function'
                    probNum = 1;
                case 'Rotated High Conditioned Elliptic Function'
                    probNum = 2;
                case 'Rotated Bent Cigar Function'
                    probNum = 3;
                case 'Rotated Discus Function'
                    probNum = 4;
                case 'Different Powers Function'
                    probNum = 5;
            end
            % dropdown switch case to plot
            switch selOpt
                case 'Nelder-Mead'
                    optNum = 1;
                    %                     plot(app.UIAxes,rand(5));
                case 'Hooke-Jeeves'
                    optNum = 2;
                    %                     plot(app.UIAxes,sin(1:0.01:25.99));
                case 'Implicit Filtering'
                    optNum = 3;
                    %                     bar(app.UIAxes,1:.5:10);
                case 'Multidirectional Search'
                    optNum = 4;
                    %                     plot(app.UIAxes,membrane);
                case 'Pattern Search'
                    optNum = 5;
                    %                     surf(app.UIAxes,peaks);
            end
            
            for i0 = 1:numel(dimensions)
                runs = allRuns{i0};
                switch i0
                    case 1
                        axesSel = app.UIAxes;
                    case 2
                        axesSel = app.UIAxes_2;
                end
                
                % Clear previous plots
                axesSel.cla;
                % Reset axes position
                reset(axesSel)
            
                samples = runs(optNum, probNum, end).samples;
                maxFES = runs(optNum, probNum, end).maxFES;
                
                %Residual errors
                errors = zeros(size(runs, 3), samples);
                
                %Final errors for each run
                finalValues = zeros(1, size(runs, 3));
                
                % Run loop
                for i1 = 1:size(runs, 3)
                    run = runs(optNum, probNum, i1);
                    errors(i1, :) = [run.solutions.y] - run.globalMin;
                    
                    %If the error is lower than epsillon, consider as zero
                    finalValues(i1) = errors(i1, end);
                    finalValues(finalValues < run.epsillon) = 0;
                end
                
                t = linspace(0, 1, samples) * maxFES;
                semilogy(axesSel,t, max(errors), 'b');
                grid(axesSel,"on")
                hold(axesSel,"on")
                semilogy(axesSel,t, min(errors), 'r');
                grid(axesSel,"on")
                xlabel(axesSel,'Avaliacoes');
                ylabel(axesSel,'Erro residual');
                legend(axesSel,{'Pior' ,'Melhor'});
                title(axesSel,sprintf('%d Dimensoes', dimensions(i0)));
                
            end
        end
    end
    
    methods (Access = public)
        
        function exerc1Function(app)
            %% General initialization
            %Load generated results
            %Load the results for the 10D optimizations
            if ~exist('runs10D', 'var')
                load('Runs10D.mat');
            end
            
            %Load the results for the 30D optimizations
            if ~exist('runs30D', 'var')
                load('Runs30D.mat');
            end
            
            %Dimension-related declarations
            dimensions = [10, 30];
            
            %Algorithm-related declarations
            algorithmNames = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering',...
                'Multidirectional Search', 'Pattern Search', 'Genetic Algorithm'};
            
            %Function-related declarations
            functionNames = {'Sphere Function',...
                'Rotated High Conditioned Elliptic Function',...
                'Rotated Bent Cigar Function',...
                'Rotated Discus Function',...
                'Different Powers Function'};
            
            %Runs for both dimensions
            allRuns = { runs10D, runs30D };
            
            %% Plot initialization
            %Creates a plot for every algorithm-function pair
            % handles = {};
            % for i = 1:(numel(algorithmNames) * numel(functionNames))
            %     handles = cat(2, handles, figure());
            %     handles(i).Position = handles(i).Position + [0 0 300 0];
            % end
            
            %% Dimensions loop
            for i = 1:numel(dimensions)
                
                %Dimension runs
                runs = allRuns{i};
                
                %% Algorithm loop
                for j = 1:numel(algorithmNames)
                    
                    %Create a table to display the information
                    tab = table();
                    
                    %% Function loop
                    for k = 1:numel(functionNames)
                        
                        samples = runs(j, k, end).samples;
                        maxFES = runs(j, k, end).maxFES;
                        
                        %Residual errors
                        %                         errors = zeros(size(runs, 3), samples);
                        
                        %Final errors for each run
                        %                         finalValues = zeros(1, size(runs, 3));
                        
                        %% Run loop
                        %                         for m = 1:size(runs, 3)
                        %                             run = runs(j, k, m);
                        %                             errors(m, :) = [run.solutions.y] - run.globalMin;
                        %
                        %                             %If the error is lower than epsillon, consider as zero
                        %                             finalValues(m) = errors(m, end);
                        %                             finalValues(finalValues < run.epsillon) = 0;
                        %                         end
                        
                        %Select the correct plot
                        %             handle = handles((j - 1) * numel(functionNames) + k);
                        %             handle.Name = sprintf('%s - %s', algorithmNames{j}, functionNames{k});
                        %             handle.NumberTitle = 'off';
                        % figure(handle);
                        
                        %Plot the worst and best curves
                        % t = linspace(0, 1, samples) * maxFES;
                        % subplot(1, 2, i);
                        % semilogy(t, max(errors), 'b');
                        % grid on;
                        % hold on;
                        % semilogy(t, min(errors), 'r');
                        % grid on;
                        % xlabel('Avaliacoes');
                        % ylabel('Erro residual');
                        % legend({'Pior' ,'Melhor'});
                        % title(sprintf('%d Dimensoes', dimensions(i)));
                        
                        %Insert values into the table
                        %                         tab(k, :) = { min(finalValues),...
                        %                             mean(finalValues),...
                        %                             max(finalValues),...
                        %                             std(finalValues) };
                    end
                    
                end
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
%             exerc1Function(app)
            plotFunction(app)
            
        end

        % Value changed function: OptimizationselectionDropDown, 
        % ProblemselectionDropDown
        function OptimizationselectionDropDownValueChanged(app, event)
            plotFunction(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1400 900];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [1 275 527 450];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Title')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            app.UIAxes_2.Position = [527 275 527 450];

            % Create OptimizationselectionDropDownLabel
            app.OptimizationselectionDropDownLabel = uilabel(app.UIFigure);
            app.OptimizationselectionDropDownLabel.HorizontalAlignment = 'right';
            app.OptimizationselectionDropDownLabel.Position = [86 821 123 22];
            app.OptimizationselectionDropDownLabel.Text = 'Optimization selection';

            % Create OptimizationselectionDropDown
            app.OptimizationselectionDropDown = uidropdown(app.UIFigure);
            app.OptimizationselectionDropDown.Items = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering', 'Multidirectional Search', 'Pattern Search'};
            app.OptimizationselectionDropDown.ValueChangedFcn = createCallbackFcn(app, @OptimizationselectionDropDownValueChanged, true);
            app.OptimizationselectionDropDown.Position = [224 821 219 22];
            app.OptimizationselectionDropDown.Value = 'Nelder-Mead';

            % Create ProblemselectionDropDownLabel
            app.ProblemselectionDropDownLabel = uilabel(app.UIFigure);
            app.ProblemselectionDropDownLabel.HorizontalAlignment = 'right';
            app.ProblemselectionDropDownLabel.Position = [108 775 101 22];
            app.ProblemselectionDropDownLabel.Text = 'Problem selection';

            % Create ProblemselectionDropDown
            app.ProblemselectionDropDown = uidropdown(app.UIFigure);
            app.ProblemselectionDropDown.Items = {'Sphere Function', 'Rotated High Conditioned Elliptic Function', 'Rotated Bent Cigar Function', 'Rotated Discus Function', 'Different Powers Function'};
            app.ProblemselectionDropDown.ValueChangedFcn = createCallbackFcn(app, @OptimizationselectionDropDownValueChanged, true);
            app.ProblemselectionDropDown.Position = [224 775 219 22];
            app.ProblemselectionDropDown.Value = 'Sphere Function';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = showResults

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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