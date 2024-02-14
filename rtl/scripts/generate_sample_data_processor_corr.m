%DOA Estimation for Uniform Circular Array
%Owner Ali Aqdas 

clc; clear all; close all;

p = 128;
fs = 10^11; 
fc = 4*10^9; 
M = 7;
N = 4; 
sVar = 1;
offset = 0;

doa = sort([20; 125; 230; 60; 200; 280]);
cSpeed = 3*10^8;
wl = cSpeed/fc;
inter_element_spacing = 0.6;
noiseCoeff = 1; 

s = sqrt(sVar)*randn(N, p).*exp(1i*(2*pi*fc*repmat([1:p]/fs, N, 1))); %Random Sources Coming at Different Antennas with a Certain Center Frequency


r = inter_element_spacing * 1.0 / (sqrt(2.0) * sqrt(1.0 - cos(2.0 * pi / M)));
x = r * cos(2 * pi / M * (1:M));
y = -r * sin(2 * pi / M * (1:M));


A = zeros(M, N);
for k = 1:N
    A(:, k) = exp((-1i*2*pi)*(x*(cos(deg2rad(doa(k))+offset)) + y*sin(deg2rad(doa(k)+offset))));
end

for i = 1:M
    desired_snr = 5;
    signal = A*s;
    signal_power = rms(signal(i,:))^2;
    noise_power = signal_power / (10^(desired_snr/10));
    W(i,:) = awgn(signal(i,:), desired_snr, 'measured','dB');
end 


