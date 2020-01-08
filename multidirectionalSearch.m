function result = multidirectionalSearch(objFnc, numVars, lowerLimits, upperLimits, options)
%MULTIDIRECTIONALSEARCH Constrained Multidirectional Search algorithm
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
    
    %Base point of the simplex
    solution.x = (upperLimits - lowerLimits) .* rand(1, numVars) + lowerLimits;
    solution.y = subObjFnc(solution.x);
    simplex = solution;
    
    %Should the initial evaluation be sampled?
    if ~isempty(evalSamplePoints) && evalSamplePoints(1) <= result.evaluations
        result.solutions = [result.solutions solution];
        evalSamplePoints(1) = [];
    end
    
    %General constants
    a = 0.05; %Initial simplex range
    uE = 2.0; %Expansion coefficient
    uC = 0.5; %Contraction coefficient
    
    %The other points
    for i = 2:numVars + 1
        solution.x = simplex(1).x;
        solution.x(i - 1) = solution.x(i - 1) * (1 + a);
        solution.y = subObjFnc(solution.x);
        
        simplex = cat(2, simplex, solution);
    end
    
    %Sort the simplex
    simplex = sortSimplex(simplex);
    
    %% Main loop
    while result.evaluations < maxFES
        %Reflection
        reflectedSimplex = simplex;
        reflectedBest = false;
        
        %Genete the reflected simplex from the base simplex
        for i = 2:numVars + 1
            reflectedSimplex(i).x = simplex(1).x - (simplex(i).x - simplex(1).x);
            reflectedSimplex(i).y = subObjFnc(reflectedSimplex(i).x);
            
            %Is the reflected point better than the best base point?
            if ~reflectedBest && simplex(1).y > reflectedSimplex(i).y
                reflectedBest = true;
            end
        end
        
        %Expansion occurs if the reflection is better, else Contraction
        %occurs
        if reflectedBest
            reflectedSimplex = sortSimplex(reflectedSimplex);
            expandedSimplex = simplex;
            expandedBest = false;
            
            %Genete the expanded points from the base simplex
            for i = 2:numVars + 1
                expandedSimplex(i).x = simplex(1).x - uE * (simplex(i).x - simplex(1).x);
                expandedSimplex(i).y = subObjFnc(expandedSimplex(i).x);
                
                %Is the expanded point better tha the best reflected point?
                if ~expandedBest && expandedSimplex(1).y > expandedSimplex(i).y
                    expandedBest = true;
                end
            end
            
            %Is the expanded simplex is better, use it, else, use the
            %reflected one
            if expandedBest
                %Sort the expanded simplex
                simplex = sortSimplex(expandedSimplex);
            else
                %No sort needed, was already performed previously
                simplex = reflectedSimplex;
            end
        else
            %Genetere the contracted simplex from the base simplex
            for i = 2:numVars + 1
                simplex(i).x = simplex(1).x + uC * (simplex(i).x - simplex(1).x);
                simplex(i).y = subObjFnc(simplex(i).x);
            end
            
            %Sort the contracted simplex
            simplex = sortSimplex(simplex);
        end
        
        %Is the residual error lower than the specified epsillon?
        if simplex(1).y - globalMin < epsillon
            %Fill the remained sample points with the final solution
            while ~isempty(evalSamplePoints)
                result.solutions = [result.solutions simplex(1)];
                evalSamplePoints(1) = [];
            end
            %Exit the main loop
            break;
        end
        
        %Should the current evaluation be sampled?
        if ~isempty(evalSamplePoints) && evalSamplePoints(1) < result.evaluations
            result.solutions = [result.solutions simplex(1)];
            evalSamplePoints(1) = [];
        end
    end
    
    %Fill the remaining sample points with the final solution
    missing = options.samples - numel(result.solutions);
    result.solutions = cat(2, result.solutions, repmat(simplex(1), 1, missing));
    
    %End of the algorithm
end

%Function to sort the specified simplex
function sortedSimplex = sortSimplex(simplex)
    [~, index] = sort([simplex.y]);
    sortedSimplex = simplex(index);
end