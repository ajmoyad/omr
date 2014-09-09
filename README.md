### OMR (Optical Music Recognition)

Optical music recognition tool implemented for the course 'Digital Image Processing', Telecommunications Engineering, 4th year, Universidad de Granada (España).

***

This is a simple music recognition tool which turns the recognized image into a string.

It is able to recognize most of the note values (Minim, crotchet, quaver, etc) as well as other common figures such as time signature and clef. It isn't able to recognize other elements such as ties or slurs.

The recognition is made by dividing the image using vertical and horizontal histograms in order to isolate the note. Once isolated, the note is compared with a figure (mask) database using two dimensional correlations. Then, the value is estimated with histograms.

The included database is a MATLAB structure thought to be easily scaleable by simply adding new figures to recognize.

A limiting rule is that the starting image needs to be properly (horizontally) aligned.

***

Authors:

* Antonio J. Moya Díaz - ajmoyad@gmail.com
* Fernando Pérez Bueno - ferztk@gmail.com

Date: 22nd of June 2012