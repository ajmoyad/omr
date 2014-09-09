### OMR (Optical Music Recognition)

Reconocedor óptico de partituras realizado en el marco de la asignatura ‘Procesado Digital de Imágenes’, Ingeniería de Telecomunicaciones, 4º Curso, Universidad de Granada.

***

Se trata de un reconocedor de partituras simple que convierte la imagen reconocida a una cadena de texto. 

Es capaz de reconocer todas las figuras musicales (blanca, negra, corchea, etc), así como otras figuras comunes como pueden ser los compases o la clave. No es capaz de reconocer otros elementos como, por ejemplo, ligaduras.

El reconocimiento se realiza segmentando la imagen mediante histogramas horizontales y verticales para aislar la figura. Una vez aislada se compara mediante correlaciones bidimesionales con una base de datos de figuras (máscaras) y se estima su altura, nuevamente, usando histogramas.

La base de datos que se incluye es una estructura de MATLAB pensada para hacer escalable la inclusión de nuevas figuras a reconocer.

Como limitación adicional la imagen de partida debe estar correctamente alineada.

***

Autores:

* Antonio J. Moya Díaz - ajmoyad@gmail.com
* Fernando Pérez Bueno - ferztk@gmail.com


Fecha: 22 de Junio de 2012
