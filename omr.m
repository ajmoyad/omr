function [ partitura ] = omr( I )
%OMR Lee una partitura a partir de una imagen de partitura dada
%
%   [PARTITURA]=OMR(IMG) recibe una imagen IMG de una partitura completa y
%   devuelve en PARTITURA una cadena de texto donde se muestra de forma
%   secuencial y ligeramente organizada la interpretaci�n realizada de la
%   partitura contenida en IMG

%% Informaci�n
%   Autores
%       MOYA D�az, Antonio Jos�
%       PEREZ Bueno, Fernando
%
%   Procesamiento Digital de Im�genes
%   22 de junio de 2012

    partitura=[];
    recortadah=corte_horizontal(I);
    pentagramas=recon_pentagramas(recortadah);

    for i=1:length(pentagramas)
    
        compases=separar_compases(pentagramas{i});
	
        for j=1:length(compases)
    
            elementos=separar_elementos(compases{j});
		
            for z=1:length(elementos)
        
                elmt=elementos{z};
                datos=id_elemento(elmt);
                partitura= [partitura datos '; '];
        
            end
        end
    
        partitura=[partitura '\n'];
    end

    close(64)

end