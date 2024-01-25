%DOA Estimation for Uniform Circular Array
%Owner Ali Aqdas 

clc; clear all; close all;

p = 100;
fs = 10^11; 
fc = 6*10^9; 
M = 7;
N = 5; 
sVar = 1;
offset = 0;

doa = sort([20; 125; 230; 60; 200]);
cSpeed = 3*10^8;
wl = cSpeed/fc;
% inter_element_spacing = wl * 8
inter_element_spacing = 0.6;
noiseCoeff = 1; 

s = sqrt(sVar)*randn(N, p).*exp(1i*(2*pi*fc*repmat([1:p]/fs, N, 1)));

r = inter_element_spacing * 1.0 / (sqrt(2.0) * sqrt(1.0 - cos(2.0 * pi / M)));
x = r * cos(2 * pi / M * (1:M));
y = -r * sin(2 * pi / M * (1:M));


A = zeros(M, N);
for k = 1:N
    A(:, k) = exp((-1i*2*pi)*(x*(cos(deg2rad(doa(k))+offset)) + y*sin(deg2rad(doa(k)+offset))));
end

for i = 1:M
    
    desired_snr = 10;
    signal = A*s;
    signal_power = rms(signal(i,:))^2;
    noise_power = signal_power / (10^(desired_snr/10));
    % Generate noisy signal using awgn
    W(i,:) = awgn(signal(i,:), desired_snr, 'measured','dB');
end 
% W = A*s + sqrt(noiseCoeff)*randn(M, p);
% atimess = (A*s);
% for i=1:M
%     SNR_W(i) = snr(atimess(i,:),sqrt(noiseCoeff)*randn(1, p));
% end
% disp("Mean SNR =",num2str(mean(SNR_W)));

R = (W*W')/p; % Empirical covariance of the antenna data

[V, D] = eig(R); %Returned in Ascending order
noiseSub = V(:, 1:M-N); % Noise subspace of R

theta = 0:1:360; %Peak search
a = zeros(M, length(theta));
res = zeros(length(theta), 1);

for i = 1:length(theta)
    a(:, i) =exp((-1i*2*pi)*(x*(cos(deg2rad(i)+offset)) + y*sin(deg2rad(i+offset))));
    res(i, 1) = 1/(norm(a(:, i)'*noiseSub).^2);
end
subplot(2,1,1); plot(res); title("Original MUSIC Spectrum");
subplot(2,1,2); plot((res-mean(res))/(var(res))); title("Normalized MUSIC Spectrum");

[pks,locs] = findpeaks(res,'MinPeakProminence',50);
DOAs = locs;


% Find the maximum length
max_length = max(length(DOAs), length(doa));

% Pad the shorter array with zeros
azimuth = padarray(sort(DOAs), [max_length - length(DOAs),0], 'post');
truths = padarray(sort(doa(1:N)),[max_length - length(doa(1:N)),0], 'post');
rms_error = sqrt(mean((azimuth - truths).^2));



