function [outputMatrix] = EuclieanDistCal(point1Cordinates,points2Cordinates)
point1Number=size(point1Cordinates,1);
point2Number=size(points2Cordinates,1);
 outputMatrix = zeros(point2Number,point1Number);
for loop1 = 1:point2Number
    for loop2 = 1:point1Number
        outputMatrix(loop1,loop2) ...
        = sqrt((point1Cordinates(loop2,1)-points2Cordinates(loop1,1))^2 + ...
        (point1Cordinates(loop2,2)-points2Cordinates(loop1,2))^2);
    end
end
end
