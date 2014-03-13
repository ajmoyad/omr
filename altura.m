function [ alt_nota ] = altura( imagen_nota )
%ALTURA Calcula la altura de una nota dada en forma de imagen sobre su pentagrama
%
%   [ALT]=ALTURA(IMG) Calcula la altura de una nota recortada, con sus
%   correspondientes l�neas, del pentagrama almacenada en IMG. Devuelve una
%   cadena de texto con al nota que representa la altura: Do, re, etc...

%% Informaci�n
%   Autores
%       MOYA D�az, Antonio Jos�
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Im�genes
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
    % cabeza de la nota y las l�neas, no la plica. 
    % La plica se puede detectar como el valor m�s repetido dentro del
    % histograma, salvo por un defecto: el m�s repetido es el cero. 
    % Asi pues estimo los valores del histograma que son estrictamente mayores
    % que 0
    aux=histh(find(histh>0));

    % Sobre esos valores mayores que 0, ahora la plica de la nota SI es la moda
    offset=mode(double(aux(:)));
    % Y as� obtengo el histograma sin plica de la nota. Ahora, en el histograma
    % solo 'tengo' las l�neas y la cabeza de la nota
    histh=histh-offset;  
    
    % Obtengo la posici�n de las l�neas (estoy buscando calcular la altura de
    % la nota
    lineas=find(histh==max(histh));
    
    histh2=histh;
    histh2(lineas)=0;
    
    
    %% Paso 2: Parametrizaci�n del espacio en el pentagrama
    
    % Una vez aislada, en el histograma horizontal, la cabeza de la nota,
    % calculamos la media de su posici�n vertical. Ser�a algo as� como una
    % espece de centroide sencillo.
    % A partir de esta posici�n absoluta (basada en los �ndices)
    % obtendremos una posici�n relativa al pentagrama (basada en los
    % espacios y las l�neas del mismo) que, a posteriori, ser� la altura 
    % que buscamos.
    
    % Para obtener esa posici�n relativa, el primer paso ser� parametrizar
    % el espacio del pentagrama. �sto es, crear una regi�n en el pentagrama
    % para cada valor de la altura.
    % Dichas regiones deben ser lo suficientemente anchas como para
    % permitir cierta variaci�n -error- en la estimaci�n de la posici�n
    % absoluta de la nota. Es decir, no nos vale suponer que la nota caer�
    % justamente sobre la l�nea, ni justamente sobre la mediatriz entre 2
    % l�neas.

    % Calculamos el alto del pentagrama
    altura_pentagrama=lineas(end)-lineas(1);

    % Calculamos la separaci�n entre dos l�neas del pentagrama
    % Supongo en todo momento que son equidistantes
    dist_lineas=lineas(2)-lineas(1);

    % Creo un 'paso' que ser� el tama�o de la regi�n de cada valor de
    % altura
    paso=dist_lineas/2;
    % Igualmente, defino el tama�o medio del paso como 'semipaso'
    semipaso=dist_lineas/4;
    
    % Una vez tenemos la altura del pentagrama hemos de tener en cuenta que
    % una peque�a regi�n por encima de la �ltima l�nea del pentagrama y,
    % respectivamente, una peque�a regi�n por debajo de la primera l�nea del
    % pentagrama pertenecer�n a esa regi�n en la cual, si cae una nota,
    % consideraremos que se encuentra SOBRE la l�nea.
    % 
    % Como pretendemos calcular la altura total sobre la cu�l seremos
    % capaces de reconocer alturas, debemos a�adir la altura de esas dos 
    % peque�as regiones. Casualmente cada una de ellas ser� un semipaso,
    % por tanto, a la altura del pentagrama a�adimos 2 semipasos.
    altura_intervalos=altura_pentagrama+paso;

%    paso2=altura_intervalos/9; % Habr�, EN PRINCIPIO, 9 intervalos

    % Creamos un vector que contendr� los �ndices de los l�mites que
    % separar�n cada uno de los pasos o intervalos.
    intervalos=[0:paso:altura_intervalos]+lineas(1)-semipaso;

%    intervalos=intervalos+lineas(1)-semipaso;

    % Con esto tenemos l�mites necesarios para poder detectar con cierto
    % margen de error hasta las l�neas primera y �ltima del pentagrama.
    % Adem�s, deber�amos ser capaces de detectar notas que se encuentren
    % fuera del pentagrama, pero pegando a �ste, en el primer espacio
    % disponible para ello. Por tanto hemos de a�adir los l�mites m�s
    % Con esto los l�mites detectables son hasta las l�neas externas del
    % pentagrama, necesitamos, pues, dos intervalos m�s, para considerar las
    % notas que est�n fuera del pentagrama pero pegando a �ste.
    intervalos=[intervalos(1)-paso intervalos intervalos(end)+paso];

    % Invertimos el vector porque los indices en la imagen est�n al rev�s
    intervalos=fliplr(intervalos);
    
    % Notar que todav�a puede haber notas m�s separadas del pentagrama. Con
    % l�neas adicionales y dem�s. Sin embargo, si seguimos a�adiendo
    % espacios para su detecci�n podemos incurrir r�pidamente en un exceso
    % de los �ndices que nos llevar�a a un error en  tiempo de ejecuci�n.
    % Para controlarlo deber�amos empezar a poner una serie de diversas
    % condiciones para controlar toda la casu�stica posible. Sin embargo,
    % en gran parte por la falta de tiempo, vamos a simplificar la
    % detecci�n para el caso que tenemos entre manos.
    % As� pues solo vamos a definir intervalos, o espacios hasta para las
    % notas que, como se detall� anteriormente, van a estar fuera del
    % pentagrama pero peng�ndo a �ste -no sobre la l�nea-. Para el c�lculo
    % de la altura tendremos en cuenta �stos intervalos, a�adiendo un leve
    % caso adicional: en caso de que la nota est� fuera de los intervalos,
    % consideraremos que se trata, tanto por encima como por debajo, de una
    % nota que se halla sobre la primera l�nea adicional.

    %% Paso 3: Estimaci�n de la altura
    % Ahora, para localizar la nota, voy a borrar las l�neas... (en el
    % histograma)
    %histh2=histh;
    %histh2(lineas)=0;

    % Como ya aislamos la cabeza del histograma, anteriormente, no tenemos
    % m�s que localizar los valores de �sta en el histograma horizontal y
    % calcular su media. Eso nos dar� una posici�n vertical, absoluta a
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

