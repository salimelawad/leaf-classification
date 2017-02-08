function [therow, thecol] = getStartingPoint2(bw)
%Input: binary image matrix
%Output: coordinate of starting point(leaf stem)

    se = strel('square',25);
    se2 = strel('square', 30);
    erosion = imerode(bw, se);
    noStem = imdilate(erosion,se2);
    stem = bw - noStem;

    [m,n] = find_center(bw);

    [row, col] = size(stem);
    minDist = sqrt((1-m).^2 + (1-n).^2);
    therow = 1;
    thecol = 1;
    for i=1:row
        for j=1:col
            if stem(i,j) == 1 && bw(i,j) == 1              
                dist = sqrt((i-m).^2 + (j-n).^2);
                if dist<minDist
                    minDist = dist;
                    therow=i;
                    thecol=j;
                end
            end
        end
    end

end

