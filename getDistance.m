%Function to get time warp distance metric
%input: contour distance curve of input image, contour distance curve to be
%compared
%output: Time Warp Distance Metric
function distance=getDistance(curve1,curve2)
    distance=dtw(curve1,curve2);
end