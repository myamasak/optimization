%% General initialization
%Load generated results
LoadResults;

%Dimension-related declarations
dimensions = [10, 30];

%Algorithm-related declarations
algorithmNames = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering',...
    'Multidirectional Search', 'Pattern Search'};

%Function-related declarations
functionNames = {'Sphere Function',...
    'Rotated High Conditioned Elliptic Function',...
    'Rotated Bent Cigar Function',...
    'Rotated Discus Function',...
    'Different Powers Function'};

%Runs for both dimensions
allRuns = { sav10d, sav30d };

%% Algorithm loop
for j = 1:numel(algorithmNames)

    %Create a table to display the information
    tab = table();

    %% Function loop
    for k = 1:numel(functionNames)

        %Pre-allocate cells
        tab(k, :) = { '', '' };
        
        %% Dimensions loop
        for i = 1:numel(dimensions)
            
            %Dimension runs
            runs = allRuns{i};
            
            %Total evaluations for each run
            evaluations = [runs(j, k, :).evaluations];
            
            %Insert values into the table
            tab(k, i) = { sprintf('%.2f +- %.2f', mean(evaluations),...
                std(evaluations)) };
        
        end
    end

    %Specify column and row names and display table
    tab.Properties.VariableNames = { 'Dimensions_10', 'Dimensions_30' };
    tab = mergevars(tab, [1, 2], 'NewVariableName',...
        'Evaluations_Mean_StdDeviation', 'MergeAsTable', true);
    tab.Properties.RowNames = { 'F1', 'F2', 'F3', 'F4', 'F5' };
    fprintf('Precision - %s\n', algorithmNames{j});
    disp(tab);
end