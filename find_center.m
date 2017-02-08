function [ r_center,c_center ] = find_center( bw )
    %Finds center of binary image
    [rows,cols] = size(bw);
    
    total_r = 0;
    total_c = 0;
    for ii = 1:rows
        for jj = 1:cols
            if (bw(ii,jj) == 1)
                total_r = total_r + ii;
                total_c = total_c + jj;
            end
        end
    end
    
    r_center = total_r/sum(sum(bw));
    c_center = total_c/sum(sum(bw));


end

