clc;
clear;
close all;

global im;
I = double(imread('medium.png'));
%imshow(im);
%im = imresize(im, [300 300]);      %Limiting image size
row = size(I, 1);
col = size(I, 2);
im = reshape(I, [row*col 3]);

CostFunction = @(x) kmeans(x);  % Cost Function

maxIterations = 3;     %Stopping condition
minValue = 0;           %Lower limit of the space problem.
maxValue = 255;         %Upper limit of the space problem.
minLocalValue = -5;     %Lower limit for local seeding.
maxLocalValue = 5;      %Upper limit for local seeding.
initialTrees = 30;      %Initial number of trees in the forest.
nVar = 3;               %Number of clusters
lifeTime = 6;           %Limit age to be part of the candidate list.
LSC = 3;                %Local seeding: Number of seeds by tree.
areaLimit = 50;         %Limit of trees in the forest.
transferRate = 0.01;    %Percentage of the trees in the candidate list that are going to global seed.
GSC = 2;                %Global seeding: Number of variables to be replaced by random numbers. MUST BE: GSC <= nVar.
maximaOrMinima = 1;     %Set -1 for maxima or 1 for minima.
candidateList = [];     %List of candidate trees.

bestTreeByIteration = zeros(maxIterations, 1);   %List of best trees on each iteration

%_______________________________
%_age__|__x1__|__x2___|__cost__|


%1. Initialize
forest = [zeros(initialTrees, 1) round(minValue + rand(initialTrees, nVar)*(maxValue - minValue)) zeros(initialTrees, 1)];
forest(:, :, 2) = [zeros(initialTrees, 1) round(minValue + rand(initialTrees, nVar)*(maxValue - minValue)) zeros(initialTrees, 1)];
forest(:, :, 3) = [zeros(initialTrees, 1) round(minValue + rand(initialTrees, nVar)*(maxValue - minValue)) zeros(initialTrees, 1)];

%2. Main loop
for i=1:maxIterations
      tic
      %2.1 Local seeding
      initialTrees = size(forest, 1);
      for j=1:initialTrees
         if forest(j, 1, 1) == 0     %2.1 If is a new tree
             for k=1:LSC           %Creating LSC seeds
                 randomVariable = round(2+rand(1)*(nVar-1));
                 smallValue = round(minLocalValue+rand(1)*(maxLocalValue - minLocalValue));
                 sizeTree = size(forest, 1)+1;
                 newTree = forest(j, :, :);
                 newTree(1, 1, 1) = 0;
                 
                 %Random RGB variable
                 randomRGB = randi([1 3]);
                 
                 %Modifica una variable RGB de un cluster
                 if newTree(1, randomVariable, randomRGB) + smallValue < minValue
                     newTree(1, randomVariable, randomRGB) = minValue;
                 elseif newTree(1, randomVariable, randomRGB) + smallValue > maxValue
                     newTree(1, randomVariable, randomRGB) = maxValue;
                 else
                     newTree(1, randomVariable, randomRGB) = newTree(1, randomVariable, randomRGB) + smallValue;
                 end
                 
                 forest( sizeTree, :, : ) = newTree;
             end
         end
         forest(j, 1, 1) = forest(j, 1, 1) + 1;
      end
      
      %2.2 Population limiting
      for j=1:size(forest, 1)
         %2.2.1 Remove trees with age bigger than life time and add them to candidate list
         if j > size(forest, 1)
            break;
         end
         if forest(j, 1, 1) > lifeTime
             sizeCandidateList = size(candidateList, 1)+1;
             candidateList(sizeCandidateList, :, :) = forest(j, :, :);
             forest(j, :, :) = [];
         end
      end
      
      %2.2.2 Sort tree according to fitness
      for j=1:size(forest, 1)
         forest(j, nVar+2, 1) = CostFunction( transpose(squeeze(forest(j, 2:(nVar+1), :))) );
         forest(j, nVar+2, 2) = forest(j, nVar+2, 1);
         forest(j, nVar+2, 3) = forest(j, nVar+2, 1);
      end
      %Sorting
      forest(:, :, 1) = sortrows(forest(:, :, 1), nVar+2);
      forest(:, :, 2) = sortrows(forest(:, :, 2), nVar+2);
      forest(:, :, 3) = sortrows(forest(:, :, 3), nVar+2);
      %End sorting
      
      %2.2.3 Remove tree that exceed area limit and add them to candidate list
      if size(forest, 1) > areaLimit
         candidateList(size(candidateList, 1)+1:size(candidateList, 1)+size(forest, 1)-areaLimit, :, :) = forest(areaLimit+1:size(forest, 1), :, :);
          forest(areaLimit+1:size(forest, 1), :, :) = [];
      end
      
      %2.3 Global seeding
      %2.3.1 Choose number of trees from candidate tree
      selectedTrees = floor(transferRate * size(candidateList, 1));
      globalParents = randperm(selectedTrees);
      
      %2.3.1 Create new trees
      for j=1:selectedTrees
          sizeTree = size(forest, 1)+1;
          newTree = candidateList(globalParents(1, j), :, :);
          newTree(1, 1, 1) = 0;
          for k=1:GSC
              %Random RGB variable
              randomRGB = randi([1 3]);
              randomVariable = round(2+rand(1)*(nVar-1));
              smallValue = round(minValue+rand(1)*(maxValue - minValue));
              newTree(1, randomVariable, randomRGB) = smallValue;
          end
          forest( sizeTree, :, : ) = newTree;
      end
      
      %Limiting candidateList
      candidateList = [];
      
      %2.4 Update best tree
      forest(1, 1, 1) = 0;
      
      bestTreeByIteration(i) = forest(1, nVar+2, 1);
      
      disp(fprintf('Iteration: %d in time: %f cost: %f', i, toc, bestTreeByIteration(i)));
end

disp(bestTreeByIteration(maxIterations));
disp(forest(1, 2:nVar+1, :));


%Show results
figure;
plot(bestTreeByIteration, 'LineWidth', 2);
% semilogy(bestTreeByIteration, 'LineWidth', 2);
title 'Forest optimization algorithm for image clustering';
xlabel('Iteration');
ylabel('Best tree cost');
grid on;


%Display images
bestTree = transpose(squeeze(forest(1, 2:nVar+1, :)));

[~, ind] = min(transpose(dist(im, bestTree)));
ind = transpose(ind);
ind = reshape(ind, row, col);
% imshow(ind,[]);

rgb_label = repmat(ind,[1 1 3]);
segmented_images = cell(1, nVar);

for i=1:nVar
   color = I;
   color(rgb_label ~= i) = 0;
   segmented_images{i} = color;
end

for i=1:nVar
    figure
    imshow(segmented_images{i});
end


