function result = hookeJeeves(objFnc, numVars, lowerLimits, upperLimits, options)
%HOOKEJEEVES Constrained Hooke-Jeeves algorithm
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

    %Base solution generation
    basePoint.x = (upperLimits - lowerLimits) .* rand(1, numVars) + lowerLimits;
    basePoint.y = subObjFnc(basePoint.x);
    
    %Should the initial evaluation be sampled?
    if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
        result.solutions = [result.solutions basePoint];
        evalSamplePoints(1) = [];
    end
    
    %Starting search range, follows a Base 10 Logaritmic AIMD (Addicitive
    %Increment, Multiplicative Decrement) rule
    searchRange = 1;
    
    %% Main loop
    while result.evaluations < maxFES
        %Stop flag
        stop = false;
        
        %Exploration around the base point
        [bestPoint, improvement] = explore(basePoint, basePoint, subObjFnc, searchRange);
        
        %Did it improve?
        while improvement
            %New search direction based on the best point
            direction = bestPoint.x - basePoint.x;
            basePoint = bestPoint;
            searchPoint.x = bestPoint.x + direction;
            searchPoint.y = subObjFnc(searchPoint.x);
            
            %Explore around the new search point
            [bestPoint, improvement] = explore(searchPoint, bestPoint, subObjFnc, searchRange);
            
            %Did it improve?
            if ~improvement
                %If not, search around the latest best point
                [bestPoint, improvement] = explore(bestPoint, bestPoint, subObjFnc, searchRange);
                basePoint = bestPoint;
            end
            
            %Is the residual error lower than the specified epsillon?
            if basePoint.y - globalMin < epsillon
                stop = true;
                break;
            end

            %Should the current evaluation be sampled?
            if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
                result.solutions = [result.solutions basePoint];
                evalSamplePoints(1) = [];
            end
        end
        
        if stop
            break;
        end
        
        searchRange = searchRange / 2;
    end
    
    %Fill the remaining sample points with the final solution
    missing = options.samples - numel(result.solutions);
    result.solutions = cat(2, result.solutions, repmat(basePoint, 1, missing));

    %End of the algorithm
end

%Hooke-Jeeves exploration function, uses an identity matrix for exploration
%directions
function [bestPoint, improvement] = explore(basePoint, bestPoint, objFnc, searchRange)
    
    %Initialization
    numVars = numel(basePoint.x);
    improvement = false;
    
    %Identity matrix direction
    V = eye(numVars);
    
    %Search for each axis
    for i = 1:numVars
        %Positive direction of the axis
        testPoint.x = basePoint.x + searchRange * V(i, :);
        testPoint.y = objFnc(testPoint.x);

        %If the tested point is worse than the base one, recalculate
        if basePoint.y < testPoint.y
            %Negative direction of the axis
            testPoint.x = basePoint.x - searchRange * V(i, :);
            testPoint.y = objFnc(testPoint.x);
        end

        %Is the point better than the base one?
        if testPoint.y < bestPoint.y
            bestPoint = testPoint;
            basePoint = bestPoint;
            improvement = true;
        end
    end
end
