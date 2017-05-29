%CALCULA  EL VECTOR RESULTANTE DE UN SISTEMA G(s)=NUM/DEN
%PARA UN PUNTO DE PRUEBA (tp) DADO.
%
%[theta,rho,vector_x,vector_y]= calculateVector(NUM,DEN,tp)
%theta : angulo resultante
%rho : magnitud del vector
%vector_x, vector_y : vector en forma rectangular

%(2017) adan.cisneros.lopez@gmail.com
function [theta,rho,vector_x,vector_y]= calculateVector(NUM,DEN,tp)
[NUM,DEN]=filternumden(NUM,DEN);
syms G(x) 
G(x)=poly2sym(NUM)/poly2sym(DEN);
vector_x=real(double(real(G(tp))));vector_y=real(double(imag(G(tp))));
try
[theta,rho]=cart2pol(vector_x,vector_y);
%disp([num2str(double(G(tp))),' ',num2str(vector_x),' ',num2str(vector_y)])
catch 
    disp('error')
disp([num2str(double(G(tp))),' ',num2str(real(vector_x)),' ',num2str(vector_y)])
end
end

