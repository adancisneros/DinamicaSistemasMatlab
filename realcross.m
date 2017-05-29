% ROOTS=realcross(NUM,DEN)
% ENCUENTRA EL CRUZE EN EL EJE REAL DE UNA FUNCION G(s)=NUM/DEN

%(2017) adan.cisneros.lopez@gmail.com
function  ROOTS=realcross(NUM,DEN)
[NUM,DEN]=filternumden(NUM,DEN);
if size(DEN,2)-1>1%SI ES DE SEGUNDO GRADO O MAYOR SE CALCULA Y GRAFICA LOS PUNTOS DONDE CRUZA EL EJE REAL
v=poly2sym(DEN);u=poly2sym(NUM);
K=-v/u;
syms G(x) D(x)
D(x)=v;
G(x)=-1/K;%Gs EN TERMINOS DE x
warning('off','symbolic:solve:warnmsg3')
r=double(solve(diff(K)));%DERIVA,RESUELVE  Y MUETRA LOS RESULTADOS COMO VALORES CON DECIMALES
rfound=0;
for i=1:size(r,1)%BUSCAR CUALES RAICES ESTAN SOBRE EL EJE REAL        
    if imag(r(i))==0,%RAICES SOBRE EL EJE REAL SIN PARTE IMAGINARIA       
        if D(r(i))~=0,%SI DENOMINADOR ES 0, EVALUAR ESPECIALMENTE%           
        if G(r(i))<0, %PARA MAGNITUDES NEGATIVAS, SIGNIFICA QUE ESTA MULTIPLICADO POR -1=180°
            %disp(['Root No.',num2str(rfound+1),'=',num2str(r(i))]);           
            rfound=rfound+1;            
            ROOTS(1,rfound)=r(i);            
        end    
        end        
    end 
end
if rfound==0,ROOTS=[];end
else ROOTS=[];
end
end

