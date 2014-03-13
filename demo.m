%% Archivo de demostraci�n del proyecto OMR
%   Autores
%       MOYA D�az, Antonio Jos�
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Im�genes
%   22 de junio de 2012

clc,close all

%% Cargado de la partitura

% Cargo la imagen con la que deseo trabajar
imagen= imread('imagenes/canon.gif');
% imagen= imread('imagenes/mibarba.gif');
% imagen= imread('imagenes/cumple.jpg');

%Muestro la partitura completa
figure(1),imshow(double(imagen))


%% Ejecuci�n normal del programa
% A continuaci�n se muestra lo que ser�a la ejecuci�n normal del programa.
% De forma completamente trasparente para el usuario. 
% Solo se mostrar�n unas im�genes momentaneamente mientras el proceso se
% est� ejecutando que se cerrar�n al t�rmino del mismo.
% El resultado ser� una cadena de texto almacenada en la variable de
% salida.
partitura=omr(imagen);

%Muestro el resultado obtenido
fprintf(partitura);


%% Detalle del proceso
% A continuaci�n se muestra una ejecuci�n con cada uno de los pasos que se
% suceden para la ejecuci�n completa del programa. Se muestran los pasos
% intermedios m�s interesantes y necesarios para la consecuci�n del
% objetivo de la lectura de la partitura.

%segmentaci�n vertical (funcion corte_horizontal)

recortadah=corte_horizontal(imagen);
figure(2),
for z=1:length(recortadah)
    subplot(length(recortadah),1,z),imshow(recortadah{z})
    if z==1
        title('partitura separada');
    end
end

clear z;

%Es necesario filtrar para utilizar solo los pentagramas
pentagramas=recon_pentagramas(recortadah);

%Para mostrar un ejemplo, separamos los compases del primer pentagrama
compases=separar_compases(pentagramas{1});
figure(3)
for z=1:length(compases)
    subplot(1,length(compases),z),imshow(compases{z}),
    if z==2
         title('compases del primer pentagrama');
    end
end
clear z;

%una vez tenemos los compases, debemos separar los elementos de cada uno
%para mostrar un ejemplo, separamos todos los elementos del primer compas
elementos=separar_elementos(compases{1});


figure(4)
for z=1:length(elementos)
    subplot(1,length(elementos),z),imshow(elementos{z});
    if z==3
        title('elementos del primer compas');
    end
end
clear z;

%El siguiente paso es trabajar sobre cada elemento para identificarlo, la
%funcion id_elemento se encarga de llamar a la funcion figura_musical que
%identificara el tipo de figura y en caso de ser necesario a la funcion
%altura que se encargara de calcular la nota correspondiente, para mostrar
%el ejemplo, llamaremos por separado a versiones modificadas de las
%funciones que muestran imagenes del proceso.

nota=elementos{5};
figura=figura_musical_demo(nota)
altura_nota=altura_demo(nota)

%Este proceso es el que se repite a lo largo de toda la partitura para
%obtener el proceso completo