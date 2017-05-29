% HALLA EL PUNTO DE PRUEBA DONDE EL ROOT LOCUS DE UNA FUNCION G(s)=NUM/DEN
% CORTA CON LA PENDIENTE FORMADA POR EL FACTOR DE AMORTIGUAMIENTO z EN EL
% PLANO S
% [x,y,e]=damping(NUM,DEN,z,percentage_error,start)
% PARAMETROS DE ENTRADA
% NUM,DEN : sistema que se evalua
% z :damping factor, factor de amortiguamiento
% percentage_error : error de porcentaje dentro del cual puede estar el punto de prueba
% start : desde que punto en el eje real iniciara a buscar el punto de prueba (lo toma como
% valor absoluto, la direccion es establecida por el signo de z)
% SI SOLO SE ESPECIFICAN 4 PARAMETROS DE ENTRADA, start=1
% SI SOLO SE ESPECIFICAN 3 PARAMETROS DE ENTRADA, start=1 percentage_error=0.0001
% PARAMETROS DE SALIDA
% x,y : ubicacion en el plano S del punto de prueba
% e : porcentaje de error con el que fue encontrado el punto de prueba

%(2017) adan.cisneros.lopez@gmail.com
function [x,y,e]=damping(NUM,DEN,z,percentage_error,start)
[NUM,DEN]=filternumden(NUM,DEN);
if nargin==4,start=1;end
if nargin==3,
    percentage_error=.0001;
    start=1;
end

syms G(s) %si la variable ya esta creada ahorro segundos
G(s)=poly2sym(NUM,s)/poly2sym(DEN,s);

x=abs(start);
mul=0;
direction_f=false;%false if for descending true for ascending error
e=100;
last_e=200;
[op]=rightDirection(x,z,NUM,DEN);

while e>percentage_error
   if z>0, 
     y=x*tan(acos(z));
     testpoint=complex(-x,y);
     t=angle(double(G(testpoint)));     
   else
     y=x*tan(-acos(z));
     testpoint=complex(x,y);
     t=angle(double(G(testpoint)));         
   end
   if t<0,t=2*pi+t;end
    e=abs(pi-abs(t))*100/pi;
    
    if e<last_e,
        if direction_f,direction_f=false;end
        if x+op*10^-mul<=0,mul=mul+1;end
        x=x+op*10^-mul;
    elseif e>last_e,
        if ~direction_f,
            mul=mul+1;
            direction_f=true;
            op=-op;
        end
        if x+op*10^-mul<=0,mul=mul+1;end
        x=x+op*10^-mul;
    end
    last_e=e;
end
if z>0,x=-x;end
end
function [theta]= getYT(x,z,NUM,DEN)
syms  G(s) %si la variable ya esta creada ahorro segundos
G(s)=poly2sym(NUM,s)/poly2sym(DEN,s);
 
if z>0,
     y=x*tan(acos(z));%-x * tan(-acos()) is positive
     %so x*tan(acos) is positive too
     
     testpoint=complex(-x,y);%x is in the let of the S plane
  theta=angle(double(G(testpoint)));  
   
 elseif z<0
   y=x*tan(-acos(z));
   testpoint=complex(x,y);
   theta=angle(double(G(testpoint)));  
 end
end
function [bool]=rightDirection(x,z,NUM,DEN)
up=1;
%if x-up<=0,up=.5;end
t0=getYT(x,z,NUM,DEN);
t2=getYT(x+up,z,NUM,DEN);
e2=(pi-abs(t2))*100/pi;
e0=(pi-abs(t0))*100/pi;
  if e2<e0,
    bool=-1;
  else
      bool=1;
  end
end