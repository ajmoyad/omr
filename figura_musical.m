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

%% Informaci�n
%   Autores
%       MOYA D�az, Antonio Jos�
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Im�genes
%   22 de junio de 2012


    %% Preparado de la imagen para comparar
    
    % Vamos a recibir la imagen de la nota aislada, pero no estar�
    % preparada para la comparaci�n con las m�scaras, por lo que el primer
    % paso ser� prepararla.

    imagen=img;
    
    % Calculamos su proyecci�n horizontal
    inv=1-imagen;
    histh=sum(inv');
    
    % Localizamos las l�neas para poder borrarlas
    lines=find(histh==max(histh));
    % Y las borramos
    imagen(lines,:)=1;
    
    % Recalculamos los nuevos histogramas
    inv=1-imagen;
    histv=sum(inv);
    histh=sum(inv');
    
    %1. Reducci�n y centrado de la nota
    %----------------------------------
    
    % Sin las l�neas, la figura nos queda 'limpia' con espacios alrededor.
    % Vamos eliminar esos espacios que podr�an ser molestos al comparar.
    % Sin embargo, la eliminaci�n completa de estos espacios puede
    % generarnos problemas a la hora de identificar y diferenciar los
    % silencios de blanca y redonda. As� pues, lo que vamos a hacer es
    % minimizar ese espacio en blanco alrededor de las notas hasta que
    % tenga un grosor exacto de 1 pixel. Con ello conseguiremos diferenciar
    % entre los silencios de blanca y redonda sin llegar a perjudir la
    % detecci�n del resto de las figuras.
    h=find(histh>0);
    v=find(histv>0);

    % Una vez localizadas las coordenadas de la nota, establecemos el punto
    % inicial del corte a un pixel antes.
    x1=v(1)-1;
    y1=h(1)-1;
    
    % Calculamos el ancho del corte teniendo en cuenta que queremos dejar
    % un pixel por detr�s.
    yw=h(end)+2-y1;
    xw=v(end)+2-x1;

    % Finalmente recortamos la imagen
    imagen=imcrop(imagen,[x1 y1 xw yw]);
    
    %figure,imshow(imagen); pause
    
    
    %2. Correcci�n de la eliminaci�n de las l�neas
    %---------------------------------------------
    
    % Al eliminar las lineas del pentagrama, tambi�n hemos eliminado parte
    % de la nota correspondiente a la plica (solo para las notas con plica)
    % pero dicha parte, la podemos recuperar f�cilmente. 
    % Si bien esto podr�a introducirnos un error en las notas sin plica.
    
    % Recalculamos, nuevamente, los histogramas
    inv=1-imagen;
    histv=sum(inv);
    histh=sum(inv');
    
    % Buscamos, en el histograma horizontal los puntos que sean 0 (es
    % decir, lineas horizontales completas en blanco
    % Luego miramos, para esas l�neas, en qu� puntos hay un maximo vertical
    % y los rellenamos. As� hemos corregido la nota, adem�s, de forma que
    % introducir� un bastante bajo error en las notas que no tengan plica.
    % Con suerte el error ser� tan peque�o que no afectar� a la
    % correlaci�n.
    h=find(histh==0);
    [maxv maxi]=max(histv);

    % Con esto ya tenemos la nota corregida
    imagen(h,maxi)=0;
    
    
    %% B�squeda de la figura correcta
    
    % Cargamos la base de datos con las m�scaras
    load('BD.mat');
    
    % La base de datos se haya ordenada de la siguiente forma:
    % Consta de 3 tablas de las cuales la tabla 1 corresponde con las
    % figuras de las notas, la tabla 2 con los silencios de las notas y la
    % tabla 3 con otras figuras que sean necesario comparar.
    % Cada tabla se compone de 2 columnas de tal forma que en la primera
    % columna se haya una cadena de texto con el nombre de la figura que se
    % haya almacenada en la posici�n correspondiente de la columna 2.
    % Para el caso de la tabla 1, de las notas, se hayan duplicadas las
    % notas con plica (de momento solo hay blancas y negras) que, estando
    % almacenadas en posiciones sucesivas, se encuentra la figura con el
    % plica hacia arriba primero, y la figura con la plica hacia abajo
    % despues.
        
    inicio=1;
    maximos={{}}; % Almacenar� los resultados de la comparaci�n tabla a tabla
    comp=[]; % Almacenar� los resultados de la correlaci�n
    maxit1=size(base_datos,2);
    
    for n=inicio:maxit1
        % Iteramos sobre el n�mero de tablas de la base de datos
        
        % Extraemos la tabla a analizar
        tabla=base_datos{1,n};
        
        maxit2=size(base_datos{n},1);
        for m=1:maxit2
            % Iteramos sobre los elementos de la tabla
            
            % Extraemos la plantilla a comparar
            template=tabla{m,2};
            % Redimensionamos la imagen a identificar al tama�o de la
            % plantilla
            imagenr=imresize(imagen,size(template));
        
            % Descomentar para depuraci�n
%             figure
%             subplot(1,2,1),imshow(imagenr),title('Figura a identificar');
%             subplot(1,2,2),imshow(template),title('Plantilla');
%             pause(0.2);
        
            % Lanzamos la correlaci�n
            similitud=corr2(template,imagenr);
            % Guardamos el resultado de la correlaci�n para esta tabla en
            % un vector
            comp=[comp similitud];
        end
        
        % Del vector de resultados de la correlaci�n extraemos el m�ximo
        [m nota_previa]=max(comp);
        
        % Almacenamos el resultado derivado de la correlaci�n m�xima en un
        % vector. Estamos almacenando un �nico valor m�ximo por cada tabla
        maximos{n}={m tabla{nota_previa,1} tabla{nota_previa,2}};
        
        % Reseteamos el vector de resultados
        comp=[];
    end
    
    % Una vez acabada la iteraci�n tenemos un vector con tres posiciones,
    % son los tres m�ximos hallados, uno por tabla. Comparamos y extraemos
    % el mayor de los 3.
    [value tipo]=max([maximos{1,1}{1} maximos{1,2}{1} maximos{1,3}{1}]);
 
    
     %% Validaci�n
     
     % Con el procedimiento dise�ado hasta ahora nos hemos encontrado con
     % una ambig�edad entre las notas blancas y las notas negras. As� como
     % entre los silencios de blanca y redonda.
     
     % As� pues, decidimos dise�ar un m�todo de validaci�n para estos casos
     % ambiguos.
     
     % Si la nota detectaba es blanca, la nota ser� blanca con casi total
     % seguridad. En cambio, si la nota detectada es negra, hay una alta
     % probabilidad de que sea blanca. As� pues, realizaremos la validaci�n
     % solo si tipo=1, es decir, es una nota -no un silencio ni otra
     % figura, y si adem�s se trata de una nota negra.
     if tipo==1 && strcmp(maximos{1,tipo}{2},'negra')         
         
         % De una forma muy parecida a lo anterior, vamos a iterar, pero en
         % este caso de forma estatica entre las plantillas de las blancas
         % y las engras.
         comp=[];
         tabla=base_datos{1,1};
         for i=2:5
             
             template=tabla{i,2};
             
             % Aqu� introducimos la correcci�n necesaria para poder
             % discernir entre blanca y negra.
             
             % Si el �ndice es par se tratar� de una plantilla con la plica
             % hacia arriba, ergo la correcci�n debe ser introducida abajo.
             if rem(i,2)==0 % es par
                 % Creamos el vector de correcci�n
                 % Lo hacemos del mismo tama�o que la imagen a identificar.
                 % Adem�s, si la correcci�n es abajo, la insercci�n de
                 % pixeles negros ser� a la izquierda.
                 t=size(imagen,2);
                 correccion=zeros(1,t);
                 correccion(floor(t/2):end)=1;
                 % Corregimos y umbralizamos
                 imagen2=[imagen; correccion];
                 imagen2=im2bw(imagen2);
             else
                t=size(imagen,2);
                correccion=zeros(1,t);
                % Igual que antes, pero con la insercci�n a la derecha
                correccion(1:floor(t/2))=1;
                imagen2=[correccion; imagen];
                imagen2=im2bw(imagen2);
             end
             
             % Realizamos la correlaci�n
             imagenr=imresize(imagen2,size(template));
             simil=corr2(template,imagenr);
             comp=[comp simil];
             
         end
         
         % En este punto tenemos un vector con los valores de la
         % correlaci�n. Extraemos su m�ximo para identificar la nota.
         [vl n]=max(comp);
         % Como hemos iterado empezando en 2, nuestro �ndice n estar� una
         % posici�n desplazado con respecto a la figura correcta de la
         % tabla, asi que sumamos uno.
         nota_val=n+1;
         % Devolvemos la cadena de texto que identifica al tipo de nota.
         figura=tabla{nota_val,1};
      
     elseif tipo==2 && (strcmp(maximos{1,tipo}{2},'silencio de blanca') || strcmp(maximos{1,tipo}{2},'silencio de negra'))
         % Resulta que tambi�n tenemos una ambig�edad entre los silencios
         % de blanca y redonda.
         % En este caso vamos a diferenciar entre una y otra mirando su
         % posici�n con respecto a las l�neas del pentagrama.
         
         % Calculamos su proyecci�n horizontal
         inv=1-img;
         histh=sum(inv');
         % Buscamos todos los valores mayores que 0. Eso es, detectar�n
         % lineas y silencio.
         indices=find(histh>0);
         % Detectamos las l�neas y calculamos la distancia entre ellas
         lineas=find(histh==max(histh));
         dist=lineas(2)-lineas(1);
         
         % La idea es la siguiente, vamos a ir comparando las diferencias
         % entre los �ndices que hemos obtenido donde le histograma es
         % mayor que 0.
         % Vamos a calcular las diferencias en parejas.
         % Esas diferencias, esas distancias, las vamos a comparar con el
         % espacio entre l�neas.
         
         % Si encontramos una distancia menor que el espacio entre l�neas
         % (lo que nos indica que hay 'algo' en el hueco) y la siguiente
         % distancia es exactamente 1, tal y como estamos recorriendo el
         % vector, significar� que el silencio est� "hacia arriba", es
         % decir, ser� de blanca.
         % Si por contra la primera distancia corresponde exactamente con 1
         % y la segunda distancia es menor que el espacio entre l�neas,
         % significar� que la figura est� 'hacia abajo' y por tanto, ser� 
         % silencio de redonda.
         i=1;
         % Usamos una variable de control para parar la iteraci�n en caso
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

