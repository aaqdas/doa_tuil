%DOA Estimation for Uniform Circular Array
%Owner Ali Aqdas 

clc; clear all; close all;

% p = 8192*4; % For Verifying Demodulation
p = 64;
fs = 10^11; 
fc = 4*10^9; 
sFreq = 22*10^6;
M = 8;
N = 2; 
sVar = 1;
offset = 0;

doa = sort([20; 50; 230; 160; 200; 280]);
cSpeed = 3*10^8;
wl = cSpeed/fc;
% inter_element_spacing = wl * 8
inter_element_spacing = 0.6;
noiseCoeff = 1; 
% bb_s = cos(2*pi*sFreq*repmat([1:p]/fs, N, 1));
% s = bb_s.*exp(1i*(2*pi*fc*repmat([1:p]/fs, N, 1))); %Random Sources Coming at Different Antennas with a Certain Center Frequency

s = sqrt(sVar)*randn(N, p).*exp(1i*(2*pi*fc*repmat([1:p]/fs, N, 1))); %Random Sources Coming at Different Antennas with a Certain Center Frequency

r = inter_element_spacing * 1.0 / (sqrt(2.0) * sqrt(1.0 - cos(2.0 * pi / M)));
x = r * cos(2 * pi / M * (1:M));
y = -r * sin(2 * pi / M * (1:M));


A = zeros(M, N);
for k = 1:N
    A(:, k) = exp((-1i*2*pi)*(x*(cos(deg2rad(doa(k))+offset)) + y*sin(deg2rad(doa(k)+offset))));
end


Hd = baseband_filter;

%12-Bit FixPt
word_length = 12;
fraction_length = 8;

for i = 1:M    
    desired_snr = 5;
    signal = A*s;
    signal_power = rms(signal(i,:))^2;
    noise_power = signal_power / (10^(desired_snr/10));
    % Generate noisy signal using awgn
    W(i,:) = awgn(signal(i,:), desired_snr, 'measured','dB');
   
    W_bb_u(i,:) = W(i,:) .* exp(-1j*2*pi*fc*repmat([1:p]/fs, 1, 1)); %Unfiltered baseband
    W_bb(i,:) = filter(Hd.Numerator,1,W_bb_u(i,:));
   
    W_bb_q_r(i,:) = fi(real(W_bb(i,:)), 1, word_length, fraction_length);
    W_bb_q_i(i,:) = fi(imag(W_bb(i,:)), 1, word_length, fraction_length);
    
    W_bb_q(i,:) = W_bb_q_r(i,:) + W_bb_q_i(i,:) *1j;

end
% R_org = (W*W')/p;

fileID = fopen('./dataset/baseband_source_real.txt','w');
for m = 1:length(W_bb_q_r(:,1))
    for k = 1:length(W_bb_q_r)
        fprintf(fileID,'%s\n', hex(W_bb_q_r(m,k)));
    end
end
fclose(fileID);
fileID = fopen('./dataset/baseband_source_imag.txt','w');
for m = 1:length(W_bb_q_i(:,1))
    for k = 1:length(W_bb_q_i)
        fprintf(fileID,'%s\n', hex(W_bb_q_i(m,k)));
    end
end
fclose(fileID);

R = (W_bb_q*W_bb_q')/p;             % Empirical covariance of the antenna data

fileID = fopen('./dataset/covariance_matrix_real.txt','w');
for m = 1:length(R)
    for k = 1:length(R)
        fprintf(fileID,'%s\n', hex(real(R(m,k))));
    end
end
fclose(fileID);
fileID = fopen('./dataset/covariance_matrix_imag.txt','w');
for m = 1:length(R)
    for k = 1:length(R)
        fprintf(fileID,'%s\n', hex(imag(R(m,k))));
    end
end
fclose(fileID);
%%
R = double(R);



N_Est = numSources(R);

[V, D] = eig(R);                    %Returned in Ascending order
noiseSub = V(:, 1:M-N_Est);         % Noise subspace of R

theta = 0:1:360;                    %Peak search
a = zeros(M, length(theta));
res = zeros(length(theta), 1);

for i = 1:length(theta)
    a(:, i) =exp((-1i*2*pi)*(x*(cos(deg2rad(i)+offset)) + y*sin(deg2rad(i+offset))));
    res(i, 1) = 1/(norm(a(:, i)'*noiseSub).^2);
end
figure();
subplot(2,1,1); semilogy(res); title("Original MUSIC Spectrum (dB)");
subplot(2,1,2); plot(res); title("Original MUSIC Spectrum");
[pks,locs] = findpeaks(res,'MinPeakProminence',5);
DOAs_lin = locs;
% [pks,locs] = findpeaks(10*log(res),'MinPeakProminence',10);
% DOAs_log = locs;    


%%
% Find the maximum length
% max_length = max(length(DOAs_log), length(doa));
% 
% % Pad the shorter array with zeros
% azimuth = padarray(sort(DOAs_log), [max_length - length(DOAs_log),0], 'post');
% truths = padarray(sort(doa(1:N)),[max_length - length(doa(1:N)),0], 'post');
% rms_error = sqrt(mean((azimuth - truths).^2))
% 

%% 

