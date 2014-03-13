function [ figura, tipo ] = figura_musical( img )
%FIGURA_MUSICAL Identifica el tipo de figura musical de una imagen de
%figura musical dada.
%
%   [FIG TIPO]=FIGURA_MUSICAL(IMG) toma una imagen IMG y la compara con una
%   base de datos plantillas en busca de identificar la figura musical que
%   se haya en IMG. Devuelve una cadena de texto con el nombre de la figura
%   musical y una variable de control tipo donde:
%       tipo 1:     Es una nota
%       tipo 2:     Es un silencio
%       tipo 3:     Es otro tipo de figura musical identificable

%% Información
%   Autores
%       MOYA Díaz, Antonio José
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Imágenes
%   22 de junio de 2012


    %% Preparado de la imagen para comparar
    
    % Vamos a recibir la imagen de la nota aislada, pero no estará
    % preparada para la comparación con las máscaras, por lo que el primer
    % paso será prepararla.

    imagen=img;
    
    % Calculamos su proyección horizontal
    inv=1-imagen;
    histh=sum(inv');
    
    % Localizamos las líneas para poder borrarlas
    lines=find(histh==max(histh));
    % Y las borramos
    imagen(lines,:)=1;
    
    % Recalculamos los nuevos histogramas
    inv=1-imagen;
    histv=sum(inv);
    histh=sum(inv');
    
    %1. Reducción y centrado de la nota
    %----------------------------------
    
    % Sin las líneas, la figura nos queda 'limpia' con espacios alrededor.
    % Vamos eliminar esos espacios que podrían ser molestos al comparar.
    % Sin embargo, la eliminación completa de estos espacios puede
    % generarnos problemas a la hora de identificar y diferenciar los
    % silencios de blanca y redonda. Así pues, lo que vamos a hacer es
    % minimizar ese espacio en blanco alrededor de las notas hasta que
    % tenga un grosor exacto de 1 pixel. Con ello conseguiremos diferenciar
    % entre los silencios de blanca y redonda sin llegar a perjudir la
    % detección del resto de las figuras.
    h=find(histh>0);
    v=find(histv>0);

    % Una vez localizadas las coordenadas de la nota, establecemos el punto
    % inicial del corte a un pixel antes.
    x1=v(1)-1;
    y1=h(1)-1;
    
    % Calculamos el ancho del corte teniendo en cuenta que queremos dejar
    % un pixel por detrás.
    yw=h(end)+2-y1;
    xw=v(end)+2-x1;

    % Finalmente recortamos la imagen
    imagen=imcrop(imagen,[x1 y1 xw yw]);
    
    %figure,imshow(imagen); pause
    
    
    %2. Corrección de la eliminación de las líneas
    %---------------------------------------------
    
    % Al eliminar las lineas del pentagrama, también hemos eliminado parte
    % de la nota correspondiente a la plica (solo para las notas con plica)
    % pero dicha parte, la podemos recuperar fácilmente. 
    % Si bien esto podría introducirnos un error en las notas sin plica.
    
    % Recalculamos, nuevamente, los histogramas
    inv=1-imagen;
    histv=sum(inv);
    histh=sum(inv');
    
    % Buscamos, en el histograma horizontal los puntos que sean 0 (es
    % decir, lineas horizontales completas en blanco
    % Luego miramos, para esas líneas, en qué puntos hay un maximo vertical
    % y los rellenamos. Así hemos corregido la nota, además, de forma que
    % introducirá un bastante bajo error en las notas que no tengan plica.
    % Con suerte el error será tan pequeño que no afectará a la
    % correlación.
    h=find(histh==0);
    [maxv maxi]=max(histv);

    % Con esto ya tenemos la nota corregida
    imagen(h,maxi)=0;
    
    
    %% Búsqueda de la figura correcta
    
    % Cargamos la base de datos con las máscaras
    load('BD.mat');
    
    % La base de datos se haya ordenada de la siguiente forma:
    % Consta de 3 tablas de las cuales la tabla 1 corresponde con las
    % figuras de las notas, la tabla 2 con los silencios de las notas y la
    % tabla 3 con otras figuras que sean necesario comparar.
    % Cada tabla se compone de 2 columnas de tal forma que en la primera
    % columna se haya una cadena de texto con el nombre de la figura que se
    % haya almacenada en la posición correspondiente de la columna 2.
    % Para el caso de la tabla 1, de las notas, se hayan duplicadas las
    % notas con plica (de momento solo hay blancas y negras) que, estando
    % almacenadas en posiciones sucesivas, se encuentra la figura con el
    % plica hacia arriba primero, y la figura con la plica hacia abajo
    % despues.
        
    inicio=1;
    maximos={{}}; % Almacenará los resultados de la comparación tabla a tabla
    comp=[]; % Almacenará los resultados de la correlación
    maxit1=size(base_datos,2);
    
    for n=inicio:maxit1
        % Iteramos sobre el número de tablas de la base de datos
        
        % Extraemos la tabla a analizar
        tabla=base_datos{1,n};
        
        maxit2=size(base_datos{n},1);
        for m=1:maxit2
            % Iteramos sobre los elementos de la tabla
            
            % Extraemos la plantilla a comparar
            template=tabla{m,2};
            % Redimensionamos la imagen a identificar al tamaño de la
            % plantilla
            imagenr=imresize(imagen,size(template));
        
            % Descomentar para depuración
%             figure
%             subplot(1,2,1),imshow(imagenr),title('Figura a identificar');
%             subplot(1,2,2),imshow(template),title('Plantilla');
%             pause(0.2);
        
            % Lanzamos la correlación
            similitud=corr2(template,imagenr);
            % Guardamos el resultado de la correlación para esta tabla en
            % un vector
            comp=[comp similitud];
        end
        
        % Del vector de resultados de la correlación extraemos el máximo
        [m nota_previa]=max(comp);
        
        % Almacenamos el resultado derivado de la correlación máxima en un
        % vector. Estamos almacenando un único valor máximo por cada tabla
        maximos{n}={m tabla{nota_previa,1} tabla{nota_previa,2}};
        
        % Reseteamos el vector de resultados
        comp=[];
    end
    
    % Una vez acabada la iteración tenemos un vector con tres posiciones,
    % son los tres máximos hallados, uno por tabla. Comparamos y extraemos
    % el mayor de los 3.
    [value tipo]=max([maximos{1,1}{1} maximos{1,2}{1} maximos{1,3}{1}]);
 
    
     %% Validación
     
     % Con el procedimiento diseñado hasta ahora nos hemos encontrado con
     % una ambigüedad entre las notas blancas y las notas negras. Así como
     % entre los silencios de blanca y redonda.
     
     % Así pues, decidimos diseñar un método de validación para estos casos
     % ambiguos.
     
     % Si la nota detectaba es blanca, la nota será blanca con casi total
     % seguridad. En cambio, si la nota detectada es negra, hay una alta
     % probabilidad de que sea blanca. Así pues, realizaremos la validación
     % solo si tipo=1, es decir, es una nota -no un silencio ni otra
     % figura, y si además se trata de una nota negra.
     if tipo==1 && strcmp(maximos{1,tipo}{2},'negra')         
         
         % De una forma muy parecida a lo anterior, vamos a iterar, pero en
         % este caso de forma estatica entre las plantillas de las blancas
         % y las engras.
         comp=[];
         tabla=base_datos{1,1};
         for i=2:5
             
             template=tabla{i,2};
             
             % Aquí introducimos la corrección necesaria para poder
             % discernir entre blanca y negra.
             
             % Si el índice es par se tratará de una plantilla con la plica
             % hacia arriba, ergo la corrección debe ser introducida abajo.
             if rem(i,2)==0 % es par
                 % Creamos el vector de corrección
                 % Lo hacemos del mismo tamaño que la imagen a identificar.
                 % Además, si la corrección es abajo, la insercción de
                 % pixeles negros será a la izquierda.
                 t=size(imagen,2);
                 correccion=zeros(1,t);
                 correccion(floor(t/2):end)=1;
                 % Corregimos y umbralizamos
                 imagen2=[imagen; correccion];
                 imagen2=im2bw(imagen2);
             else
                t=size(imagen,2);
                correccion=zeros(1,t);
                % Igual que antes, pero con la insercción a la derecha
                correccion(1:floor(t/2))=1;
                imagen2=[correccion; imagen];
                imagen2=im2bw(imagen2);
             end
             
             % Realizamos la correlación
             imagenr=imresize(imagen2,size(template));
             simil=corr2(template,imagenr);
             comp=[comp simil];
             
         end
         
         % En este punto tenemos un vector con los valores de la
         % correlación. Extraemos su máximo para identificar la nota.
         [vl n]=max(comp);
         % Como hemos iterado empezando en 2, nuestro índice n estará una
         % posición desplazado con respecto a la figura correcta de la
         % tabla, asi que sumamos uno.
         nota_val=n+1;
         % Devolvemos la cadena de texto que identifica al tipo de nota.
         figura=tabla{nota_val,1};
      
     elseif tipo==2 && (strcmp(maximos{1,tipo}{2},'silencio de blanca') || strcmp(maximos{1,tipo}{2},'silencio de negra'))
         % Resulta que también tenemos una ambigüedad entre los silencios
         % de blanca y redonda.
         % En este caso vamos a diferenciar entre una y otra mirando su
         % posición con respecto a las líneas del pentagrama.
         
         % Calculamos su proyección horizontal
         inv=1-img;
         histh=sum(inv');
         % Buscamos todos los valores mayores que 0. Eso es, detectarán
         % lineas y silencio.
         indices=find(histh>0);
         % Detectamos las líneas y calculamos la distancia entre ellas
         lineas=find(histh==max(histh));
         dist=lineas(2)-lineas(1);
         
         % La idea es la siguiente, vamos a ir comparando las diferencias
         % entre los índices que hemos obtenido donde le histograma es
         % mayor que 0.
         % Vamos a calcular las diferencias en parejas.
         % Esas diferencias, esas distancias, las vamos a comparar con el
         % espacio entre líneas.
         
         % Si encontramos una distancia menor que el espacio entre líneas
         % (lo que nos indica que hay 'algo' en el hueco) y la siguiente
         % distancia es exactamente 1, tal y como estamos recorriendo el
         % vector, significará que el silencio está "hacia arriba", es
         % decir, será de blanca.
         % Si por contra la primera distancia corresponde exactamente con 1
         % y la segunda distancia es menor que el espacio entre líneas,
         % significará que la figura está 'hacia abajo' y por tanto, será 
         % silencio de redonda.
         i=1;
         % Usamos una variable de control para parar la iteración en caso
         % de encontrar el resultado.
         ctrl=false;
         while ctrl==false && i<length(indices)-2
             % Calculamos las distancias
             d1=indices(i+1)-indices(i);
             d2=indices(i+2)-indices(i+1);    
             
             % Comprobamos
             if d1<dist && d2==1
                 figura='silencio de blanca'; 
                 ctrl=true;
             end
             if d1==1 && d2<dist
                 figura='silencio de redonda';
                 ctrl=true;
             end
 
             i=i+1;% Incrementamos el iterador
         end
        
     else
         % En caso contrario, si no era una negra, ni un silencio 
         % todo lo anterior es innecesario y devolvemos directamente 
         % la cadena de texto que identifica a la figura.
         figura=maximos{1,tipo}{2};
     end
      
end

