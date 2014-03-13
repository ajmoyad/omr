function [ alt_nota ] = altura( imagen_nota )
%ALTURA Calcula la altura de una nota dada en forma de imagen sobre su pentagrama
%
%   [ALT]=ALTURA(IMG) Calcula la altura de una nota recortada, con sus
%   correspondientes líneas, del pentagrama almacenada en IMG. Devuelve una
%   cadena de texto con al nota que representa la altura: Do, re, etc...

%% Información
%   Autores
%       MOYA Díaz, Antonio José
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Imágenes
%   22 de junio de 2012

    
    %% Paso 1: Aislar el histograma horizontal de la cabeza de la nota
    % invertimos... blablabla
    inv=1-imagen_nota;

    % Proyecciones...
    histv=sum(inv);
    histh=sum(inv');

%     figure(131)
%     subplot(2,2,1),barh(fliplr(histh));
%     set(gca,'Ylim',[0 size(inv,1)])
%     subplot(2,2,2),imshow(nota1);
%     subplot(2,2,4),bar(histv);
%     set(gca,'Xlim',[0 size(inv,2)]) 

   % pause

    % Vamos a ver, lo que quiero es que en el histograma 'me quede' solo la
    % cabeza de la nota y las líneas, no la plica. 
    % La plica se puede detectar como el valor más repetido dentro del
    % histograma, salvo por un defecto: el más repetido es el cero. 
    % Asi pues estimo los valores del histograma que son estrictamente mayores
    % que 0
    aux=histh(find(histh>0));

    % Sobre esos valores mayores que 0, ahora la plica de la nota SI es la moda
    offset=mode(double(aux(:)));
    % Y así obtengo el histograma sin plica de la nota. Ahora, en el histograma
    % solo 'tengo' las líneas y la cabeza de la nota
    histh=histh-offset;  
    
    % Obtengo la posición de las líneas (estoy buscando calcular la altura de
    % la nota
    lineas=find(histh==max(histh));
    
    histh2=histh;
    histh2(lineas)=0;
    
    
    %% Paso 2: Parametrización del espacio en el pentagrama
    
    % Una vez aislada, en el histograma horizontal, la cabeza de la nota,
    % calculamos la media de su posición vertical. Sería algo así como una
    % espece de centroide sencillo.
    % A partir de esta posición absoluta (basada en los índices)
    % obtendremos una posición relativa al pentagrama (basada en los
    % espacios y las líneas del mismo) que, a posteriori, será la altura 
    % que buscamos.
    
    % Para obtener esa posición relativa, el primer paso será parametrizar
    % el espacio del pentagrama. Ésto es, crear una región en el pentagrama
    % para cada valor de la altura.
    % Dichas regiones deben ser lo suficientemente anchas como para
    % permitir cierta variación -error- en la estimación de la posición
    % absoluta de la nota. Es decir, no nos vale suponer que la nota caerá
    % justamente sobre la línea, ni justamente sobre la mediatriz entre 2
    % líneas.

    % Calculamos el alto del pentagrama
    altura_pentagrama=lineas(end)-lineas(1);

    % Calculamos la separación entre dos líneas del pentagrama
    % Supongo en todo momento que son equidistantes
    dist_lineas=lineas(2)-lineas(1);

    % Creo un 'paso' que será el tamaño de la región de cada valor de
    % altura
    paso=dist_lineas/2;
    % Igualmente, defino el tamaño medio del paso como 'semipaso'
    semipaso=dist_lineas/4;
    
    % Una vez tenemos la altura del pentagrama hemos de tener en cuenta que
    % una pequeña región por encima de la última línea del pentagrama y,
    % respectivamente, una pequeña región por debajo de la primera línea del
    % pentagrama pertenecerán a esa región en la cual, si cae una nota,
    % consideraremos que se encuentra SOBRE la línea.
    % 
    % Como pretendemos calcular la altura total sobre la cuál seremos
    % capaces de reconocer alturas, debemos añadir la altura de esas dos 
    % pequeñas regiones. Casualmente cada una de ellas será un semipaso,
    % por tanto, a la altura del pentagrama añadimos 2 semipasos.
    altura_intervalos=altura_pentagrama+paso;

%    paso2=altura_intervalos/9; % Habrá, EN PRINCIPIO, 9 intervalos

    % Creamos un vector que contendrá los índices de los límites que
    % separarán cada uno de los pasos o intervalos.
    intervalos=[0:paso:altura_intervalos]+lineas(1)-semipaso;

%    intervalos=intervalos+lineas(1)-semipaso;

    % Con esto tenemos límites necesarios para poder detectar con cierto
    % margen de error hasta las líneas primera y última del pentagrama.
    % Además, deberíamos ser capaces de detectar notas que se encuentren
    % fuera del pentagrama, pero pegando a éste, en el primer espacio
    % disponible para ello. Por tanto hemos de añadir los límites más
    % Con esto los límites detectables son hasta las líneas externas del
    % pentagrama, necesitamos, pues, dos intervalos más, para considerar las
    % notas que están fuera del pentagrama pero pegando a éste.
    intervalos=[intervalos(1)-paso intervalos intervalos(end)+paso];

    % Invertimos el vector porque los indices en la imagen están al revés
    intervalos=fliplr(intervalos);
    
    % Notar que todavía puede haber notas más separadas del pentagrama. Con
    % líneas adicionales y demás. Sin embargo, si seguimos añadiendo
    % espacios para su detección podemos incurrir rápidamente en un exceso
    % de los índices que nos llevaría a un error en  tiempo de ejecución.
    % Para controlarlo deberíamos empezar a poner una serie de diversas
    % condiciones para controlar toda la casuística posible. Sin embargo,
    % en gran parte por la falta de tiempo, vamos a simplificar la
    % detección para el caso que tenemos entre manos.
    % Así pues solo vamos a definir intervalos, o espacios hasta para las
    % notas que, como se detalló anteriormente, van a estar fuera del
    % pentagrama pero pengándo a éste -no sobre la línea-. Para el cálculo
    % de la altura tendremos en cuenta éstos intervalos, añadiendo un leve
    % caso adicional: en caso de que la nota esté fuera de los intervalos,
    % consideraremos que se trata, tanto por encima como por debajo, de una
    % nota que se halla sobre la primera línea adicional.

    %% Paso 3: Estimación de la altura
    % Ahora, para localizar la nota, voy a borrar las líneas... (en el
    % histograma)
    %histh2=histh;
    %histh2(lineas)=0;

    % Como ya aislamos la cabeza del histograma, anteriormente, no tenemos
    % más que localizar los valores de ésta en el histograma horizontal y
    % calcular su media. Eso nos dará una posición vertical, absoluta a
    % toda la imagen.
    vals_nota=find(histh2>0);
    pos_nota=mean(vals_nota);
    

    ind=0;
    if pos_nota>intervalos(1)
        ind=1;
    end
    if pos_nota<intervalos(end)
        ind=13;
    end
    if ind==0
        maxit=length(intervalos);
        for i=1:maxit-1
            if intervalos(i)>pos_nota && pos_nota>intervalos(i+1)
                ind=i+1;
            end
        end
    end
    
    load('escala.mat');
%ind
    alt_nota=escala{ind};
    
    

end

