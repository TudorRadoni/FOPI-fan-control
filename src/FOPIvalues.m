function [Kp,Ti]=FOPIvalues(Alfa,Omega,P,L);
Complex=L/P; a=real(Complex); b=imag(Complex);
Ti=-((a/b)*sin(Alfa*pi/2)+cos(Alfa*pi/2))/(Omega^Alfa);
Kp=-(b*Ti*(Omega^Alfa))/sin(Alfa*pi/2);