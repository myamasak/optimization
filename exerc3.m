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
            
            %Totals
            successfulTests = 0;
            successfulEvaluations = 0;
            
            %% Run loop
            for m = 1:size(runs, 3)
                run = runs(j, k, m);
                
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
            tab(k, :) = { successRate, performance };
        end
        
%         %Specify column and row names and display table
        tab.Properties.VariableNames = { 'SuccessRate', 'Performance' };
        tab.Properties.RowNames = { 'F1', 'F2', 'F3', 'F4', 'F5' };
        fprintf('Success Rate and Performance - %s - %d Dimensions\n',...
            algorithmNames{j}, dimensions(i));
        disp(tab);
          

              
%          tabFinal = [tabFinal tab];
    end
end
% tabFinalConv = array2table(tabFinal);
% tabFinalConv.Properties.VariableNames = { 'SuccessRate', 'Performance' };
% tabFinalConv.Properties.RowNames = { 'F1', 'F2', 'F3', 'F4', 'F5' };
% tabFinalConv = mergevars(tabFinalConv, {'tabFinal1','tabFinal2'}, 'NewVariableName', 'NelderMead', 'MergeAsTable', false);
% tabFinalConv = mergevars(tabFinalConv, {'tabFinal3','tabFinal4'}, 'NewVariableName', 'EllipticFunction', 'MergeAsTable', false);
% disp(tabFinalConv);