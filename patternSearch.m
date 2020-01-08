function result = patternSearch(objFnc, numVars, lowerLimits, upperLimits, options)
%PATTERNSEARCH Constrained Pattern Search algorithm
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
    
    %Output function for the patternsearch (Patter Search) function
    %Updates function evaluations, samples values and stops the algorithm
    %if the stopping criterion has been met
    function [stop, options, changed] = outputFunction(bestInfo, options, ~)
        changed = false;
        result.evaluations = bestInfo.funccount;
        
        if bestInfo.fval - globalMin < epsillon
            stop = true;
            return;
        end
        
        if ~isempty(evalSamplePoints) && evalSamplePoints(1) < result.evaluations
            solution.x = bestInfo.x;
            solution.y = bestInfo.fval;
            result.solutions = [result.solutions solution];
            evalSamplePoints(1) = [];
        end
        
        stop = false;
    end
    
    %Starting point
    startingPoint.x = (upperLimits - lowerLimits) .* rand(1, numVars) + lowerLimits;
    startingPoint.y = objFnc(startingPoint.x);
    
    %Should the initial evaluation be sampled?
    if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
        result.solutions = [result.solutions startingPoint];
        evalSamplePoints(1) = [];
    end

    %patternsearch options
    subOptions = optimoptions(@patternsearch);
    subOptions.ConstraintTolerance = 0;
    subOptions.Display = 'off';
    subOptions.FunctionTolerance = 0;
    subOptions.MaxFunctionEvaluations = maxFES;
    subOptions.MaxIterations = Inf;
    subOptions.MeshTolerance = 0;
    subOptions.StepTolerance = 0;
    subOptions.OutputFcn = @outputFunction;
    
    %% Sub-algorithm (patternsearch) execution
    start = tic;
    [bestX, bestY] = patternsearch(objFnc, startingPoint.x, [], [], [], [], lowerLimits, upperLimits, [], subOptions);
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