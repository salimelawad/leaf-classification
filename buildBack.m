function [output_matrix] = buildBack(fd)
    denom = 2/max(size(fd));
    multiplier = 300/max(max(fd));
    output_matrix = zeros(max(max(fd))*multiplier*2.5,max(max(fd))*multiplier*2.5);
    center_row = uint32(size(output_matrix,1)/2);
    center_col = uint32(size(output_matrix,2)/2);
    fd = double(fd*multiplier);
    angle = 0;

    for ii= 1:max(size(fd));
        oldangle = mod(angle-(pi*denom),2*pi);
        if (ii==1)
            [r,c] = bresenham(double(cos(oldangle)*fd(max(size(fd)))),double(sin(oldangle)*fd(max(size(fd)))),double(cos(angle)*fd(ii)),double(sin(angle)*fd(ii)));
        else
            [r,c] = bresenham(double(cos(oldangle)*fd(ii-1)),double(sin(oldangle)*fd(ii-1)),double(cos(angle)*fd(ii)),double(sin(angle)*fd(ii)));
        end
        for jj = 1:size(r,1)
            output_matrix(int32(r(jj))+int32(center_row)+1,int32(c(jj))+int32(center_col)+1) = 255;
        end
% 
%         row=center_row+fd(ii)*cos(angle);
%         col=center_col+fd(ii)*sin(angle);
% 
%         output_matrix(row,col) = 1.0;
         angle = angle + pi*denom;
        
    end
end