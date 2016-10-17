
% Best_pos = mejor solucion encontrada por el optimizador
% Dim = dimensiones
% Data = piexeles de la imagen ordenados en columnas
% I = Imagen Original

%Reordena los centroides en una matris de 2 x num de clusters
c = reshape(Best_pos,[Dim size(Best_pos,2)/Dim]);
dist_c = dist(Data,c); %calcula la distancia de cada cluster al centroide
[~, ind] = min(dist_c,[],2);  % encuentra los indices de la  minima distancia

% a partir del vector de indices, genera una imagen reordenando el vector
Iout= reshape(ind,nrows,ncols);
figure
imshow(Iout,[])


% Genera las imagenes segmentadas
segmented_images = cell(1,Class_N); %inicializa matrices de imagenes segmnetadas
rgb_label = repmat(Iout,[1 1 3]); % copiala matriz de indices

%Genera las imagenes con los datos a partir de los indices y la imagen
%original
for k = 1:Class_N
    color = I; %Imagen original (copia)
    color(rgb_label ~= k) = 0; %pone en ceros los pixeles q no corresponden al cluster k en la copia de laimagen original
    segmented_images{k} = color; %asigna a la matriz k de segmented images
    
end

%muestra imagenes 
for i = 1:Class_N
    figure
    imshow(segmented_images{i});
end
