% CALCULA LOS VALORES DONDE UNA FUNCION G(s)=NUM/DEN INTERSECTA AL EJE IMAGINARIO
% imagcross(NUM,DEN)

%(2017) adan.cisneros.lopez@gmail.com
function ROOTS=imagcross(NUM,DEN)
[NUM,DEN]=filternumden(NUM,DEN);
if size(DEN,2)<size(NUM,2),error('Numerator grade must be less or equal than denominator'),end
if size(DEN,2)-2==0,
    ROOTS=[];return
end
sub=size(DEN,2)-size(NUM,2);
NUM=[zeros(1,sub) NUM];%debo llenar con ceros los espacios delante si es que DEN es mayor que NUM

rfound=0;
order_den=size(DEN,2)-1;
syms x k
a=sym('n',[1 size(NUM,2)]);
b=sym('d',[1 size(DEN,2)]);

rhz=rh(a*k+b);%procesarlos en RouthHurwitz
coeffs_eq2=[rhz(order_den-1,1) 0 rhz(order_den-1,2)];
coeffs_eqk=rhz(order_den,1);

try
    k_sym=solve(subs(subs(coeffs_eqk,a,NUM),b,DEN),k);
    for i=1:size(k_sym,1)
        if imag(double(k_sym(i,1)))~=0,break;end
        if real(double(k_sym(i,1)))<0,break;end
        %kc_sym=k_sym(i,1);
        kc=double(k_sym(i,1));
        kc=real(kc);
        
        rts_sym=solve(poly2sym(subs(subs(subs(coeffs_eq2,k,kc),a,NUM),b,DEN),x));        
        rts=double(rts_sym);
        if real((rts(1)))==0&&real((rts(2)))==0,
            rfound=rfound+1;%en cada raiz encontrada se suma uno
            ROOTS(1,rfound,1)=abs(rts(1));
            ROOTS(1,rfound,2)=kc;
         end  
    end
    if rfound==0,ROOTS=[];end
% try  
 catch e
    e.identifier
   disp('Eror calculating cross with imaginary axis')
end
end     
