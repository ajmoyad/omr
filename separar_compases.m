function [ compases2 ] = separar_compases( pentagrama )
%SEPARAR_COMPASES Extrae los compases de una imagen de pentagrama
%
%   [COMPAS]=SEPARAR_COMPASESA(PENTAGRAMA) Recibe una imagen de PENTAGRAMA
%   y la divide en sus distintos compases, devolviéndolos indexados en una
%   celda COMPAS.

%% Información
%   Autores
%       MOYA Díaz, Antonio José
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Imágenes
%   22 de junio de 2012

%%
    % Los ceros no suman, pero está mas claro si sumamos los ceros, por
    % eso, invertimos y contamos.
    inv=1-pentagrama;

    % Calculamos las proyecciones de su histograma
    histv=sum(inv);
    histh=sum(inv'); 
    
    % En el histograma vertical, quitamos la moda, es decir, el valor de
    % las 5 líneas del pentagrama para po
%    offset=mode(double(histv(:)));
%    histv=histv-offset;
    
    % El alto de todas las divisiones siempre será el mismo y, salvo quizá
    % la clave, será el máximo.
    maximo=max(histv(:,size(histv,2)/3:end));
    
    % Buscamos los valores máximos, que corresponderan a la barra de
    % separación entre compases.
    separador_compases=find(histv==maximo);
    % A veces el pentagrama está 'abierto' al principio (no tiene una barra
    % que delimite donde empieza) por lo que añadimos el índice 1 para el
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
            % De forma similar al caso anterior, el pentagrama podría estar
            % abierto por el final, por tanto, desde el último índice y
            % hasta el final de la línea suponemos otro compás.
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
        % A veces ocurre que las líneas no tienen exactamente la misma
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

    
    % Una vez determinado que el hipotético compás tiene las 5 líneas
    % necesarias para que sea parte del pentagrama, ahora, le exigimos un
    % ancho mínimo. Esto se hace así porque casos como la doble línea
    % vertical de final de pentagrama provoca que el algoritmo anterior
    % devuelva una región de muy pocos píxeles como compás, sin serlo.
    k=1;
    for i=1:limi

        if length(precompases{i})>=(0.3*longmax)
            compases2{k}=precompases{i};
            k=k+1;
        end
    end

end

