classdef showResults_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes_2                       matlab.ui.control.UIAxes
        UITable                        matlab.ui.control.Table
        ResidualErrorLabel             matlab.ui.control.Label
        RefreshButton                  matlab.ui.control.Button
        UITable_2                      matlab.ui.control.Table
        PrecisionLabel                 matlab.ui.control.Label
        UITable_3                      matlab.ui.control.Table
        SuccessRatePerformanceLabel    matlab.ui.control.Label
        UITable_4                      matlab.ui.control.Table
        AlgorithmComplexityLabel       matlab.ui.control.Label
        OptimizationselectionDropDownLabel  matlab.ui.control.Label
        OptimizationselectionDropDown  matlab.ui.control.DropDown
        ProblemselectionDropDownLabel  matlab.ui.control.Label
        ProblemselectionDropDown       matlab.ui.control.DropDown
        TabGroup                       matlab.ui.container.TabGroup
        IndividualResultsTab           matlab.ui.container.Tab
        AllResults12Tab                matlab.ui.container.Tab
        UITable_5                      matlab.ui.control.Table
        AlgorithmComplexityLabel_2     matlab.ui.control.Label
        UITable_6                      matlab.ui.control.Table
        SuccessRatePerformanceLabel_2  matlab.ui.control.Label
        AllResults22Tab                matlab.ui.container.Tab
        PrecisionLabel_2               matlab.ui.control.Label
        UITable_7                      matlab.ui.control.Table
        ResidualerrorLabel             matlab.ui.control.Label
        UITable_8                      matlab.ui.control.Table
    end

    
    properties (Access = public)
        sav10d;
        sav30d;
        tab4;
        tab3;
        tab2;
        tab1;
    end
    
    
    methods (Access = public)
        
        function plotFunction(app,optNum,probNum)
            
            %Dimension-related declarations
            dimensions = [10, 30];
            %Runs for both dimensions
            allRuns = {app.sav10d, app.sav30d};
            
            % Used in Y axis normalization
            minY = Inf;
            maxY = -Inf;
            
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
                semilogy(axesSel,t, max(errors),'LineWidth',2);
                grid(axesSel,"on")
                hold(axesSel,"on")
                semilogy(axesSel,t, min(errors),'LineWidth',2);
                grid(axesSel,"on")
                set(findobj(axesSel,'type','axes'),'FontWeight','Bold');
                xlabel(axesSel,'Evaluations','fontweight','bold');
                ylabel(axesSel,'Residual Error','fontweight','bold');
                legend(axesSel,{'Worst' ,'Best'});
                title(axesSel,sprintf('%d Dimensions', dimensions(i0)));
                
                % Normalization of Y Axis - Saving min and max values
                YLimits=get(axesSel,'Ylim');
                if min(YLimits) < minY
                    minY=min(YLimits);
                end
                if max(YLimits) > maxY;
                    maxY=max(YLimits);
                end
                
            end
            
            % Normalize Y axis
            set(app.UIAxes,'Ylim',[minY maxY])
            set(app.UIAxes_2,'Ylim',[minY maxY])
        end
        
        function [optNum,probNum] = initDropDownSelection(app)
            % Selected dropdown option
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
        end
    end
    
    
    methods (Access = private)
        
        function showTableResultsError(app,optNum,probNum)
            %Dimension-related declarations
            dimensions = [10, 30];
            
            %Runs for both dimensions
            allRuns = {app.sav10d, app.sav30d};
            
            %% Dimensions loop
            for i = 1:numel(dimensions)
                
                %Dimension runs
                runs = allRuns{i};
                
                
                %Create a table to display the information
                tab = table();
                
                samples = runs(optNum, probNum, end).samples;
                %                 maxFES = runs(optNum, probNum, end).maxFES;
                
                %Residual errors
                errors = zeros(size(runs, 3), samples);
                
                %Final errors for each run
                finalValues = zeros(1, size(runs, 3));
                %% Run loop
                for m = 1:size(runs, 3)
                    run = runs(optNum, probNum, m);
                    errors(m, :) = [run.solutions.y] - run.globalMin;
                    
                    %If the error is lower than epsillon, consider as zero
                    finalValues(m) = errors(m, end);
                    finalValues(finalValues < run.epsillon) = 0;
                    %Insert values into the table
                    tab(i,:) = { min(finalValues),...
                        mean(finalValues),...
                        max(finalValues),...
                        std(finalValues) };
                end
            end
            %Specify column and row names and display table
            tab.Properties.VariableNames = {'Best','Mean','Worst','StandardDeviation'};
            tab.Properties.RowNames = {'10 D','30 D'};
            % Selected dropdown option
            selOpt = app.OptimizationselectionDropDown.Value;
            selProblem = app.ProblemselectionDropDown.Value;
            fprintf('Residual Error - %s \n',...
                selProblem);
            disp(tab);
            
            app.UITable.Data = tab;
            app.UITable.RowName = tab.Properties.RowNames;
        end
        
        function showTableResultsPrecision(app,optNum,probNum)
            %Dimension-related declarations
            dimensions = [10, 30];
            
            %Runs for both dimensions
            allRuns = {app.sav10d, app.sav30d};
            
            % Selected dropdown option
            selOpt = app.OptimizationselectionDropDown.Value;
            selProblem = app.ProblemselectionDropDown.Value;            
            
            %Create a table to display the information
            tab = table();           
            
            %Pre-allocate cells
            tab(numel(dimensions), :) = { '' };
            
            %% Dimensions loop
            for i = 1:numel(dimensions)               
                %Dimension runs
                runs = allRuns{i};
                
                %Total evaluations for each run
                evaluations = [runs(optNum, probNum, :).evaluations];
                
                %Insert values into the table
                tab(i,:) = { sprintf('%.2f +- %.2f', mean(evaluations),...
                    std(evaluations)) };
                
            end
            
            %Specify column and row names and display table
            tab.Properties.VariableNames = {'Mean_StdDeviation'};
            tab.Properties.RowNames = {'10 D', '30 D'};
            fprintf('Precision - %s\n', selProblem);
            disp(tab);
            app.UITable_2.Data = tab;
            app.UITable_2.RowName = tab.Properties.RowNames;
        end
        
        function showTableResultsPerformance(app,optNum,probNum)
            %Dimension-related declarations
            dimensions = [10, 30];
            
            %Runs for both dimensions
            allRuns = {app.sav10d, app.sav30d};
            
            %Create a table to display the information
            tab = table();
           
            %% Dimensions loop
            for i = 1:numel(dimensions)
                
                %Dimension runs
                runs = allRuns{i};

                %Totals
                successfulTests = 0;
                successfulEvaluations = 0;
                
                %% Run loop
                for m = 1:size(runs, 3)
                    run = runs(optNum, probNum, m);
                    
                    %Verify if run was successful and increment variables
                    if run.solutions(end).y - run.globalMin < run.epsillon
                        successfulTests = successfulTests + 1;
                        successfulEvaluations = successfulEvaluations + run.evaluations;
                    end
                end
                
                %Calculate success rate and performance
                successRate = successfulTests / size(runs, 3);
                performance = successfulEvaluations / successfulTests / successRate;
                
                %Validate unsuccessful runs
                if ~isfinite(performance)
                    performance = 0;
                end
                
                %Insert values into the table
                tab(i, :) = { successRate, performance };
            end

            %Specify column and row names and display table
            tab.Properties.VariableNames = {'SuccessRate', 'Performance'};
            tab.Properties.RowNames = {'10 D','30 D'};
            % Selected dropdown option
            selProblem = app.ProblemselectionDropDown.Value;
            fprintf('Success Rate and Performance - %s\n',...
                selProblem);
            disp(tab);
            
            app.UITable_3.Data = tab;
            app.UITable_3.RowName = tab.Properties.RowNames;
        end
        
        function showTableResultsComplexity(app,optNum,probNum)

            tab = app.tab4;
            selOpt = app.OptimizationselectionDropDown.Value;
            tabIndex = find(strcmp(selOpt,tab{:,3}));
            tab = tab(tabIndex,:);
            %% Show results
