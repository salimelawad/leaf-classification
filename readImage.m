function [ current_image_matrix ] = readImage( location )
    current_image_matrix = imread(location);
    [rows,cols] = size(current_image_matrix);
    current_image_matrix = imresize(current_image_matrix,sqrt(500000/(rows*cols))); %rescale
    current_image_matrix=imbinarize(current_image_matrix);
    current_image_matrix = bwareaopen(current_image_matrix,10);
    current_image_matrix=imclose(current_image_matrix,strel('disk',3));
    current_image_matrix=imopen(current_image_matrix,strel('disk',3));       %Cleaning up noise in binarized image
    if current_image_matrix(1,1) == 1 %If inverted, fix color
        current_image_matrix = imcomplement(current_image_matrix);
    end
    current_image_matrix = padarray(current_image_matrix,20,0);
    current_image_matrix = imfill(current_image_matrix,'holes');
    
    current_image_matrix = bwlabel(current_image_matrix);
    number_of_regions = max(max(current_image_matrix));
    
    largest_region = 0;
    number_of_elements = 0;
    for ii = 1:number_of_regions
        cur_size = size(current_image_matrix(current_image_matrix == ii),1);
        if (cur_size > number_of_elements)
            largest_region = ii;
            number_of_elements = cur_size;
        end
    end
    current_image_matrix(current_image_matrix~=largest_region) = 0;
    current_image_matrix(current_image_matrix==largest_region) = 1;
end

