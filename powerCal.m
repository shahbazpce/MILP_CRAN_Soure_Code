clc;
clear all;
P_rec = -20.11;
P_uW = (10^(P_rec/10))*1000;
R_s = 0.9;
I_ph = R_s*P_uW;
% disp(P_rec);
% disp(I_ph);
I_d = 1*10^(-8);
q = 1.6*10^(-19);
k = 1.38 * 10^(-23);
M = 3;
T = 300;
B = 10^10;
I_s = (I_ph)*(M)*10^(-6);
I_n = sqrt(2*q*(I_ph*10^(-6) + I_d)*(M^(3))*B + (4*k*T*B)/50);
%disp(I_n);
SNR = 20*log10(I_s/I_n);

ebnodB = 11.60;
ebno = 10^(ebnodB/10);
BER_x = 0.5*erfc(sqrt(ebno/2));
disp (BER_x);



