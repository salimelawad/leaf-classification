%Function getEcc(img)
%Input:=Image Matrix
%Output:=Eccentricity of "bounding" circle around image object

function [ecc]=getEcc(bw)
    
    %Cleaning up Binarized Image
    bw=imopen(bw,strel('square',5));
    bw=imclose(bw,strel('square',5)); 
    
    %Getting Circle Properties of Leaf
    s=regionprops(bw,'centroid','MajorAxisLength','MinorAxisLength','Eccentricity','Orientation');
    centroids=cat(1,s.Centroid);
    centers=s.Centroid;
    diameters=mean([s.MajorAxisLength s.MinorAxisLength],2);
	%Returning Eccentricity
    ecc=s.Eccentricity;
    
end