function []= main(n)
    %Input 0 to run use all images as training, 1 to exclude the test
    %images.
    t = 3;
    if (n==1)
        t = 4;
        display('Training with all but test images');
    else
        display('Training with all including test images');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %%%STORE TRAINING RESULT
    %%%%%%%%%%%%%%%%%%%%%%%%
    classEcc = []; %Each row represents ecc
    class_norm_TS = {}; %each corresponding cell holds the "ideal" time series for the class
    AngleHistogram = {}; %each corresponding cell holds the average Angle Histogram of the classes

    %OPEN FILES
    %Find all folders that contain grayscale images of leaves
    mkdir('Output');
    
    image_folders = dir('Downloads\grayscale');
    image_folders = image_folders(3:end); 
    
    %Loop through folders
    number_of_folders = size(image_folders,1);
    for ii = 1:number_of_folders
        current_folder = image_folders(ii).name;
        image_names = dir(strcat('Downloads\grayscale\',current_folder));
        image_names = image_names(t:end);
        
        
        mkdir(strcat('Output/',current_folder,'_Output'));
        
        average_class_fd = zeros(64,1);
        average_class_angle_code_hist = zeros(80,1);
        average_class_ecc = 0;
        min_class_ecc = 1;
        max_class_ecc = 0;
        display(strcat(current_folder));
        %loop through images
        number_of_images = size(image_names,1);
        for jj = 1:number_of_images
            current_image = image_names(jj).name;
            display(strcat('_____',current_image))
            %%%%% DO WORK FOR EACH IMAGE%%%%%%%
            %Read and clean image
            current_image_matrix=readImage(strcat('Downloads\grayscale\',current_folder,'/',current_image));
            
            %Boundary
            current_boundary = getBoundary(current_image_matrix);

            
            %Eccentricity
            current_ecc = getEcc(current_image_matrix);
            average_class_ecc = average_class_ecc + current_ecc;
            min_class_ecc = min(current_ecc,min_class_ecc);
            max_class_ecc = max(current_ecc,max_class_ecc);
            
            %Time Series
            [current_start_row,current_start_column] = getStartingPoint2(current_image_matrix);
            current_time_series = ccdc1(current_image_matrix,current_boundary,current_start_row,current_start_column);
            current_fourier_descriptor = fd(current_time_series);
            average_class_fd = average_class_fd + current_fourier_descriptor;
            
            %save iamges in output folder
            [center_row,center_col] = find_center(current_image_matrix);
            output_example = uint8(current_boundary*255);
            filler = zeros(size(output_example),'uint8');  % For the green and blue color planes
            output_example = cat(3,output_example,filler,filler);  % Make the RGB image
            output_example(uint16(center_row),uint16(center_col),2) = 255;
            output_example(uint16(current_start_row),uint16(current_start_column),3) = 255;
            imwrite(output_example,strcat('Output/',current_folder,'_Output/',current_image,'_Boundary.tif'));
            
            %Compute Angle Histogram
            [angles,bins]=angleCodeHistogram(current_boundary,20);
            average_class_angle_code_hist = average_class_angle_code_hist + bins.';
            
        end
        %Calculate averages of stats for all leafs in class
        average_class_angle_code_hist = average_class_angle_code_hist/number_of_images;
        AngleHistogram{ii} = average_class_angle_code_hist;
        average_class_fd = average_class_fd/number_of_images;
        class_norm_TS{ii} = average_class_fd;
        classEcc(ii)= average_class_ecc/number_of_images;
        p = plot(average_class_fd);
        saveas(p, strcat('Output/',current_folder,'_Output/Average_FD_',current_folder,'.tif'));
        imwrite(buildBack(average_class_fd), strcat('Output/',current_folder,'_Output/Rebuild_shape',current_folder,'.tif'));
    end

    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %TEST WITH SAMPLE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %List of all files to be tested
    list_of_files = {'Downloads\grayscale\ag1-ag10\ag1.tif', 'Downloads\grayscale\bg1-bg10\bg1.tif','Downloads\grayscale\cg1-cg10\cg1.tif', 'Downloads\grayscale\dg1-dg5\dg1.tif', 'Downloads\grayscale\gg1-gg3\gg1.tif', 'Downloads\grayscale\hg1-hg3\hg1.tif', 'Downloads\grayscale\ig1-ig3\ig1.tif', 'Downloads\grayscale\jg1-jg3\jg1.tif', 'Downloads\grayscale\kg1-kg3\kg1.tif', 'Downloads\grayscale\lg1-lg10\lg1.tif'};

    number_of_tests = max(size(list_of_files));
    
    %Eccentricity Test
    display('ECC TEST');
    correctness = 0;
    for ii = 1:number_of_tests
        ima = readImage(list_of_files{ii});
        bound = getBoundary(ima);
        ecc = getEcc(ima);
        [row,col] = getStartingPoint2(ima);
        ccdc = ccdc1(ima,bound,row,col);
        fd1 = fd(ccdc);
        
        %Find Match Based ONLY on ECC
        dif = abs(classEcc-ecc);
        [m,i] = min(dif);
        if(ii == i)
            correctness = correctness+ 10;
        end
        display(strcat('Based on eccentricity alone, element from class_',num2str(ii),' matched to class_',num2str(i)));
    end
    display(strcat({'Total correct is: '},num2str(correctness),'%'));
    
    %TWD test
    display('FD TEST');
    correctness=0;
    for ii = 1:number_of_tests
        ima = readImage(list_of_files{ii});
        bound = getBoundary(ima);
        ecc = getEcc(ima);
        [row,col] = getStartingPoint2(ima);
        ccdc = ccdc1(ima,bound,row,col);
        fd1 = fd(ccdc);
        
        %Find Match Based ONLY on FD
        distance = [];
        for jj = 1:number_of_tests
            distance = [distance getDistance(fd1,class_norm_TS{jj})];
        end
        [m,i] = min(distance);
        if(ii == i)
            correctness = correctness+ 10;
        end
        display(strcat('Based on fourier descriptors alone, element from class_',num2str(ii),' matched to class_',num2str(i)));
    end
    display(strcat({'Total correct is: '},num2str(correctness),'%'));
    
    %Angle Code Histogram test
    display('Angle Histogram Test');
    correctness= 0 ;
    for ii = 1:number_of_tests
        ima = readImage(list_of_files{ii});
        bound = getBoundary(ima);
        ecc = getEcc(ima);
        [row,col] = getStartingPoint2(ima);
        ccdc = ccdc1(ima,bound,row,col);
        fd1 = fd(ccdc);
        [angles,bins]=angleCodeHistogram(bound,20);
        bins = bins.';
        distance = [];
        for jj = 1:number_of_tests
            distance  = [distance sqrt(sum((AngleHistogram{jj} - bins) .^ 2))];
        end
        [m,i] = min(distance);
        if(ii == i)
            correctness = correctness+ 10;
        end
        display(strcat('Based on Angle Code Histogram, element from class_',num2str(ii),' matched to class_',num2str(i)));
    end
    display(strcat({'Total correct is: '},num2str(correctness),'%'));
    
    %Weighted Test
    display('Weighted Test');
    correctness= 0;
    for ii = 1:number_of_tests

        results = zeros(10,4); %test, angle code hist, %ecc, %twd
        results(:,1) = [1:10].';
        ima = readImage(list_of_files{ii});
        bound = getBoundary(ima);
        ecc = getEcc(ima);
        [row,col] = getStartingPoint2(ima);
        ccdc = ccdc1(ima,bound,row,col);
        fd1 = fd(ccdc);
        [angles,bins]=angleCodeHistogram(bound,20);
        bins = bins.';
        %calc distances
        for jj = 1:number_of_tests
            results(jj,2) = sqrt(sum((AngleHistogram{jj} - bins) .^ 2));
            results(jj,4) = getDistance(fd1,class_norm_TS{jj});
        end
        results(:,3) = abs(classEcc-ecc).';
        
        %calculate weight:
        results = sortrows(results,2);
        results(:,2) = 1:10;
        results = sortrows(results,3);
        results(:,3) = 1:10;
        results = sortrows(results,4);
        results(:,4) = 1:10;
        results = sortrows(results,1);
        total_sum=sum(results(:,2:4),2);
        [m,i] = min(total_sum);

        if(ii == i)
            correctness = correctness+ 10;
        end
        display(strcat('Based on Weighted test of all 3, element from class_',num2str(ii),' matched to class_',num2str(i)));
    end
    display(strcat({'Total correct is: '},num2str(correctness),'%'));
end

