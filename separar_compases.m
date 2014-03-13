function [ compases2 ] = separar_compases( pentagrama )
%SEPARAR_COMPASES Extrae los compases de una imagen de pentagrama
%
%   [COMPAS]=SEPARAR_COMPASESA(PENTAGRAMA) Recibe una imagen de PENTAGRAMA
%   y la divide en sus distintos compases, devolvi�ndolos indexados en una
%   celda COMPAS.

%% Informaci�n
%   Autores
%       MOYA D�az, Antonio Jos�
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Im�genes
%   22 de junio de 2012

%%
    % Los ceros no suman, pero est� mas claro si sumamos los ceros, por
    % eso, invertimos y contamos.
    inv=1-pentagrama;

    % Calculamos las proyecciones de su histograma
    histv=sum(inv);
    histh=sum(inv'); 
    
    % En el histograma vertical, quitamos la moda, es decir, el valor de
    % las 5 l�neas del pentagrama para po
%    offset=mode(double(histv(:)));
%    histv=histv-offset;
    
    % El alto de todas las divisiones siempre ser� el mismo y, salvo quiz�
    % la clave, ser� el m�ximo.
    maximo=max(histv(:,size(histv,2)/3:end));
    
    % Buscamos los valores m�ximos, que corresponderan a la barra de
    % separaci�n entre compases.
    separador_compases=find(histv==maximo);
    % A veces el pentagrama est� 'abierto' al principio (no tiene una barra
    % que delimite donde empieza) por lo que a�adimos el �ndice 1 para el
    % primer corte.
    separador_compases=[1 separador_compases];
    
%     figure(2)
%     subplot(2,1,2),bar(histv);
%     subplot(2,1,1),imshow(pentagrama);
%     set(gca,'Xlim',[0 size(pentagrama,2)])  
%     
    
    compases={};
    k=1;
    maxit=length(separador_compases);
    for i=1:maxit
        if i==maxit
            % De forma similar al caso anterior, el pentagrama podr�a estar
            % abierto por el final, por tanto, desde el �ltimo �ndice y
            % hasta el final de la l�nea suponemos otro comp�s.
            compases{k}=pentagrama(:,separador_compases(i):end);
        else
            compases{k}=pentagrama(:,separador_compases(i):separador_compases(i+1));
        end
        k=k+1;
    end
    
    
    % En las separaciones realizadas, a veces quedan espacios inutiles.
    % Filtramos para quedarnos solo con los compases.
    precompases={};
    compases2={};
    anchos=[];
    k=1;
    limi=length(compases);
    
    % En primer lugar, comprobamos que el histograma de un compas tiene 5
    % maximos correspondientes al pentagrama.
    for i=1:limi
        experimento=compases{i};
        inv=1-experimento;
        histh=sum(inv');
        % A veces ocurre que las l�neas no tienen exactamente la misma
        % longitud, y no podemos permitir que se nos escape ninguna.
        maximos=find(histh>=0.75*max(histh));
        if length(maximos)==5
            precompases{k}=experimento;
            anchos(k)=length(experimento);
            k=k+1;
        end
    end
    
    limi=length(precompases);
    longmax=max(anchos);

    
    % Una vez determinado que el hipot�tico comp�s tiene las 5 l�neas
    % necesarias para que sea parte del pentagrama, ahora, le exigimos un
    % ancho m�nimo. Esto se hace as� porque casos como la doble l�nea
    % vertical de final de pentagrama provoca que el algoritmo anterior
    % devuelva una regi�n de muy pocos p�xeles como comp�s, sin serlo.
    k=1;
    for i=1:limi

        if length(precompases{i})>=(0.3*longmax)
            compases2{k}=precompases{i};
            k=k+1;
        end
    end

end

