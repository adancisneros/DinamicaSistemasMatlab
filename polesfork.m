% [ POLES ] = polesfork( NUM,DEN,K)
% PARA UNA FUNCION G(s)=NUM/DEN, ENCUENTRA TODOS LOS POLOS
% PARA LOS CUALES LA GANANCIA K ES LA MISMA

%(2017) adan.cisneros.lopez@gmail.com
function [ POLES ] = polesfork( NUM,DEN,K)
if ~isscalar(K),error('K must be a scalar');end
[NUM,DEN]=filternumden(NUM,DEN);
diff=size(DEN,2)-size(NUM,2);
NUM=[zeros(1,diff) NUM];
eq=K*NUM+DEN;
POLES=roots(eq);
POLES=reshape(POLES,1,[]);
oldp=[];
ptemp=[];
for i=1:size(POLES,2),
    if i>1,
        if abs(POLES(i))~=abs(oldp)||abs(angle(POLES(i)))~=abs(angle(oldp)),%si son conjugados
            ptemp=[ptemp POLES(i)];
        elseif i==size(POLES,2),
            break;
        end
    else
        ptemp=POLES(i);
    end
    
    oldp=POLES(i);
end
   POLES=ptemp;            

end

