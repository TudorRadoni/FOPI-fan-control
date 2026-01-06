function [Kp,Ti_Td,Alfa]=KCtuner_FOPI_FOPD(PM,Omeg,P,dP,FOPI);
% Robin De Keyser - 180217

C=1/cosd(PM); R=sqrt(C^2-1); Re=-C+R*cosd(90-PM); Im=-R*sind(90-PM); L=Re+j*Im; dL=-(Re+C)/Im;
FieP=angle(P)*180/pi; if FieP<0, FieP=FieP+360; end; FiePC=180+PM;
if FOPI==1, AlfaMin=(FieP-FiePC)/90; else AlfaMin=(FiePC-FieP)/90; end;

SlopeVek=[]; AlfaVek=[];
for Alfa=AlfaMin:0.01:1.99, 
    if FOPI==1, [Kp,Ti]=FOPIvalues(Alfa,Omeg,P,L); [C,dC]=FOPIslope(Kp,Ti,Alfa,Omeg); end;
    if FOPI==0, [Kp,Td]=FOPDvalues(Alfa,Omeg,P,L); [C,dC]=FOPDslope(Kp,Td,Alfa,Omeg); end;
    dPC=P*dC+C*dP; SlopeVek=[SlopeVek; imag(dPC)/real(dPC)];
    AlfaVek=[AlfaVek; Alfa];
end;

Err=abs((dL-SlopeVek)/dL); [MinValue,i]=min(Err); Alfa=AlfaVek(i);
if FOPI==1, [Kp,Ti]=FOPIvalues(Alfa,Omeg,P,L); Ti_Td=Ti; end;
if FOPI==0, [Kp,Td]=FOPDvalues(Alfa,Omeg,P,L); Ti_Td=Td; end;
end