function [C,dC]=FOPIslope(Kp,Ti,Alfa,Omega);
C=Kp*(1+1/(Ti*(j*Omega)^Alfa));
Omega1=0.99*Omega; C1=Kp*(1+1/(Ti*(j*Omega1)^Alfa));
Omega2=1.01*Omega; C2=Kp*(1+1/(Ti*(j*Omega2)^Alfa));
dC=(C2-C1)/(Omega2-Omega1);