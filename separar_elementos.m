function [ notas ] = separar_elementos( compas )
%SEPARAR_ELEMENTOS Separa los distintos elementos de una imagen de un
%compas
%
%   [ELEMTNOS]=SEPARAR_ELEMENTOS(COMPAS) Segmenta COMPAS seg�n los
%   distintos elementos presentes en �l y devuelve un vector de celdas que
%   contiene, en cada posici�n, una matriz que representa una imagen que
%   contiene, aproximadamente centrado, el elemento.

%% Informaci�n
%   Autores
%       MOYA D�az, Antonio Jos�
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Im�genes
%   22 de junio de 2012

%% 
    % Calculamos las proyecciones del histograma
    inv=1-compas;
    histv=sum(inv);
    histh=sum(inv');
    
    % La moda del histograma vertical ser� la suma de las 5 l�neas.
    % Calcul�ndola y restando nos quedamos con el histograma de la nota. Y
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
    
    % Conociendo los ceros podemos ya realizar la segmentaci�n vertical
    notas={};
    k=1;
    for i=1:length(ceros)-1
        if (ceros(i+1)-ceros(i)) ~=1
            % Al realizar la segmentaci�n a�adir un margen de un pixel a
            % lado y lado del elemento.
            notas{k}=compas(:,ceros(i)-1:ceros(i+1)+1);
            k=k+1;
        end        
    end



end

