function [pentagramas] = recon_pentagramas( recortadah )
%RECON_PENTAGRAMAS Reconoce, de una imagen, si se trata de un pentagrama o
%no
%
%   [PENT]=RECON_PENTAGRAMAS(IMG) analiza las distintas lineas de una
%   imagen segmentada, IMG, reconociendo si se tratan o no de pentagramas.
%   Devuelve un vector de celdas conteniendo aquellas que se traten de
%   pentagramas

%% Informaci�n
%   Autores
%       MOYA D�az, Antonio Jos�
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Im�genes
%   22 de junio de 2012

    pentagramas={};
    k=1;
    limi=length(recortadah);
    %maximos=[];
    for i=1:limi
        experimento=recortadah{i};
        inv=1-experimento;
        histh=sum(inv');
        % Podr�a ocurrir que las l�neas del pentagrama no fueran
        % exactamente iguales en longitud, por tanto, tampoco lo ser�an sus
        % valores del histograma. Para asegurarnos de que existen tales
        % l�neas, y que, por tanto, se trata de un pentagrama buscamos
        % exactamente 5 valores que superen, el menos, el 75% del
        % histograma.
        maximos=find(histh>=0.75*max(histh));
        if length(maximos)==5
            pentagramas{k}=recortadah{i};
            k=k+1;
        end
    end
end
