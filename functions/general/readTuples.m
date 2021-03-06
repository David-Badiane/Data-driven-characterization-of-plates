function [fileData] = readTuples(filename, nVals, transpose)
%EXTRACTPASTTUPLES Summary of this function goes here
%   This function allows to retrieve a nVals*nCols matrix from a file
%   nCols depends from the length of the file, if the matrix
%   nRows*nVals is desired, apply transposed.
%   When you call it be sure to be in the same directory where 
%   the source file is present.
 file = fopen(filename,'rt');
 formatSpec = '%f';
 fileData = cell2mat(textscan(file,formatSpec));
 rows = nVals;
 cols = round(length(fileData)/rows);
 if isnan(cols) 
    fileData = zeros(nVals,1);
 else
    fileData = reshape(fileData,[rows, cols]);
 end
 fclose(file);
 if transpose 
     fileData = fileData';
 end
end

