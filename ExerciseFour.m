%% Initial declarations

%Table for the final results
tab = table();

%% Calculation of T0

%Start of t0's timer
startT0 = tic;

x = 0.55;
for j = 1:1000000
    x = x + x;
    x = x / 2;
    x = x * x;
    x = sqrt(x);
    x = log(x);
    x = exp(x);
    x = x / (x + 2);
end

%End of t0's timer, store the result
t0 = toc(startT0);

%% Calculation of T1s and T2s

%Constant declarations
dimensions = [10, 30];

% algorithms = {@nelderMead, @hookeJeeves, @implicitFiltering,...
%         @multidirectionalSearch, @patternSearch, @geneticAlgorithm};
algorithms = {@nelderMead, @hookeJeeves, @implicitFiltering,...
        @multidirectionalSearch, @patternSearch};
% algorithmNames = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering',...
%     'Multidirectional Search', 'Pattern Search', 'Genetic Algorithm'};
algorithmNames = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering',...
    'Multidirectional Search', 'Pattern Search'};

runs = 5;

for i = 1:numel(dimensions)
    
    %% Calculation of T1
    
    %Zero vector for function evaluation
    x = zeros(1, dimensions(i));
    
    %Start of t1's timer
    startT1 = tic;
    
    for j = 1:200000
        y = cec13_func(x', 5);
    end
    
    %End of t1's timer, store the result
    t1 = toc(startT1);
    
    %% Calculation of T2
    objFnc = @(x) cec13_func(x', 5);
    numVars = dimensions(i);
    lowerLimits = -100 * ones(1, numVars);
    upperLimits =  100 * ones(1, numVars);

    options.maxFES = 200000;
    options.samples = 0;
    options.globalMin = -1000;
    options.epsillon = 0;
    options.pauseIfNeeded = true; %Compensate for early termination

    %Algorithm loop
    for j = 1:numel(algorithms)

        algorithm = algorithms{j};
        t2 = zeros(1, runs);
        
        fprintf('Running Method %s with %d dimensions %d times... ',...
            algorithmNames{j}, dimensions(i), runs);
        
        %Run loop
        for k = 1:runs
            
            %Start of t2's timer
            startT2 = tic;
            
            [~] = algorithm(objFnc, numVars, lowerLimits, upperLimits, options);
            
            %End of t2's timer, store the result
            t2(k) = toc(startT2);
        end
        fprintf('Done!\n');
        
        meanT2 = mean(t2);
        complexity = (meanT2 - t1) / t0;
        
        row = (i - 1) * numel(algorithms) + j;
        tab(row, :) = { t0, dimensions(i), algorithmNames{j}, t1,...
            meanT2, complexity };
    end
end

tab.Properties.VariableNames = { 'T0', 'Dimensions', 'Method', 'T1',...
    'T2', 'Complexity' };
disp(tab);