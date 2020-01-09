%Load the results for the 10D optimizations
if ~exist('sav10d', 'var')       
    load('sav10d.mat');
end

%Load the results for the 30D optimizations
if ~exist('sav30d', 'var')
    load('sav30d.mat');
end

if ~exist('tab4', 'var')
    load('exerc4sav.mat');
end 

if ~exist('tab3', 'var')
    tab3 = readtable('results/ResultsTable3.xlsx');
end 

if ~exist('tab2', 'var')
    tab2 = readtable('results/ResultsTable2.xlsx');
end 

if ~exist('tab1', 'var')
    tab1 = readtable('results/ResultsTable1.xlsx');
end 