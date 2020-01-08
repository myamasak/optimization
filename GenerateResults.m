%% General initialization
%Dimension-related declarations
dimensions = [10, 30];

%Algorithm-related declarations
algorithmNames = {'Nelder-Mead', 'Hooke-Jeeves', 'Implicit Filtering',...
    'Multidirectional Search', 'Pattern Search', 'Genetic Algorithm'};
algorithms = {@nelderMead, @hookeJeeves, @implicitFiltering,...
    @multidirectionalSearch, @patternSearch, @geneticAlgorithm};

%Function-related declarations
functionNames = {'Sphere Function',...
    'Rotated High Conditioned Elliptic Function',...
    'Rotated Bent Cigar Function',...
    'Rotated Discus Function',...
    'Different Powers Function'};
functions = [1, 2, 3, 4, 5];
globalMins = [-1400, -1300, -1200, -1100, -1000];

%Runs-related declarations
runsPerAlgorithm = 51;

%Result structure
result.evaluations = 0;
result.solutions = [];
result.globalMin = 0;
result.epsillon = 0;
result.maxFES = 0;
result.samples = 0;

%Optimization results
runs = repmat(result, numel(dimensions), numel(algorithms),...
    numel(functions), runsPerAlgorithm);

%% Dimension loop
for i = 1:numel(dimensions)
    
    %General initialization
    numVars = dimensions(i); %Dimension of the problem
    lowerLimits = -100 * ones(1, numVars); %Lower bounds
    upperLimits =  100 * ones(1, numVars); %Upper bounds
    
    %General optimization options
    options.maxFES = 10000 * numVars; %Function evaluations
    options.samples = 100; %Number of samples
    options.epsillon = 1e-8; %Residual error epsillon
    options.pauseIfNeeded = false; %Do not pause, just run
    
    %% Algorithm loop
    for j = 1:numel(algorithms)
        
        %Algorithm to be run
        algorithm = algorithms{j};
        
        %% Function loop
        for k = 1:numel(functions)
            
            %Objective function
            objFnc = @(x) cec13_func(x', functions(k));
            
            %Problem specific options
            options.globalMin = globalMins(k); %Global minimum
            
            %% Runs loop
            for m = 1:runsPerAlgorithm
                %Run the algorithm and alert when it's done
                fprintf('%d Dimens�es, M�todo %s, %s, Rodada #%d... ',...
                    numVars, algorithmNames{j}, functionNames{k}, m);
                runs(i, j, k, m) = algorithm(objFnc, numVars,...
                    lowerLimits, upperLimits, options);
                fprintf('OK!\n');
            end
        end
    end
end

%% Results saving
%Save the 10-D optimization results
runs10D = permute(runs(1,:,:,:), [2 3 4 1]);
save('Runs10D.mat', 'runs10D');

%Save the 30-D optimization results
runs30D = permute(runs(2,:,:,:), [2 3 4 1]);
save('Runs30D.mat', 'runs30D');