function result = implicitFiltering(objFnc, numVars, lowerLimits, upperLimits, options)
%NEWIMPLICITFILTERING Constrained Implicit Filtering algorithm
%
%Input values:
% subObjFnc             - The objective's function handle
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
        
        %If the variables are outside their limits, return Infinity
        if any(x < lowerLimits) || any(x > upperLimits)
            y = Inf;
            return;
        end
        
        %Increment evaluation number
        result.evaluations = result.evaluations + 1;

        %Evaluate the function
        y = objFnc(x);
    end

    %The modified objective function
    subObjFnc = @constraintEvaluationValidator;

    %Base solution generation
    bestPoint.x = (upperLimits - lowerLimits) .* rand(1, numVars) + lowerLimits;
    bestPoint.y = subObjFnc(bestPoint.x);
    
    %Should the initial evaluation be sampled?
    if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
        result.solutions = [result.solutions bestPoint];
        evalSamplePoints(1) = [];
    end
    
    %Algorithm parameters
    maxLineSearchIters = 52; %Calculated from -log2(eps)
    alpha = 1e-4; %Suggested value
    beta = 0.6; %Suggested value
    
    %Initial gradient scale
    scale = 1;
    
    %% Main loop
    while result.evaluations < maxFES
        outOfEvaluations = false;
        
        %% Difference gradient calculation
        while true
            %Verify if we can evaluate the function any further
            if result.evaluations >= maxFES
                outOfEvaluations = true;
                break;
            end
            
            %Calculates the centered simplex difference gradient
            [gradient, success] = simplexGradient(subObjFnc, bestPoint, scale);
            
            %If it's not successful, reduce the scale and try again
            if success
                break;
            else
                scale = scale / 2;
            end
            
            %Reset the scale when it reaches zero
            if scale == 0
                scale = 1;
            end
        end
        
        %Out of evaluations. Exit the main loop
        if outOfEvaluations
            break;
        end
        
        %Save the starting point for reference
        currentPoint = bestPoint;
        
        %% Projected gradient descent algorithm
        for m = 0:maxLineSearchIters
            %Lambda, decreases exponentially
            lambda = beta^m;
            
            %Calculate and "project" the new point
            testPoint.x = gradientProjection(bestPoint.x - lambda * gradient, lowerLimits, upperLimits);
            testPoint.y = subObjFnc(testPoint.x);

            %Update the best point
            if currentPoint.y > testPoint.y
                currentPoint = testPoint;
            end
            
            %Should the current evaluation be sampled?
            if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
                result.solutions = [result.solutions currentPoint];
                evalSamplePoints(1) = [];
            end
            
            fOne = testPoint.y - bestPoint.y;
            fTwo = -alpha * lambda * norm(gradient, 2)^2;
            
            %Criterion of sufficient decrease, or if d is lower than eps
            if fOne < fTwo || lambda < eps
                break;
            end
        end
        
        %Update the best point
        bestPoint = currentPoint;
        
        %Is the residual error lower than the specified epsillon?
        if bestPoint.y - globalMin < epsillon
            break;
        end
    end
    
    %Fill the remaining sample points with the final solution
    missing = options.samples - numel(result.solutions);
    result.solutions = cat(2, result.solutions, repmat(bestPoint, 1, missing));
    
    %End of the algorithm
end

%"Gradient Projection" function
%Limits the input inbetween the given bounds
function projectedX = gradientProjection(x, lowerLimits, upperLimits)
    projectedX = min(max(x, lowerLimits), upperLimits);
end

%Centered Simplex Gradient algorithm
function [gradient, success] = simplexGradient(objFnc, point, scale)
    numVars = length(point.x);
    lowerCosts = zeros(1, numVars);
    upperCosts = zeros(1, numVars);
    diff = eye(numVars) .* scale;
    
    success = false;

    for i = 1:numVars
        lowerValue = point.x - diff(:,i)';
        lowerCost = objFnc(lowerValue);
 
        upperValue = point.x + diff(:,i)';
        upperCost = objFnc(upperValue);
        
        %If the upper point is outside the problem's bounds, reflect the
        %value of the lower point
        if ~isfinite(upperCost) && isfinite(lowerCost)
            upperCost = point.y + (point.y - lowerCost);
        end
        
        %If the lower point is outside the problem's bounds, reflect the
        %value of the upper point
        if ~isfinite(lowerCost) && isfinite(upperCost)
            lowerCost = point.y - (upperCost - point.y);
        end
        
        if point.y > lowerCost
            success = true;
        end
        
        if point.y > upperCost
            success = true;
        end
        
        upperCosts(i) = upperCost - point.y;
        lowerCosts(i) = point.y - lowerCost;
    end
    
    if success
        gradient = (0.5 * ((diff \ lowerCosts') + (diff \ upperCosts')))';
    else
        gradient = [];
    end
end