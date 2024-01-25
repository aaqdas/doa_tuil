% This File Generates the Results for Direction of Arrival in Uniform
% Circular Array using MUSIC Alogrithm
% Owner Ali Aqdas

clc; close all; clear all;

timestamps = 100;
elements = 7;
num_sources  = 5;
for desired_snr = 0:5:20
    fileName = sprintf('./logs/rms/tstamps%d_el%d_srcs%d_snr%d.csv', timestamps, elements,num_sources,desired_snr);
    fptr = fopen(fileName,'w');    
    if fptr == -1
       disp('Could not Open File for Writing');
    end

    fprintf(fptr,'FC,Source Seperation,RMS Error\n');
    for fc = 4*10^9:500*10^6:6*10^9
        for sources_sep = [2 4 8 16 32]
            sources = 16:sources_sep:16+sources_sep*(num_sources-1);
            [azimuth, spectrum, rms_error] = doa_uca_sim(fc,timestamps,elements,sources,desired_snr);
            fprintf(fptr,'%d,%d,%s \n',fc,sources_sep,num2str(rms_error));
            disp(rms_error)
        end 
    end

    fclose(fptr);
end 