%             tab.Properties.VariableNames = { 'T0', 'Dimensions', 'Method', 'T1',...
%                 'T2', 'Complexity' };
            disp(tab);
            
            app.UITable_4.Data = tab;
            app.UITable_4.RowName = tab.Properties.RowNames;
            
        end
        
        function showAllResults(app)
            % Show all results of Algorithm Complexity
            tab = app.tab4;
            app.UITable_5.Data = tab;
            app.UITable_5.RowName = tab.Properties.RowNames;
            
            tab = app.tab3;
            app.UITable_6.Data = tab;
            app.UITable_6.ColumnName = tab.Properties.VariableNames;
            
            tab = app.tab2;
            app.UITable_7.Data = tab;
            app.UITable_7.ColumnName = tab.Properties.VariableNames;
            
            tab = app.tab1;
            app.UITable_8.Data = tab;
            app.UITable_8.ColumnName = tab.Properties.VariableNames;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %             exerc1Function(app)
            LoadResults                       
            app.sav10d = sav10d;
            app.sav30d = sav30d;
            app.tab4 = tab4;
            app.tab3 = tab3; 
            app.tab2 = tab2;
            app.tab1 = tab1;

            
            [optNum,probNum] = initDropDownSelection(app);
            plotFunction(app,optNum,probNum)
            showTableResultsError(app,optNum,probNum)
            showTableResultsPrecision(app,optNum,probNum)
            showTableResultsPerformance(app,optNum,probNum)
            showTableResultsComplexity(app,optNum,probNum)
            
            showAllResults(app)
            
        end

        % Callback function: OptimizationselectionDropDown, 
        % ProblemselectionDropDown, RefreshButton
        function OptimizationselectionDropDownValueChanged(app, event)
            [optNum,probNum] = initDropDownSelection(app);
            plotFunction(app,optNum,probNum)
            showTableResultsError(app,optNum,probNum)
            showTableResultsPrecision(app,optNum,probNum)
            showTableResultsPerformance(app,optNum,probNum)
            showTableResultsComplexity(app,optNum,probNum)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1400 940];
            app.UIFigure.Name = 'UI Figure';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1400 940];

            % Create IndividualResultsTab
            app.IndividualResultsTab = uitab(app.TabGroup);
            app.IndividualResultsTab.Title = 'Individual Results';

            % Create UIAxes
            app.UIAxes = uiaxes(app.IndividualResultsTab);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Position = [138 329 530 472];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.IndividualResultsTab);
            title(app.UIAxes_2, 'Title')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            app.UIAxes_2.FontSize = 14;
            app.UIAxes_2.Position = [695 329 530 472];

            % Create UITable
            app.UITable = uitable(app.IndividualResultsTab);
            app.UITable.ColumnName = {'Best'; 'Mean'; 'Worst'; 'StdDeviation'};
            app.UITable.RowName = {''};
            app.UITable.ColumnSortable = [true true true true];
            app.UITable.FontSize = 14;
            app.UITable.Position = [180 202 478 80];

            % Create ResidualErrorLabel
            app.ResidualErrorLabel = uilabel(app.IndividualResultsTab);
            app.ResidualErrorLabel.HorizontalAlignment = 'center';
            app.ResidualErrorLabel.FontSize = 14;
            app.ResidualErrorLabel.FontWeight = 'bold';
            app.ResidualErrorLabel.Position = [334 281 170 32];
            app.ResidualErrorLabel.Text = 'Residual Error';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.IndividualResultsTab, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @OptimizationselectionDropDownValueChanged, true);
            app.RefreshButton.FontSize = 14;
            app.RefreshButton.Position = [822 842 122 47];
            app.RefreshButton.Text = 'Refresh';

            % Create UITable_2
            app.UITable_2 = uitable(app.IndividualResultsTab);
            app.UITable_2.ColumnName = {'Mean_StdDeviation'};
            app.UITable_2.RowName = {''};
            app.UITable_2.ColumnSortable = true;
            app.UITable_2.FontSize = 14;
            app.UITable_2.Position = [735 202 231 80];

            % Create PrecisionLabel
            app.PrecisionLabel = uilabel(app.IndividualResultsTab);
            app.PrecisionLabel.HorizontalAlignment = 'center';
            app.PrecisionLabel.FontSize = 14;
            app.PrecisionLabel.FontWeight = 'bold';
            app.PrecisionLabel.Position = [766 285 170 32];
            app.PrecisionLabel.Text = 'Precision';

            % Create UITable_3
            app.UITable_3 = uitable(app.IndividualResultsTab);
            app.UITable_3.ColumnName = {'SuccessRate'; 'Performance'};
            app.UITable_3.RowName = {''};
            app.UITable_3.ColumnSortable = [true true];
            app.UITable_3.FontSize = 14;
            app.UITable_3.Position = [994 202 231 80];

            % Create SuccessRatePerformanceLabel
            app.SuccessRatePerformanceLabel = uilabel(app.IndividualResultsTab);
            app.SuccessRatePerformanceLabel.HorizontalAlignment = 'center';
            app.SuccessRatePerformanceLabel.FontSize = 14;
            app.SuccessRatePerformanceLabel.FontWeight = 'bold';
            app.SuccessRatePerformanceLabel.Position = [1010 285 201 32];
            app.SuccessRatePerformanceLabel.Text = 'Success Rate & Performance';

            % Create UITable_4
            app.UITable_4 = uitable(app.IndividualResultsTab);
            app.UITable_4.ColumnName = {'T0'; 'Dimensions'; 'Method'; 'T1'; 'T2'; 'Complexity'};
            app.UITable_4.RowName = {''};
            app.UITable_4.ColumnSortable = [true true true true true true];
            app.UITable_4.FontSize = 14;
            app.UITable_4.Position = [180 52 1035 80];

            % Create AlgorithmComplexityLabel
            app.AlgorithmComplexityLabel = uilabel(app.IndividualResultsTab);
            app.AlgorithmComplexityLabel.HorizontalAlignment = 'center';
            app.AlgorithmComplexityLabel.FontSize = 14;
            app.AlgorithmComplexityLabel.FontWeight = 'bold';
            app.AlgorithmComplexityLabel.Position = [597 131 201 32];
            app.AlgorithmComplexityLabel.Text = 'Algorithm Complexity';

            % Create OptimizationselectionDropDownLabel
            app.OptimizationselectionDropDownLabel = uilabel(app.IndividualResultsTab);
            app.OptimizationselectionDropDownLabel.HorizontalAlignment = 'right';
            app.OptimizationselectionDropDownLabel.FontSize = 14;
            app.OptimizationselectionDropDownLabel.Position = [391 867 142 22];
            app.OptimizationselectionDropDownLabel.Text = 'Optimization selection';

            % Create OptimizationselectionDropDown
            app.OptimizationselectionDropDown = uidropdown(app.IndividualResultsTab);
            app.OptimizationselectionDropDown.Items = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering', 'Multidirectional Search', 'Pattern Search'};
            app.OptimizationselectionDropDown.ValueChangedFcn = createCallbackFcn(app, @OptimizationselectionDropDownValueChanged, true);
            app.OptimizationselectionDropDown.FontSize = 14;
            app.OptimizationselectionDropDown.Position = [548 867 219 22];
            app.OptimizationselectionDropDown.Value = 'Nelder-Mead';

            % Create ProblemselectionDropDownLabel
            app.ProblemselectionDropDownLabel = uilabel(app.IndividualResultsTab);
            app.ProblemselectionDropDownLabel.HorizontalAlignment = 'right';
            app.ProblemselectionDropDownLabel.FontSize = 14;
            app.ProblemselectionDropDownLabel.Position = [416 821 117 22];
            app.ProblemselectionDropDownLabel.Text = 'Problem selection';

            % Create ProblemselectionDropDown
            app.ProblemselectionDropDown = uidropdown(app.IndividualResultsTab);
            app.ProblemselectionDropDown.Items = {'Sphere Function', 'Rotated High Conditioned Elliptic Function', 'Rotated Bent Cigar Function', 'Rotated Discus Function', 'Different Powers Function'};
            app.ProblemselectionDropDown.ValueChangedFcn = createCallbackFcn(app, @OptimizationselectionDropDownValueChanged, true);
            app.ProblemselectionDropDown.FontSize = 14;
            app.ProblemselectionDropDown.Position = [548 821 219 22];
            app.ProblemselectionDropDown.Value = 'Sphere Function';

            % Create AllResults12Tab
            app.AllResults12Tab = uitab(app.TabGroup);
            app.AllResults12Tab.Title = 'All Results 1/2';

            % Create UITable_5
            app.UITable_5 = uitable(app.AllResults12Tab);
            app.UITable_5.ColumnName = {'T0'; 'Dimensions'; 'Method'; 'T1'; 'T2'; 'Complexity'};
            app.UITable_5.RowName = {''};
            app.UITable_5.ColumnSortable = [true true true true true true];
            app.UITable_5.FontSize = 14;
            app.UITable_5.Position = [177 38 1035 276];

            % Create AlgorithmComplexityLabel_2
            app.AlgorithmComplexityLabel_2 = uilabel(app.AllResults12Tab);
            app.AlgorithmComplexityLabel_2.HorizontalAlignment = 'center';
            app.AlgorithmComplexityLabel_2.FontSize = 14;
            app.AlgorithmComplexityLabel_2.FontWeight = 'bold';
            app.AlgorithmComplexityLabel_2.Position = [594 313 201 32];
            app.AlgorithmComplexityLabel_2.Text = 'Algorithm Complexity';

            % Create SuccessRatePerformanceLabel_2
            app.SuccessRatePerformanceLabel_2 = uilabel(app.AllResults12Tab);
            app.SuccessRatePerformanceLabel_2.HorizontalAlignment = 'center';
            app.SuccessRatePerformanceLabel_2.FontSize = 14;
            app.SuccessRatePerformanceLabel_2.FontWeight = 'bold';
            app.SuccessRatePerformanceLabel_2.Position = [594 850 201 32];
            app.SuccessRatePerformanceLabel_2.Text = 'Success Rate & Performance';

            % Create UITable_6
            app.UITable_6 = uitable(app.AllResults12Tab);
            app.UITable_6.ColumnName = {'Function problem'; 'Optimization'; 'SuccessRate10D'; 'Performance10D'; 'SuccessRate30D'; 'Performance30D'};
            app.UITable_6.RowName = {''};
            app.UITable_6.ColumnSortable = true;
            app.UITable_6.FontSize = 14;
            app.UITable_6.Position = [177 375 1035 475];

            % Create AllResults22Tab
            app.AllResults22Tab = uitab(app.TabGroup);
            app.AllResults22Tab.Title = 'All Results 2/2';

            % Create PrecisionLabel_2
            app.PrecisionLabel_2 = uilabel(app.AllResults22Tab);
            app.PrecisionLabel_2.HorizontalAlignment = 'center';
            app.PrecisionLabel_2.FontSize = 14;
            app.PrecisionLabel_2.FontWeight = 'bold';
            app.PrecisionLabel_2.Position = [597 421 201 32];
            app.PrecisionLabel_2.Text = 'Precision';

            % Create UITable_7
            app.UITable_7 = uitable(app.AllResults22Tab);
            app.UITable_7.ColumnName = {'Function problem'; 'Optimization'; 'Mean_StdDeviation_10D'; 'Mean_StdDeviation_30D'};
            app.UITable_7.RowName = {''};
            app.UITable_7.ColumnSortable = true;
            app.UITable_7.FontSize = 14;
            app.UITable_7.Position = [180 30 1035 388];

            % Create ResidualerrorLabel
            app.ResidualerrorLabel = uilabel(app.AllResults22Tab);
            app.ResidualerrorLabel.HorizontalAlignment = 'center';
            app.ResidualerrorLabel.FontSize = 14;
            app.ResidualerrorLabel.FontWeight = 'bold';
            app.ResidualerrorLabel.Position = [596 871 201 32];
            app.ResidualerrorLabel.Text = 'Residual error';

            % Create UITable_8
            app.UITable_8 = uitable(app.AllResults22Tab);
            app.UITable_8.ColumnName = {'Function problem'; 'Optimization'; 'Best10D'; 'Mean10D'; 'Worst10D'; 'StandardDeviation10D'; 'Best30D'; 'Mean30D'; 'Worst30D'; 'StandardDeviation30D'};
            app.UITable_8.RowName = {''};
            app.UITable_8.ColumnSortable = true;
            app.UITable_8.FontSize = 14;
            app.UITable_8.Position = [36 480 1324 388];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = showResults_exported

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