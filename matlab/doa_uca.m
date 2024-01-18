%DOA Estimation for Uniform Circular Array
%Owner Ali Aqdas 


clc;clear all;close all;

p = 100;
fs = 10^7; 
fc = 10^6; 
M = 9;
N = 5; 
sVar = 1;

s = sqrt(sVar)*randn(N, p).*exp(1i*(2*pi*fc*repmat([1:p]/fs, N, 1)));


%%
doa = [20; 50; 85; 110; 145];
cSpeed = 3*10^8;
wl = cSpeed/fc;
r = 214.859;

A = zeros(M, N);
for k = 1:N
    A(:, k) = exp(-1i*2*pi*r/wl*cos(deg2rad(doa(k))-(2*pi.*(0:(M-1))./M))); 
end

noiseCoeff = 1; 
x = A*s + sqrt(noiseCoeff)*randn(M, p);

%%
R = (x*x')/p; % Empirical covariance of the antenna data

%%

% STEP d: Finding the noise subspace and estimating the DOAs %%%%%%%%%%%%%
[V, D] = eig(R); %Returned in Ascending order
noiseSub = V(:, 1:M-N); % Noise subspace of R

theta = 0:1:360; %Peak search
a = zeros(M, length(theta));
res = zeros(length(theta), 1);
for i = 1:length(theta)
    a(:, i) = exp(-1i*2*pi*r/wl*cos(deg2rad(i)-(2*pi.*(0:(M-1))./M)));
    res(i, 1) = 1/(norm(a(:, i)'*noiseSub).^2);
end
plot(res)
[pks,locs] = findpeaks(res,'MinPeakProminence',5);
DOAs = locs;
% STEP d: Finding the noise subspace and estimating the DOAs %%%%%%%%%%%%%