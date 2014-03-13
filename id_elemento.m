function [ datos ] = id_elemento( elemento )
%ID_ELEMENTO Identifica el tipo de elemento de un pentagrama
%
%   [DATA]=ID_ELEMENTO(ELMENTO) Recibe un recorte de un pentagrama con un
%   elemento aislado y reconoce el tipo de elemento que es, devolviéndolo
%   como una cadena de texto.

%% Información
%   Autores
%       MOYA Díaz, Antonio José
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Imágenes
%   22 de junio de 2012

%% Identificaicón del elemento
    
    % En primer lugar se realiza una llamada a la función figura_musical
    % que nos dirá el tipo de figura musical que se trata.
    [fig,tipo]=figura_musical(elemento);
    %datos=fig;
    
    datos=[];
    % En el caso de que se trate de una nota, lanzamos la función altura
    % para calcular la altura de la misma.
    if tipo==1                       
        altu=altura(elemento);
        datos=[fig ' ' altu];
    else
        datos=fig;
    end
        
 figure(64),imshow(elemento),title('leyendo...'),pause(0.1)
end
