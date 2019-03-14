clear; clc; close all;

N = 1000000;
Nn = 100000;

[x, fs] = audioread('audio.wav');
x = x(1:N, 1)';

x = [zeros(1, Nn), x];     

%Adding uniformly distributed white noise
y = x + 0.1*(rand(size(x)));   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1. Computing Power spectral density of noise

window_len = 800; 
window_number = round(Nn/window_len);
Sz = zeros(1, window_len/2);

for i=0:window_number
    if i==0
        s1_fft = abs(fft(y(1:window_len)));
        s1_fft = s1_fft(1:window_len/2);
        s1_fft = s1_fft.*s1_fft;
        Sz1 = s1_fft/window_len;
    else
        s1_fft = abs(fft(y(i*window_len:(i+1)*window_len)));
        s1_fft = s1_fft(1:window_len/2);
        s1_fft = s1_fft.*s1_fft;
        Sz1 = s1_fft/window_len;
    end
    Sz = Sz + Sz1;
end    

Sz = Sz / window_number;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Denoise algorithm


window_len = 800;
window_number = round((N+Nn)/window_len);
X = zeros(1, N);

for j=1:window_number-1
    %2.
    if j==1
        y_okno = y(1:window_len);
    else
        y_okno = y((window_len*j):(window_len*(j+1))-1);
    end
    
    y_fft = abs(fft(y_okno));
    y_fft = y_fft(1:window_len/2);
    y_fft = y_fft.*y_fft;
    Sy = y_fft/window_len;

    %3.
    Sx = Sy - 5*Sz;
    Sx(Sx < 0) = 0; 

    %4. 
    A1 = sqrt(Sx./Sy);
    A = [A1 , fliplr(A1)];

    %5.
    Yw = fft(y_okno);
    Xw = A.*Yw;
    xk = ifft(Xw);
    xk = real(xk);
    
    if j==1
        X(1:window_len) = xk;
    else
        X((window_len*j):(window_len*(j+1))-1) = xk;  
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Windowing denoised signal to obtain better results
window_len = 800;
window_number = round((N+Nn)/window_len);
triang_window = triang(window_len);
triang_window = triang_window';
jump = 0.5;

x_final = zeros(1, N+Nn);

for j=1:jump:window_number
    if j==1
        x_final(1:window_len) = triang_window.*X(1:window_len);
    else
        temp = triang_window.*X(window_len*(j-1):window_len*(j)-1);
        x_final(window_len*(j-1):window_len*(j)-1) = x_final(window_len*(j-1):window_len*(j)-1) + temp;
    end
end

noised_audio = audioplayer(y, fs);
denoised_audio = audioplayer(x_final, fs);

audiowrite('denoised_audio.wav', x_final, fs);
audiowrite('noised_audio.wav', y, fs);
