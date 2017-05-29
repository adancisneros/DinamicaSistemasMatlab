%Routh-Hurwitz criteria
% [RH] = rh(POLY,E)
% RESUELVE EL CRITERIO DE ROUTH-HURWITZ PARA UN POLYNOMIO POLY

%(2017) adan.cisneros.lopez@gmail.com
function [RH] = rh(POLY,E)
if nargin==1,E='E';end
e=sym(E);

filas=size(POLY,2);
%columnas=0;
if iseven(filas),columnas=filas/2;else columnas=(filas+1)/2;end
M=sym(zeros(filas,columnas));
%RH=zeros(filas,columnas);
k=1;
for fila=1:filas%recorrer todas las  filas
    if fila==1,k=1;end
    if fila==2,k=2;end
    for columna=1:columnas%recorrer todas las columnas        
    if fila==1||fila==2
        if k>filas,
            %RH(fila,columna)=0;
            M(fila,columna)=0;
        else
            %RH(fila,columna)=
            M(fila,columna)=POLY(1,k);
        end
        k=k+2;
    else
    %iteraciones para cada elemento de la matriz
    %R(fila,columna) recorrera cada elemento
   
    if columna<columnas, %no me acerco a las columnas de la orilla derecha por que son 0's
     
    if columna==2&&fila>=filas-1,
         M(fila,columna)=0;continue
    end        
    M(fila,columna)=(M(fila-1,1)*M(fila-2,columna+1)-M(fila-2,1)*M(fila-1,columna+1))/M(fila-1,1);    
    if M(fila,columna)==0,M(fila,columna)=e;end
    
    end  
    end
    end
end

RH=M;
end

