function [ segmentada ] = corte_horizontal(imagen)
%CORTE_HORIZONTAL Realiza una separación horizontal de las distintas líneas
%de contenido presentes en una imagen.
%
%   [SEG]=CORTE_HORIZONTAL(IMG) Recibe una imagen IMG de un pentagrama y la
%   divide en las distintas líneas, ya sean compases o texto, del mismo.
%   Devuelve en SEG una celda donde cad posición es una matriz que
%   representa al trozo de imagen segmentada 

%%  Tipo de dato de la imagen
%   En lo sucesivo vamos a trabajar con imágenes binarias, sin embargo, la
%   imagen que introduzca el usuario puede estar en cualquier formato por
%   lo que hemos de hacer que nuestro programa reconozca el tipo y gestione
%   la imagen correctamente de forma completamente transparente para el
%   usuario.

    if strcmp(class(imagen),'uint8') && max(imagen(:))<=1
        % Si la clase es uint8 [0,255] pero su valor máximo es 1, tendremos
        % una imagen mal representada, por lo que la forzamos a que sea de
        % tipo double
        imagen=double(imagen);
    elseif strcmp(class(imagen),'double') && max(imagen(:))>1
        % Si tenemos una clase double [0,1] pero su máximo es mayor que 1,
        % al igual que antes, tendremos la imagen mal representada, por lo
        % que la forzamos a uin8.
        imagen=uint8(imagen);
    end

    % Binarizamos la imagen
    I=im2bw(imagen);
    
    % Los ceros no suman, pero está mas claro si sumamos los ceros, por
    % eso, invertimos y contamos.
    inv=1-I;

    % Calculamos la proyección de su histograma horizontal
    %histv=sum(inv);
    histh=sum(inv');
    
    segmentada={};
    % limites=[];
    % Buscamos los valores donde el histograma se hace 0. Serán los puntos
    % por los que segmentar la imagen.
    ceros=find(histh==0);
    
    k=1;
    for i=1:length(ceros)-1;
        % Del vector que contiene los índices donde el histograma se hace 0
        % vamos comparando elemento a elemento. Si la diferencia de dos
        % indices consecutivos es mayor que 1, será porque ha habido un
        % salto, por lo que i e i+1 serán los índices que marcan principio
        % y fin de la zona a recortar.
        if (ceros(i+1)-ceros(i))~=1
            segmentada{k}=I(ceros(i):ceros(i+1),:);
            k=k+1;
        end
    end


end

