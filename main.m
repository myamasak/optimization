clear all
close all
clc

%mex cec13_func.cpp -DWINDOWS

% Function numbers
% Sphere Function (F1);
% Rotated High Conditioned Elliptic Function (F2)
% Rotated Bent Cigar Function (F3);
% Rotated Discus Function (F4);
% Different Powers Function (F5);
funcNum=[1,2,3,4,5];

%Function-related declarations
functionNames = {'Sphere Function',...
    'Rotated High Conditioned Elliptic Function',...
    'Rotated Bent Cigar Function',...
    'Rotated Discus Function',...
    'Different Powers Function'};

% Optimization algorithms
optimizationNames = {'Nelder-Mead','Hooke-Jeeves','Implicit Filtering','Multidirectional Search','Pattern Search'};
algorithms = {@nelderMead, @hookeJeeves, @implicitFiltering,...
    @multidirectionalSearch, @patternSearch, @geneticAlgorithm};

% Global Minimums
globalMins=[-1400,-1300,-1200,-1100,-1000];


% Dimensions
D=[10,30];
% D=[5];

%Limits
Xmin=-100;
Xmax=100;

% Number of runs
runNum=51;
% runNum = 2;

%% Load CEC13 function
% fhd=str2func('cec13_func');

%Result structure
result.evaluations = 0;
result.solutions = [];
result.globalMin = 0;
result.epsillon = 0;
result.maxFES = 0;
result.samples = 0;




% Loop of dimensions - (10D,30D) - 2x
for i0=1:numel(D)
    % General optimization options
    % Function evaluations
    options.maxFES = 10000 * D(i0); 
    % Number of samples
    options.samples = 100; 
    % Residual error epsillon
    options.epsillon = 1e-8; 
    % Do not pause, just run
    options.pauseIfNeeded = false; 
    % Lower/Upper bounds
    lowerLimits = Xmin * ones(1, D(i0)); %Lower bounds
    upperLimits = Xmax * ones(1, D(i0)); %Upper bounds

    % Loop of Optimization algorithms - 5x
    for i1=1:numel(optimizationNames)
        %Algorithm to be run
        algorithm = algorithms{i1};
        % Loop of available Functions - 5x
        for i2=1:numel(funcNum)            
            %Problem specific options
            options.globalMin = globalMins(i2); %Global minimum 
            %Objective function
            objFnc = @(x) cec13_func(x', funcNum(i2));
            
            fprintf('%d Dimensions, Method %s, %s \n',...
            D(i0), optimizationNames{i1}, functionNames{i2});
            % Loop of runs - 51x
            for i3=1:runNum
                % Run the algorithm and alert when it's done
%                 fprintf('%d Dimensions, Method %s, %s, Run #%d... ',...
%                 D(i0), optimizationNames{i1}, functionNames{i2}, i3);
                fprintf('Run #%d ',i3);
                
                % Run
                
                runs(i0, i1, i2, i3) = algorithm(objFnc, D(i0),...
                    lowerLimits, upperLimits, options);
                
                fprintf(' Partial result: y=%e \n',min([runs(i0, i1, i2, i3).solutions.y]));
                if i3==1
                    fprintf(' Done!\n');
                else
                    fprintf('Done!\n');
                end
                
            end
        end
    end
end

%% Results saving
%Save the 10-D optimization results
sav10d = permute(runs(1,:,:,:), [2 3 4 1]);
save('sav10d.mat', 'sav10d');

%Save the 30-D optimization results
sav30d = permute(runs(2,:,:,:), [2 3 4 1]);
save('sav30d.mat', 'sav30d');

