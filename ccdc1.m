%Description: ccdc takes the input boundary image, and calculates the
%distance of each point on the boundary to the image's centroid, starting
%at the input starting point
%Input:= binary boundary image, starting coordinate row, starting
%coordinate column
%Output:= Centroid Contour Distance Curve

function [dists]=ccdc1(bw,bound,rstart,cstart)

%     bound=getBoundary(img);
    
    [rows,cols] = size(bw);
    
    %Find Closest point in the edge
    minDistance = Inf;
    r_min = 0;
    c_min = 0;
    for ii= 1:rows
        for jj = 1:cols
            if (bound(ii,jj) == 1)
                cur_distance = sqrt((ii-rstart)^2 + (jj-cstart)^2);
                if (cur_distance<minDistance)
                    r_min = ii;
                    c_min = jj;
                    minDistance = cur_distance;
                end
            end
        end
    end
    
    contour=bwtraceboundary(bound,[r_min, c_min],'N',8,Inf,'clockwise');
    
    if max(size(contour) == [0,0]) == 1
        display('ERROR, EMPTY BOUNDARY');
    end
    

    %getting centroid coordinate
    [center_row,center_col]=find_center(bw);


    %calculating distance between each border point and centroid
    dists=sqrt((contour(:,1)-center_row).^2+(contour(:,2)-center_col).^2);
    
    
end