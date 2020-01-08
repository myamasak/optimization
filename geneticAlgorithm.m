function result = geneticAlgorithm(objFnc, numVars, lowerLimits, upperLimits, options)
%GENETICALGORITHM Genetic Algorithm
%
%Input values:
% objFnc             - The objective's function handle
% numVars            - Number of variables of the problem
% lowerLimits        - The variables' lower bound
% upperLimits        - The variables' upper bound
% options            - Optimization options, as described below:
%   maxFES           - Maximum number of objective function evaluations
%   samples          - Number of points that should be sampled
%   globalMin        - The global mimimum of the objective function
%   epsillon         - The function tolerance for termination (y - y*) < e
%   pauseIfNeeded    - Pause the algorithm to compensate for early
%                      termination
%
%Output values:
% result         - The optimization results, as described below:
%   evaluations  - Final number of function evaluations
%   solutions    - Solutions at the specified sample points:
%     x          - The input values
%     y          - The output value
%   globalMin    - The global mimimum of the objective function
%   epsillon     - The function tolerance for termination (y - y*) < e
%   maxFES       - Maximum number of objective function evaluations
%   samples      - Number of points that should be sampled

    %% Algorithm initialization
    %Constants
    maxFES = options.maxFES;
    evalSamplePoints = linspace(0, 1, options.samples) * maxFES;
    globalMin = options.globalMin;
    epsillon = options.epsillon;
    
    %Result initialization
    result.evaluations = 0;
    result.solutions = [];
    result.globalMin = globalMin;
    result.epsillon = epsillon;
    result.maxFES = maxFES;
    result.samples = options.samples;
    
    %Output function for the ga (Genetic Algorithm)
    %Samples evaluations and stops the algorithm if the stopping criterion
    %has been met
    function [state, options, changed] = outputFunction(options, state, ~)
        changed = false;
        
        [~, i] = min(state.Score);
        solution.x = state.Population(i, :);
        solution.y = state.Score(i);
        
        if solution.y - globalMin < epsillon
            state.StopFlag = 'y - y* < epsillon';
            return;
        end
        
        if ~isempty(evalSamplePoints) && evalSamplePoints(1) < result.evaluations
            result.solutions = [result.solutions solution];
            evalSamplePoints(1) = [];
        end
    end

    %Artificial objective function to validate variable constraints and
    %evaluation number limit
    function y = constraintEvaluationValidator(x)
        %If there are no evaluations left, return Infinity
        if result.evaluations >= maxFES
            y = Inf;
            return;
        end
        
        %Increment evaluation number
        result.evaluations = result.evaluations + 1;
        
        %If the variables are outside their limits, return Infinity
        if any(x < lowerLimits) || any(x > upperLimits)
            y = Inf;
            return;
        end
        
        %Evaluate the function
        y = objFnc(x);
    end

    %The modified objective function
    subObjFnc = @constraintEvaluationValidator;
    
    %Starting point
    startingPoint.x = (upperLimits - lowerLimits) .* rand(1, numVars) + lowerLimits;
    startingPoint.y = subObjFnc(startingPoint.x);
    
    %Should the initial evaluation be sampled?
    if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
        result.solutions = [result.solutions startingPoint];
        evalSamplePoints(1) = [];
    end

    %ga options
    subOptions = optimoptions(@ga);
    subOptions.ConstraintTolerance = 0;
    subOptions.Display = 'off';
    subOptions.FitnessLimit = globalMin;
    subOptions.FunctionTolerance = 0;
    subOptions.MaxGenerations = floor(maxFES / (numVars * 10));
    subOptions.MaxStallGenerations = Inf;
    subOptions.OutputFcn = @outputFunction;
    subOptions.PopulationSize = numVars * 10;
    
    %% Sub-algorithm (ga) execution
    start = tic;
    [bestX, bestY] = ga(subObjFnc, numVars, [], [], [], [], lowerLimits, upperLimits, [], [], subOptions);
    timeElapsed = toc(start);
    solution.x = bestX;
    solution.y = bestY;

    %If by any means, the algorithm exists before reaching the stopping
    %criterion (Eg.: x and y tolerance have been reached), set the total
    %number of evaluations to maxFES to indicate that the algorithm did not
    %converge
    if bestY - globalMin >= epsillon
        %Pause for the appropriate amout of time to simulate the remaining
        %evaluations, and maintain a consistent time complexity
        if options.pauseIfNeeded
            timePerEvaluation =  timeElapsed / result.evaluations;
            pause((maxFES - result.evaluations) * timePerEvaluation);
        end
        
        result.evaluations = maxFES;
    end
    
    %Fill the remaining sample points with the final solution
    missing = options.samples - numel(result.solutions);
    result.solutions = cat(2, result.solutions, repmat(solution, 1, missing));
end