function [ notas ] = separar_elementos( compas )
%SEPARAR_ELEMENTOS Separa los distintos elementos de una imagen de un
%compas
%
%   [ELEMTNOS]=SEPARAR_ELEMENTOS(COMPAS) Segmenta COMPAS según los
%   distintos elementos presentes en él y devuelve un vector de celdas que
%   contiene, en cada posición, una matriz que representa una imagen que
%   contiene, aproximadamente centrado, el elemento.

%% Información
%   Autores
%       MOYA Díaz, Antonio José
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Imágenes
%   22 de junio de 2012

%% 
    % Calculamos las proyecciones del histograma
    inv=1-compas;
    histv=sum(inv);
    histh=sum(inv');
    
    % La moda del histograma vertical será la suma de las 5 líneas.
    % Calculándola y restando nos quedamos con el histograma de la nota. Y
    % calculando los ceros tendremos delimitada la nota.
    offset=mode(double(histv(:)));
    histv=histv-offset;
    ceros=find(histv==0);
    
%         figure(31),
%     subplot(2,2,1),barh(fliplr(histh));
%     set(gca,'Ylim',[0 size(inv,1)])
%     subplot(2,2,2),imshow(compas);
%     subplot(2,2,4),bar(histv);
%         set(gca,'Xlim',[0 size(inv,2)]) 
    
    % Conociendo los ceros podemos ya realizar la segmentación vertical
    notas={};
    k=1;
    for i=1:length(ceros)-1
        if (ceros(i+1)-ceros(i)) ~=1
            % Al realizar la segmentación añadir un margen de un pixel a
            % lado y lado del elemento.
            notas{k}=compas(:,ceros(i)-1:ceros(i+1)+1);
            k=k+1;
        end        
    end



end

