clc;
clear;
close all;

CostFunction = @(x) func5(x);  % Cost Function

maxIterations = 2000;     %Stopping condition
minValue = -600;         %Lower limit of the space problem.
maxValue = 600;          %Upper limit of the space problem.
minLocalValue = -1;  %Lower limit for local seeding.
maxLocalValue = 1;   %Upper limit for local seeding.
initialTrees = 100;      %Initial number of trees in the forest.
nVar = 6;               %Number of variables to optimize.
lifeTime = 6;           %Limit age to be part of the candidate list.
LSC = 3;                %Local seeding: Number of seeds by tree.
areaLimit = 100;        %Limit of trees in the forest.
transferRate = 0.1;    %Percentage of the trees in the candidate list that are going to global seed.
GSC = 2;                %Global seeding: Number of variables to be replaced by random numbers. MUST BE: GSC <= nVar.
maximaOrMinima = 1;     %Set -1 for maxima or 1 for minima.
candidateList = [];     %List of candidate trees.

bestTreeByIteration = zeros(maxIterations, 1);   %List of best trees on each iteration

%_______________________________
%_age__|__x1__|__x2___|__cost__|


%1. Initialize
forest = [zeros(initialTrees, 1) minValue + rand(initialTrees, nVar)*(maxValue - minValue) zeros(initialTrees, 1)];

%2. Main loop
for i=1:maxIterations
      %2.1 Local seeding
      initialTrees = size(forest, 1);
      for j=1:initialTrees
         if forest(j, 1) == 0     %2.1 If is a new tree
             for k=1:LSC        %Creating LSC seeds
                 randomVariable = round(2+rand(1)*(nVar-1));
                 smallValue = minLocalValue+rand(1)*(maxLocalValue - minLocalValue);
                 sizeTree = size(forest, 1)+1;
                 newTree = forest(j, :);
                 newTree(1) = 0;
                 
                 if newTree(randomVariable) + smallValue < minValue
                     newTree(randomVariable) = minValue;
                 elseif newTree(randomVariable) + smallValue > maxValue
                     newTree(randomVariable) = maxValue;
                 else
                     newTree(randomVariable) = newTree(randomVariable) + smallValue;
                 end
                 
                 forest( sizeTree, : ) = newTree;
             end
         end
         forest(j, 1) = forest(j, 1) + 1;
      end      
      
      %2.2 Population limiting
      for j=1:size(forest, 1)
         %2.2.1 Remove trees with age bigger than life time and add them to candidate list
         if j > size(forest, 1)
            break;
         end
         if forest(j, 1) > lifeTime
             sizeCandidateList = size(candidateList, 1)+1;
             candidateList(sizeCandidateList, :) = forest(j, :);
             forest = forest(setdiff(1:size(forest,1),j),:);
         end
      end
      
      %2.2.2 Sort tree according to fitness
      for j=1:size(forest, 1)
         forest(j, nVar+2) = CostFunction( forest(j, 2:(nVar+1)) ); 
      end
      forest = sortrows(forest, maximaOrMinima*(nVar+2));
      
      %2.2.3 Remove tree that exceed area limit and add them to candidate list
      if size(forest, 1) > areaLimit
          candidateList(end+1:end+size(forest, 1)-areaLimit, :) = forest(areaLimit+1:end, :);
          forest = forest(1:areaLimit, :);
      end
      
      
      %2.3 Global seeding
      %2.3.1 Choose number of trees from candidate tree
      selectedTrees = floor(transferRate * size(candidateList, 1));
      % Select "Transfer Rate" percent trees from the candidate population
      globalParents = randperm(selectedTrees);
      
      %2.3.1 Create new trees
      for j=1:selectedTrees
          sizeTree = size(forest, 1)+1;
          newTree = candidateList(globalParents(1, j), :);
          newTree(1) = 0;
          for k=1:GSC
              randomVariable = round(2+rand(1)*(nVar-1));
              smallValue = minValue+rand(1)*(maxValue - minValue);
              newTree(randomVariable) = smallValue;
          end
          forest( sizeTree, : ) = newTree;
      end
      
      %Limiting candidateList
      candidateList = [];
      
      %2.4 Update best tree
      forest(1, 1) = 0;
      
      bestTreeByIteration(i) = forest(1, nVar+2);
end

disp(forest(1, 2:nVar+1));
disp(forest(1, nVar+2));

%Show info
figure;
%semilogy(bestTreeByIteration, 'LineWidth', 2);
plot(bestTreeByIteration, 'LineWidth', 2);
title 'Forest optimization algorithm';
xlabel('Iteration');
ylabel('Best tree cost');
grid on;
