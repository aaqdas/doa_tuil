function [azimuth, spectrum, rms_error] = doa_uca_sim(fc,timestamps,elements,inter_element_spacing,sources,desired_snr)
    % DOA Estimation for Uniform Circular Array
    %Owner Ali Aqdas 
    % --------------- INPUTS -------------------------------
    % fc -> center frequency
    % timestamps -> total number of samples per estimation
    % elements -> total number of sensing elements
    % sources -> total number of simulated sources
    % noiseCoeff -> noise variance which determines SNR
    % inter_element_spacing -> in meters
    % --------------- OUPUTS -------------------------------
    % azimuth -> estimate angle of arrivals in degrees
    % SNR -> estimated SNR of Received Signals based on noiseCoeff TODO:
    % Add SNR as Input and Remove NoiseCoeff
    % spectrum -> MUSIC Spectrum Output (Array)
    % rms_error -> root mean square error in the estimated angles
    
    %-------------------------------------------------------
    fs = 2*fc; 
    N = length(sources); 
    sVar = 1;
    offset = 0;
    cSpeed = 3*10^8;
    wl = cSpeed/fc;
%     inter_element_spacing = 0.6;
    s = sqrt(sVar)*randn(N, timestamps).*exp(1i*(2*pi*fc*repmat([1:timestamps]/fs, N, 1)));

    r = inter_element_spacing * 1.0 / (sqrt(2.0) * sqrt(1.0 - cos(2.0 * pi / elements)));
    x = r * cos(2 * pi / elements * (1:elements));
    y = -r * sin(2 * pi / elements * (1:elements));

    A = zeros(elements, N);
    for k = 1:N
        A(:, k) = exp((-1i*2*pi)*(x*(cos(deg2rad(sources(k))+offset)) + y*sin(deg2rad(sources(k)+offset))));
    end

    
    Hd = baseband_filter;

    %12-Bit FixPt
    word_length = 12;
    fraction_length = 8;
    
    for i = 1:elements
        signal = A*s;
        % Generate noisy signal using awgn
        W(i,:) = awgn(signal(i,:), desired_snr, 'measured','dB');
        %Unfiltered Baseband Sources
        W_bb_u(i,:) = W(i,:) .* exp(-1j*2*pi*fc*repmat([1:timestamps]/fs, 1, 1)); 
        %Low-Pass Filtered Baseband
        W_bb(i,:) = filter(Hd.Numerator,1,W_bb_u(i,:));
        %Quantized through ADC to 12-Bit Fixed Point
        W_bb_q_r(i,:) = fi(real(W_bb(i,:)), 1, word_length, fraction_length);
        W_bb_q_i(i,:) = fi(imag(W_bb(i,:)), 1, word_length, fraction_length);
        W_bb_q(i,:) = W_bb_q_r(i,:) + W_bb_q_i(i,:) *1j;        
    end 
%     W = A*s + sqrt(noiseCoeff)*randn(elements, timestamps);
%     atimess = (A*s);
%     for i=1:elements
%         SNR_W(i) = snr(atimess(i,:),sqrt(noiseCoeff)*randn(1, timestamps));
%     end
%     disp("Mean SNR",num2str(mean(SNR_W)));

    R = (W_bb_q*W_bb_q')/timestamps; % Empirical covariance of the antenna data
    %Converting Back to Double because Eigen-Decomposition doesn't work on
    %Fixed Point in MATLAB
    
    R = double(R);
    
    [V, D] = eig(R); %Returned in Ascending order
    noiseSub = V(:, 1:elements-N); % Noise subspace of R

    theta = 0:1:360; %Peak search
    a = zeros(elements, length(theta));
    res = zeros(length(theta), 1);

    for i = 1:length(theta)
        a(:, i) =exp((-1i*2*pi)*(x*(cos(deg2rad(i)+offset)) + y*sin(deg2rad(i+offset))));
        res(i, 1) = 1/(norm(a(:, i)'*noiseSub).^2);
    end

    [~,locs] = findpeaks(res,'MinPeakProminence',10);
    azimuth = locs;
    spectrum = res;
    max_length = max(length(azimuth), length(sources));
    % Pad the shorter array with zeros
    azimuth_p = padarray(sort(azimuth), [max_length - length(azimuth),0], 'post');
    truths_p = padarray(sort(sources)',[max_length - length(sources),0], 'post');

    rms_error = sqrt(mean((azimuth_p - truths_p).^2));
end

