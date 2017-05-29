% [ kp,ep,kv,ev,ka,ea] = kpkvka( NUM,DEN,K,FACTOR)
% CALCULA LAS CONSTANTES DE ERROR ESTATICO KP KV KA DE UNA FUNCION G(s)=NUM/DEN
% EN LA FUNCION 200(s+1)/(s+2)(s+4) para 5u(t)
% K=200
% FACTOR=5

%(2017) adan.cisneros.lopez@gmail.com
function [ kp,ep,kv,ev,ka,ea] = kpkvka( NUM,DEN,K,FACTOR)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[NUM,DEN]=filternumden(NUM,DEN);
if ~exist('K','var'),K=1;end
if ~exist('FACTOR','var'),FACTOR=1;end
syms G(x) 
KG(x)=K*poly2sym(NUM)/poly2sym(DEN);
kp=limit(KG(x));
kv=limit(x*KG(x));
ka=limit(x*x*KG(x));
integrators=0;
for i=size(DEN,2):-1:1
    if DEN(1,i)==0,integrators=integrators+1;end
end

kp=double(kp);kv=double(kv);ka=double(ka);
if isnan(kp),
    kp=Inf;
    ep=0;
else
    ep=FACTOR/(1+kp);    
end
if isnan(kv),
    kv=Inf;
    ev=0;
else
    ev=FACTOR/kv;    
end
if isnan(ka),
    ka=Inf;
    ea=0;
else
    ea=FACTOR/ka;    
end
if nargout==3, %si solo hay dos argumentos 
switch integrators %kp kv
    case 0
        kv=0;
    case 1
        kp=kv;
        ep=ev;
        kv=1;
    case 2
        kp=ka;
        ep=ea;
        kv=2;
end
end
end

