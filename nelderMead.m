function result = nelderMead(objFnc, numVars, lowerLimits, upperLimits, options)
%NELDERMEAD Constrained Nelder-Mead algorithm
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
    
    %Output function for the fminsearch (Nelder-Mead) algorithm
    %Samples evaluations and stops the algorithm if the stopping criterion
    %has been met
    function stop = outputFunction(bestX, bestInfo, ~)
        %Is the residual error lower than the specified epsillon?
        if bestInfo.fval - globalMin < epsillon
            %Fill the remaining sample points with the final solution
            while ~isempty(evalSamplePoints)
                solution.x = bestX;
                solution.y = bestInfo.fval;
                result.solutions = [result.solutions solution];
                evalSamplePoints(1) = [];
            end
            %Stop the algorithm and return
            stop = true;
            return;
        end
        
        %Should the current evaluation be sampled?
        if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
            solution.x = bestX;
            solution.y = bestInfo.fval;
            result.solutions = [result.solutions solution];
            evalSamplePoints(1) = [];
        end
        
        %Continue running
        stop = false;
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

    %fminsearch options
    subOptions = optimset(@fminsearch);
    subOptions.Display = 'off';
    subOptions.MaxFunEvals = maxFES;
    subOptions.MaxIter = Inf;
    subOptions.TolFun = 0;
    subOptions.TolX = 0;
    subOptions.OutputFcn = @outputFunction;
    
    %% Sub-algorithm (fminsearch) execution
    start = tic;
    [bestX, bestY] = fminsearch(subObjFnc, startingPoint.x, subOptions);
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

