## Computational Work for Optimization discipline

### Follow the link below to watch a demo:
https://www.youtube.com/watch?v=dAM3orE9PV0


The problems have been retrieved from [CEC2013 (Problem Definitions and Evaluation Criteria for the CEC 2013 Special Session on Real-Parameter Optimization](/Problems_CEC2013.pdf).

The evaluation criteria has been retrieved from [Evaluation_2019](/Evaluation_2019.pdf)

### Phase I: Study of the Optimization Methods 
#### Classical Approaches: 

* Nelder-Mead (available in MATLAB); 
* Hooke-Jeeves; 
* Implicit Filtering; 
* Multidirectional Search; 
* Pattern Search (available in MATLAB); 

### Phase II: Problems 

In both engineering and computer science, optimization methods are applied to 
solve real world problems. However, to test these techniques, some mathematical 
functions can be adopted. Here, the following functions must be optimized: 

* Sphere Function (F1); 
* Rotated High Conditioned Elliptic Function (F2) 
* Rotated Bent Cigar Function (F3); 
* Rotated Discus Function (F4); 
* Different Powers Function (F5); 

#### Evaluation Criteria: 

All the optimization methods (Nelder-Mead, Hooke-Jeeves, Implicit Filtering, 
Multidirectional Search, DIRECT, Pattern Search, and the additional technique of your 
choice should be evaluated according to the specification reported at 
Problems_CEC2013.pdf”. However, this course will limit the evaluation criteria to: 
 * Dimensions: D = 10 e D = 30; 
 * Runs per problem: 51; 
 * Initialization: Uniform random initialization within the search space. Random 
seed is based on time. In MATLAB users can perform the initialization using: 
('state', sum(100*clock)); 
 * Search space: x = [-100, 100]^D; 
 * Maximum number of function evaluations (MaxFES): 10000*D (MaxFES for 10D 
= 100000, for 30D = 300000); 
 * Termination criteria: terminate when reaching MaxFES or the error value is 
smaller than 10-8. 
 * Global Optimum: All problems have the global optimum within the given bounds 
and there is no need to perform search outside of the given bounds for these 
problems, see Fi *= Fi(x*) in Table I available in [“Problems_CEC2013.pdf”](/Problems_CEC2013.pdf) to 
verify the global optimum of each required function. 

