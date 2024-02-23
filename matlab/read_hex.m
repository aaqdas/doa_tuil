function [b] = read_hex(filename,word_length,fraction_length)
% filename = './dataset/covariance_matrix_real_hw.txt';
% FID = fopen(filename);
% dataFromfile = textscan(FID, '%s');% %s for reading string values (hexadecimal numbers)
% dataFromfile = dataFromfile{1};
% for i=1:length(dataFromfile)
%     decData(i) = hex2dec(cell2mat(dataFromfile(i)));
% end
% decData = decData';
% fclose(FID);

h = fopen(filename,'r');

nextline = '';
str='';
while ischar(nextline)
    nextline = fgetl(h);
    if ischar(nextline)
        str = [str;nextline];
    end
end
% b = fi([],1,57,36);
b = fi([],1,31,16);
b.hex = str ;
fclose(h);
end

