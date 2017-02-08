%Function getBoundary(img)
%Input:=Image array matrix obtained using imread()
%Output:=Boundary image matrix (binarized)
function boundary=getBoundary(bw)
   
    boundary=bwmorph(bw,'remove'); %Removes 
   
end