%DOA Estimation for Uniform Circular Array
%Owner Ali Aqdas 

clc;clear all;close all;

p = 100;
fs = 10^11; 
fc = 4*10^9; 
M = 7;
N = 5; 
sVar = 1;


s = sqrt(sVar)*randn(N, p).*exp(1i*(2*pi*fc*repmat([1:p]/fs, N, 1)));
% myDFT(s(1,:),fs);

%%
doa = [20; 125; 230; 335; 60; 200];
cSpeed = 3*10^8;
wl = cSpeed/fc;

offset = 0;
r = wl*32 * 1.0 / (sqrt(2.0) * sqrt(1.0 - cos(2.0 * pi / M)));
x = r * cos(2 * pi / M * (1:M));
y = -r * sin(2 * pi / M * (1:M));

A = zeros(M, N);
for k = 1:N
    A(:, k) = exp((-1i*2*pi)*(x*(cos(deg2rad(doa(k))+offset)) + y*sin(deg2rad(doa(k)+offset))));
end

noiseCoeff = 5; 
W = A*s + sqrt(noiseCoeff)*randn(M, p);

atimess = (A*s);
for i=1:M
    SNR_W(i) = snr(atimess(i,:),sqrt(noiseCoeff)*randn(1, p));
end

%%
R = (W*W')/p; % Empirical covariance of the antenna data

%%
% STEP d: Finding the noise subspace and estimating the DOAs %%%%%%%%%%%%%

[V, D] = eig(R); %Returned in Ascending order
noiseSub = V(:, 1:M-N); % Noise subspace of R

theta = 0:1:360; %Peak search
a = zeros(M, length(theta));
res = zeros(length(theta), 1);

for i = 1:length(theta)
    a(:, i) =exp((-1i*2*pi)*(x*(cos(deg2rad(i)+offset)) + y*sin(deg2rad(i+offset))));
    res(i, 1) = 1/(norm(a(:, i)'*noiseSub).^2);
end
subplot(2,1,1); plot(res)
subplot(2,1,2); plot((res-mean(res))/(var(res)))
[pks,locs] = findpeaks(res,'MinPeakProminence',5);
DOAs = locs;
% STEP d: Finding the noise subspace and estimating the DOAs %%%%%%%%%%%%%