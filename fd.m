function [fourier_descriptor] = fd(ccdc)
    %Input: ccdc
    %Uses first 64 fourier descriptors to calculate normalzied time series
    fourier_descriptor = fft(ccdc);
    fourier_descriptor = fourier_descriptor(1:64);
    fourier_descriptor = fourier_descriptor/fourier_descriptor(1);
    fourier_descriptor=abs(ifft(fourier_descriptor));
end

