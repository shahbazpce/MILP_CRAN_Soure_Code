R_bw = 100*10^6;
N_sc = R_bw/15000;
T_s = 1/(66.6*10^(-6));
N_bits = 15;
N_ant = 2;
sec = 3;

R = (N_sc*T_s*N_bits*N_ant*0.9*2)/10^9;
R_total = sec*R;

line_rate = 40;
E_S=(8*1500)/(line_rate*10^9);
C_T = 36.15;
total_traffic = 21.6;
P = total_traffic/line_rate;
Q_delay = E_S*(C_T/(2*(1-P)))*log(P/0.1);

for i=1:100
    a(i)=poissrnd(0.9)
end


