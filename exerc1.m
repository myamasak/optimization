clc
clear all
close all

%% General initialization
%Load generated results
LoadResults;

%Dimension-related declarations
dimensions = [10, 30];
% dimensions = [5];


%Algorithm-related declarations
% algorithmNames = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering',...
%     'Multidirectional Search', 'Pattern Search', 'Genetic Algorithm'};
algorithmNames = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering',...
    'Multidirectional Search', 'Pattern Search'};
% algorithmNames = {'Nelder-Mead'};

%Function-related declarations
functionNames = {'Sphere Function',...
    'Rotated High Conditioned Elliptic Function',...
    'Rotated Bent Cigar Function',...
    'Rotated Discus Function',...
    'Different Powers Function'};

%Runs for both dimensions
allRuns = {sav10d, sav30d};
% allRuns = {sav10d};

%% Plot initialization
%Creates a plot for every algorithm-function pair
handles = {};
for i = 1:(numel(algorithmNames) * numel(functionNames))
    handles = cat(2, handles, figure());
    handles(i).Position = handles(i).Position + [0 0 300 0];
end

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
            errors = zeros(size(runs, 3), samples);
            
            %Final errors for each run
            finalValues = zeros(1, size(runs, 3));
            
            %% Run loop
            for m = 1:size(runs, 3)
                run = runs(j, k, m);
                errors(m, :) = [run.solutions.y] - run.globalMin;
                
                %If the error is lower than epsillon, consider as zero
                finalValues(m) = errors(m, end);
                finalValues(finalValues < run.epsillon) = 0;
            end
            
            %Select the correct plot
            handle = handles((j - 1) * numel(functionNames) + k);
            handle.Name = sprintf('%s - %s', algorithmNames{j}, functionNames{k});
            handle.NumberTitle = 'off';
            figure(handle);
            
            %Plot the worst and best curves
            t = linspace(0, 1, samples) * maxFES;
            subplot(1, 2, i);
            semilogy(t, max(errors),'LineWidth',2);            
            grid on;
            hold on;
            semilogy(t, min(errors),'LineWidth',2);
            set(findobj(gcf,'type','axes'),'FontWeight','Bold');
            
            
            grid on;
            xlabel('Evaluations','fontweight','bold');
            ylabel('Residual Error','fontweight','bold');
            legend({'Worst' ,'Best'});
            title(sprintf('%d Dimensions', dimensions(i)));
            
            set(gcf,'position',[680,490,860,460])
            
            %Insert values into the table
            tab(k, :) = { min(finalValues),...
                mean(finalValues),...
                max(finalValues),...
                std(finalValues) };
        end
        
        %Specify column and row names and display table
        tab.Properties.VariableNames = {'Best','Mean','Worst','StandardDeviation'};
        tab.Properties.RowNames = { 'F1', 'F2', 'F3', 'F4', 'F5' };
        fprintf('Residual Error - %s - %d Dimensions\n',...
            algorithmNames{j}, dimensions(i));
        disp(tab);
    end
end