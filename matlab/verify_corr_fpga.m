clc;clear all;close all;

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

%Matlab Data
s_corr_r = read_hex('.\dataset\covariance_matrix_real_hw.txt');
% m_corr_r = fi(m_corr_r, 1, 12,8);
s_corr_i = read_hex('.\dataset\covariance_matrix_imag_hw.txt');
% m_corr_i = fi(m_corr_i, 1, 12,8);
s_corr_arr_utri = s_corr_r + 1j* s_corr_i;
rem_ct = 0;
col_inc = 1;
row_inc = 0;
o_i = 1;
% s_corr_arr = [];
for i = 1:length(s_corr_arr_utri)
      if(rem(o_i-1,M) ==  0 || i == 1)
          if (i ~= 1) 
              row_inc = 0;
              rem_ct_tracker = rem_ct;
              while(rem_ct_tracker ~= 0)
                s_corr_arr_append(rem_ct - rem_ct_tracker + 1) = s_corr_arr_utri(1+col_inc+row_inc)';
                rem_ct_tracker = rem_ct_tracker - 1;
                row_inc = M-(rem_ct-rem_ct_tracker) + row_inc;
              end
              col_inc = col_inc + 1;
              s_corr_arr = horzcat(s_corr_arr,s_corr_arr_append);
              o_i = o_i + rem_ct;
              rem_ct = rem_ct + 1;
          else
%               s_corr_arr(o_i) = s_corr_arr_utri(i);
%               o_i = o_i + 1;
              rem_ct = rem_ct + 1;
          end
      end
          s_corr_arr(o_i) = s_corr_arr_utri(i);
          o_i = o_i + 1;
end

 s_corr = transpose(reshape(s_corr_arr,8,8));
 s_corr = double(s_corr);
%% 
%Matlab Data
m_corr_r = read_hex('.\dataset\covariance_matrix_real.txt');
% m_corr_r = fi(m_corr_r, 1, 12,8);
m_corr_i = read_hex('.\dataset\covariance_matrix_imag.txt');
% m_corr_i = fi(m_corr_i, 1, 12,8);
m_corr_arr = m_corr_r + 1j * m_corr_i;
m_corr = transpose(reshape(m_corr_arr,8,8));
m_corr = double(m_corr);
%%
r = inter_element_spacing * 1.0 / (sqrt(2.0) * sqrt(1.0 - cos(2.0 * pi / M)));
x = r * cos(2 * pi / M * (1:M));
y = -r * sin(2 * pi / M * (1:M));


[V, D] = eig(s_corr);     %Returned in Ascending order
% N_Est = numSources(m_corr);        
noiseSub = V(:, 1:M-2);         % Noise subspace of R

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

%Testbench Simulation Data
% corr_r = read_hex('.\dataset\covariance_matrix_imag_hw.txt');
% corr_i = read_hex('.\dataset\covariance_matrix_imag_hw.txt');
% corr = double(corr_r) + 1j* (double(corr_i));
