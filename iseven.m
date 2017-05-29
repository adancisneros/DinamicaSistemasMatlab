function [ ANS ] = iseven(N)
%SOLO TRABAJA CON ESCALARES
%   Detailed explanation goes here

if N==0,error('0 es par o impar'),end;
n=mod(N,2);
if n==0
    ANS=true;
else
    ANS=false;
end

end

