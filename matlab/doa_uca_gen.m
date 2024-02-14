% This File Generates the Results for Direction of Arrival in Uniform
% Circular Array using MUSIC Alogrithm
% Owner Ali Aqdas

clc; close all; clear all;
mc_steps = 100; %Number of Steps in MonteCarlo Simulation
timestamps = 64;
elements = 7;
num_sources  = 4;
inter_element_spacing = 0.6;

for desired_snr = 0:5:20
    fileName = sprintf('./logs/rms_sdr_flow/tstamps%d_el%d_sp%s_srcs%d_snr%d.csv', timestamps, elements, num2str(inter_element_spacing),num_sources,desired_snr);
    fptr = fopen(fileName,'w');    
    if fptr == -1
       disp('Could not Open File for Writing');
    end

    fprintf(fptr,'FC,Source Seperation,RMS Error\n');
    for fc = 4*10^9:500*10^6:6*10^9
        for sources_sep = [2 4 8 16 32]
            sources = 16:sources_sep:16+sources_sep*(num_sources-1);
            rms_error = 0;
            for mc_sim = 1:mc_steps
                [~, ~, rms_error_mc] = doa_uca_sim(fc,timestamps,elements,inter_element_spacing,sources,desired_snr);
                rms_error = rms_error + rms_error_mc;
            end
            rms_error = rms_error/mc_steps;
            fprintf(fptr,'%d,%d,%s \n',fc,sources_sep,num2str(rms_error));
%             disp(rms_error)
        end 
    end

    fclose(fptr);
end 