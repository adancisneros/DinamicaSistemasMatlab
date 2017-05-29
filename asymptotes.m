%CALCULA LAS ASINTOTAS DE UN SISTEMA G(S)=NUM/DEN
%LA SALIDA DE ESTE PROGRAMA ES UN PUNTO DE CORTE CON EL EJE REAL (Oa) Y LOS
%ANGULOS A LOS CUALES SE FORMAN LAS ASINTOTAS
%
%[Oa,ANGLES]=asymptotes(NUM,DEN)

%(2017) adan.cisneros.lopez@gmail.com

function [Oa,ANGLES]=asymptotes(NUM,DEN) 
[NUM,DEN]=filternumden(NUM,DEN);
if size(DEN,2)>size(NUM,2),%si existen asintotas, mostrar donde cortan y con cual angulo

    Na=size(DEN,2)-size(NUM,2);%number of asymptotes  
    ANGLES=zeros(1,Na);
    z=reshape(roots(NUM),1,[]);
    p=reshape(roots(DEN),1,[]);
    Ox=(sum(p,2)-sum(z,2))/(Na);
    if imag(Ox)==0,
    Oa=Ox;
    else
       Oa=[];
    end
    
  for i=1:Na
      theta_a=(2*i-1)*pi/(Na);
      ANGLES(1,i)=theta_a;
  end
else
    Oa=[];ANGLES=[];
 end
end