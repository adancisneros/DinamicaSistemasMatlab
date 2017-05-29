%Parametros esperados obligatorios
%   NUM=VECTOR FILA (O COLUMNA*) CON LOS COEFICIENTES DEL NUMERADOR
%   DEN=VECTOR FILA (O COLUMNA*) CON LOS COEFICIENTES DEL DENOMINADOR
%   rlokis([1 2],[1 2 3],....) para el sistema G(s)=(s+2)/(s^2+2s+3)
%   tambien es posible la siguiente opcion
%   rlokis([1 2],[0;-4;-6],....) donde el denominador tiene la forma
%   s(s+4)(s+6)
%   *Notese que ahora DEN esta separado por ; (VECTOR COLUMNA, para hacer uso
%   de esta manera de ingresar NUM o DEN debe exixtir mas de un cero o polo)
%   Seria lo mismo que escribir de esta manera:
%   rlokis([1 2],[1 10 24 0],....) ya que s(s+4)(s+6)=s^3+10s^2+24s+0
%   Si solo se escribe un numero en NUM y/o DEN,y es distinto de cero,
%   entonces se reconocera como una constante, si es cero, se reconocera
%   como un zero o polo en el origen, segun corresponda:
%   rlokis(1,[1 2]) para el sistema G(s)=1/(s+2) *Notese que no es
%   necesario escribir NUM entre corchetes
%   rlokis(0,[1 2]) para el sistema G(s)= s/(s+2) *Zero en el origen
%Parametros esperados opcionales,no importa el orden, 
%escribir entre apostrofes -> 'parametro','valor',...  si 'valor' es una opcion
%predefinida o 'parametro',valor,... si valor es un vector o numero
%   testpoint : punto de prueba para evaluar un sistema
%   ejemplo ...,'testpoint',-3+4i,... o ...,'testpoint',-3,... o ...,'testpoint',4i,...
%   k :valor de K para probar el sistema (pueden ser varios valores)
%   ejemplo ...,'k',42,... o ...,'k',[1 12 45 59],...
%   z :coeficiente de amortiguamiento relativo (damping), se buscara el
%   punto de prueba que se halle en el  cruze de linea de z con el lugar de las raices
%   pos :valor del overshoot en porcentaje para el cual se quiere evaluar
%   el sistema, internamente el overshoot se convertira en z y se buscara
%   el cruze del  lugar de las raices con z
%   g :graficar, opciones: a,r,s,o
%       a : (a de all) grafica rlocus y step del sistema si existen los
%       datos necesarios para hacerlo (opcion predeterminada si no se usa
%       el parametro 'g')
%       r : (r de rlocus) grafica solo el lugar de las raices del sistema con la
%       ubicacion del punto de prueba si es que hay informacion para
%       obtenerlo
%       s : (s de step) grafica solo la respuesta del sistema a una entrada escalon
%       (si se introducen mas de una ganancia con el parametro 'k', se
%       graficaran todas las respuestas en la misma figura)
%       o: (o de off) no grafica nada
%   p :imprimir informacion en pantalla, opciones: a,as,r,i,t,k,o
%       a : (a de all) imprime toda la informacion del sistema (opcion
%       predeterminada si no se usa el parametro 'p')
%       as : (as de asintota) imprime informacion sobre las asintotas
%       (punto de salida y angulo de estas)
%       r : (de cruze con el eje Real) imprime informacion sobre las raices que cortan el eje real
%       i : (de cruze con el eje Imaginario) imprime informacion sobre las raices que cortan el eje imaginario
%       t :(de test point) imprime informacion sobre el punto de prueba
%       k: si se especifica el parametro 'k' con una o varias ganancias, se
%       imprimira la informacion sobre esta(s)
%       o : no imprime nada
%   tp : calcula punto prueba para un tiempo pico 
%   ts : calcula punto prueba para un tiempo de asentamiento
%       *Notese que es posible dar un factor alas opciones de arriba, si se pasa como
%       parametro un vector fila con 2 elementos, siendo el primero un elemento
%       de la siguiente lista:
%       1 suma
%       2 resta
%       3 multiplica
%       4 divide
%       5 cantidad de porcentaje
%       y el ultimo el factor;  se aplicara la operacion indicada al ts original con respecto al factor
%       por ejemplo
%       'ts',[4,2] : al tiempo de asentamiento original de un sistema dado se le dividira (opcion 4) por 2 (factor)
%       'tp',[3,1/2] : al tiempo pico original de un sistema dado se le multiplicara (opcion 3) por 1/2 (factor)
%   criteria : criterio de error con el que se calcula ts, por default 2% (escribir solo el numero)
%   nc : numerador del compensador (sigue las mismas reglas que NUM y DEN
%   para ingresar los datos)
%   dc : denominador del compensador (sigue las mismas reglas que NUM y DEN
%   para ingresar los datos)
%adan.cisneros.lopez@gmail.com
function rlokis(NUM,DEN,varargin)
[NUM,DEN]=filternumden(NUM,DEN);
%#Zeros must be equal or less than #Poles
if size(NUM,2)>size(DEN,2),error('Number of zeros must be less or equal to the number of poles');end 

%PLOT OPTIONS
validPlot={'a','r','s','o'};plotOn={validPlot{1},validPlot{2},validPlot{3}};rPlot={validPlot{1},validPlot{2}};sPlot={validPlot{1},validPlot{3}};
%PRINT OPTIONS
validPrint={'a','as','r','i','t','k','o'};printOn={validPrint{1},validPrint{2},validPrint{3},validPrint{4},validPrint{5},validPrint{6}};asPrint={validPrint{1},validPrint{2}};rPrint={validPrint{1},validPrint{3}};iPrint={validPrint{1},validPrint{4}};tPrint={validPrint{1},validPrint{5}};kPrint={validPrint{1},validPrint{6}};
%VALID NAMES FOR SYSTEM (USED ONLY IN PROGRAM)
validName={'Original','Compensated'};
%checkParam=@(x) isrow(x);
if true,%PROCESAR ARGUMENTOS
p=inputParser;  
addParamValue(p,'testpoint',[],@isnumeric)
addParamValue(p,'k',[],@isnumeric)
addParamValue(p,'z',[],@isnumeric)
addParamValue(p,'pos',[],@isnumeric)%overshot %
addParamValue(p,'numc',[],@isnumeric)%numerator compensator
addParamValue(p,'denc',[],@isnumeric)%denominator compensator
addParamValue(p,'g',validPlot{4},@(x) any(strcmp(x,validPlot)))%g stands for graphic,default 'off'
addParamValue(p,'p',validPrint{1},@(x) any(strcmp(x,validPrint)))%p stands for print,default 'all'
addParamValue(p,'name',validName{1},@(x)any(strcmp(x,validName)))
addParamValue(p,'tp',[],@isnumeric)
addParamValue(p,'ts',[],@isnumeric)
addParamValue(p,'criteria',2,@isnumeric)
%addParamValue(p,'kx',[],@isnumeric)
parse(p,varargin{:});
TESTPOINT=p.Results.testpoint;
GAIN=p.Results.k;   
Z=p.Results.z;
POS=p.Results.pos;
NUMC=p.Results.numc;
DENC=p.Results.denc;
PLOT=p.Results.g;
PRINT=p.Results.p;    
TP=p.Results.tp;
TS=p.Results.ts;
CRITERIA=p.Results.criteria;
end
if any(strcmp(PRINT,printOn)),%IMPRIME FUNCION DE TRANSFERENCIA
    printsys(NUM,DEN,'s')
end
if isvector(Z)||isvector(POS),%calcular test point para amortiguamiento relativo dado
   if ~isvector(Z), Z=-log(POS/100)/sqrt(pi*pi+log(POS/100)^2);end
    if isvector(TP)||isvector(TS),
        if isvector(TP),
            %according with the formula Tpeak=PI/(Wn*sqrt(1-Z^2))
            %where Y=Wn*sqrt(1-Z^2) is the imaginary part in the S plane
            %and tan(-Cos(Z))=Y/X so X, the real part => X=Y/tan(-cos(Z))
            th=tan(-acos(Z));%para Z>0 ya que hacia la izquierda del plano S es donde
            %se encuentra RLocus
            
            if size(TP,2)==2,
                 [tx,ty,err]=damping(NUM,DEN,Z);
               tpx=complex(tx,ty);
               wn=abs(tpx);
                operation=TP(1);factor=TP(2);
                TP=pi/wn/sqrt(1-Z*Z);
                switch operation
                   case 1 %'+'
                       TP=TP+factor;
                   case 2 %'-'
                       TP=TP-factor;
                   case 3 % '*'
                       TP=TP*factor;
                   case 4 %'/'
                       TP=TP/factor;
                   case 5 % '%'
                       TP=TP*factor/100;
                   otherwise, error('Unknown command for TP');
               end
            end
            
            if Z>0,
            TESTPOINT=complex(pi/TP/th,pi/TP);
            else
            TESTPOINT=complex(-pi/TP/th,pi/TP);
            end

        else%is vector TS
            %acording to https://en.wikipedia.org/wiki/Settling_time
            %Ts=-ln(tolerance fraction*sqrt(1-Z^2)/(Wn*Z)
            %where tolerance fraction=> CRITERIA/100 and Wn*Z=X => the real
            %part in the S plane, so Y/X=tn(-cos(Z)) and Y=X*tn(-cos(Z))
           
           if size(TS,2)==2,%para el caso 'ts',[1,3]
               [tx,ty,err]=damping(NUM,DEN,Z);
               tpx=complex(tx,ty);
               wn=abs(tpx);
               operation=TS(1);
               factor=TS(2);
               TS=-log(CRITERIA*.01*sqrt(1-Z^2))/(Z*wn);
               switch operation
                   case 1 %'+'
                       TS=TS+factor;
                   case 2 %'-'
                       TS=TS-factor;
                   case 3 % '*'
                       TS=TS*factor;
                   case 4 %'/'
                       TS=TS/factor;
                   case 5 % '%'
                       TS=TS*factor/100;
                   otherwise, error('Unknown command for TS');
               end
               
           end
            
            n=-log(CRITERIA*.01*sqrt(1-Z*Z));
            th=tan(-acos(Z));
           if Z>0,
            TESTPOINT=complex(-n/TS,-n*th/TS);   
           else
            TESTPOINT=complex(n/TS,n*th/TS);
           end                      
        end
    else
    [a,b,err]=damping(NUM,DEN,Z);
    TESTPOINT=complex(a,b);
    end
elseif isvector(TP)||isvector(TS),
   error('Either test point,damping or overshot values must be set first in order to use Tp or Ts')
end    
if any(strcmp(PRINT,asPrint)),%CALCULO DE ASINTOTAS
[Oa,ang]=asymptotes(NUM,DEN);
if size(ang,2)>0,
disp('------Asymptotes')
disp(['Intersect real axis at:',num2str(Oa)])
txt='Angles:';
for d=1:size(ang,2)
    txt=[txt,' ',num2str(ang(1,d)*180/pi),'°'];
end
disp(txt);
end
end
if any(strcmp(PRINT,rPrint)),%SE CaLCULA DONDE CRUZA EL EJE REAL
r=realcross(NUM,DEN);
if isvector(r),
    disp('------Computing intersection with real axis')
    for i=1:size(r,2)
        disp(['Crossing real axis at:',num2str(r(i))])
    end
end
end
if any(strcmp(PRINT,iPrint)),%CALCULANDO CRUZE CON EJE IMGINARIO
 imk=imagcross(NUM,DEN);
if min(size(imk))>0,
    disp('------Computing intersection with imaginary axis')
for i=1:size(imk,2)
    disp(['Crossing imaginary axis at: ±',num2str(imk(1,1,1)),'i']);      
%             t=cart2pol(0,imk(1,1,1));
%             Zim=-cos(t);%PO=100*exp(-Z*pi/sqrt(1-Z*Z));
%             disp(['Damping=',num2str(Zim)])
            disp(['Freq(rad/s)=',num2str(imk(1,1,1))]);
            disp(['Kcr=',num2str(imk(1,1,2))]);
            disp(['Pcr(s)=',num2str(2*pi/imk(1,1,1))]);
end
end
end
if any(strcmp(PLOT,rPlot)),%IMPRIMO ZEROS Y POLOS
poles=roots(DEN);
zeros=roots(NUM);
figure('Name',[p.Results.name,': Root Locus'],'NumberTitle','off');
hold on;%SE PERMITE QUE LAS GRAFICAS CONSERVEN SU CONTENIDO PARA PODER SEGUIR DIBUJANDO ENCIMA
% end
if isreal(poles),
plot(complex(poles),'kx','MarkerSize',7,'LineWidth',2);
else plot(roots(poles),'kx','MarkerSize',7,'LineWidth',1);
end
if size(NUM,2)>1,
if isreal(zeros),
plot(complex(zeros),'bo','LineWidth',1);
else plot(zeros,'kx','MarkerSize',7,'LineWidth',1);
end
end
rlocus(NUM,DEN);
end

if isvector(TESTPOINT),%SI HAY PUNTO DE PRUEBA
if any(strcmp(PLOT,rPlot)),plot(real(TESTPOINT),imag(TESTPOINT),'bo','MarkerFaceColor','r');end
[v_theta,v_len,v_x,v_y]=calculateVector(NUM,DEN,TESTPOINT);
v_theta_deg=v_theta*180/pi;
Kgain=1/v_len;

if any(strcmp(PLOT,rPlot)),%imprime vector resultante
plot([0 v_x],[0 v_y],'r-');plot(v_x,v_y,'r*','MarkerFaceColor','r');
end
if any(strcmp(PRINT,tPrint)),%si se puede imprimir all o testpoint
  disp('------Computing data for test point')
if exist('err','var'),
    disp(['Test point:',num2str(TESTPOINT),' calculated with (',num2str(err),')% error']);
else
  disp(['Test point:',num2str(TESTPOINT)])     
end

if v_theta<0,
%    disp(['Angle of vector:',num2str(v_theta),'rad = ',num2str(v_theta_deg),'° or :',num2str(v_theta+2*pi),'rad = ',num2str(360+v_theta_deg),'°']);
disp(['Resultant vector:',num2str(v_len),' with angle:',num2str(v_theta+2*pi),'rad = ',num2str(360+v_theta_deg),'°']);
else
    disp(['Resultant vector:',num2str(v_len),' with angle:',num2str(v_theta),'rad = ',num2str(v_theta_deg),'°'])
end
        poles=polesfork(NUM,DEN,Kgain);        
        if size(poles,2)>1,%si hay mas de un polo
        txtpolesk=['Gain K:',num2str(Kgain),' and other poles:'];
        magtp=abs(TESTPOINT); 
        for j=1:size(poles,2)
             magp=abs(poles(j));
             dif=abs(magtp-magp)*100/magtp;
             if dif<.1,continue,end;
            %if double(poles(j))==double(TESTPOINT),continue;end
             if isreal(poles(j)),                
                txtpolesk=[txtpolesk,' ',num2str(poles(j))];               
            else
                txtpolesk=[txtpolesk,' ',num2str(real(poles(j))),'±',num2str(imag(poles(j))),'i'];               
            end
            %if j<size(poles,2)-1,txtpolesk=[txtpolesk,','];end
         end
        disp(txtpolesk);
        else %solo un polo que es el TESTPOINT
            disp(['Gain K:',num2str(Kgain)]);
        end
        
%OBTENER CONSTANTES DE ERROOR KP KV KA
disp('Error constants')
[kx,ex,type]=kpkvka(NUM,DEN,Kgain);
switch type
    case 0, disp(['Kp=',num2str(kx),' E(inf)=',num2str(ex)])
    case 1,disp(['Kv=',num2str(kx),' E(inf)=',num2str(ex)])
    case 2,disp(['Ka=',num2str(kx),' E(inf)=',num2str(ex)])
end

%INFORMACION EXTRA SOBRE EL COMPORTAMIENTO DEL SISTEMA EN EL PUNTO PRUEBA
printdataforTestPoint(TESTPOINT,CRITERIA);
end
if ~isvector(Z),Z=-cos(angle(TESTPOINT));end
if any(strcmp(PLOT,rPlot)),sgrid(Z,0);end
%si no hay ganancia explicita y hay opcion de ploteo se procede a realizar la grafica de step para el punto de prueba
if isempty(GAIN)&&any(strcmp(PLOT,sPlot)),%no hay GAIN y plot es 'step' o 'all'
    %if isempty(NUMC)&&isempty(DENC),%si no se usan compensadores, puedo graficar step de una vez
        if strcmp(PLOT,sPlot{1}),hold off;end%si plot es 'all', deja de mantener la figura 1 para pasar a la figura 2
        
        %en este punto ya grafico rlocus si es que PLOT es 'all', y si es 'all' hay que desactivar HOLD
        %llegado a est punto la linea debajo sera la ultima figura que se ploteara
        if strcmp(p.Results.name,validName{2}),%Compensado
           if strcmp(PLOT,sPlot{1}),%si plot es all significa que ya grafico rlocus, y step es la 2
           figure(2),hold on
           else
           figure(1),hold on
           end 
           step(feedback(tf(Kgain*NUM,DEN),1))
           title('Step response for compensated and original systems')
           legend(validName{1},validName{2},'Location','Best')
        else
        figure('Name','Step response','NumberTitle','off');          
        step(feedback(tf(Kgain*NUM,DEN),1))
        title(['Gain K=',num2str(Kgain)])
        end      
end
end
%TOMAR EN CUENTA GANANCIA K EXPLICITA EN LOS PARAMETROS
if isvector(GAIN),
    if any(strcmp(PLOT,sPlot)),%si se quiere imprimir step
        %para ahorrar figuras, grafico la respuesta escalon de TP y GAIN en
        %la misma figura
        if isvector(TESTPOINT),
            txt='step(feedback(tf(Kgain*NUM,DEN),1),feedback(tf(GAIN(1)*NUM,DEN),1)';%cerrar con parantesis )
            txtl='legend([''Test point K '',num2str(Kgain)],[''K '',num2str(GAIN(1))]';                        
        else
            txt='step(feedback(tf(GAIN(1)*NUM,DEN),1)';%cerrar con parantesis )
            txtl='legend([''K '',num2str(GAIN(1))]';
        end    
    end
    
   if any(strcmp(PRINT,kPrint)), disp('------Computing poles for value(s) of K'),end
    for i=1:size(GAIN,2)
      if i>1&&any(strcmp(PLOT,sPlot)),
       txt=[txt,',feedback(tf(GAIN(',num2str(i),')*NUM,DEN),1)'];
       txtl=[txtl,',[''K '',num2str(GAIN(',num2str(i),'))]'];
      end
      if any(strcmp(PRINT,kPrint)),%all o testpoint ???
      disp(['For K ',num2str(GAIN(i))]);
        poles=polesfork(NUM,DEN,GAIN(i));        
        if size(poles,2)==1,%solo un polo
         disp(['pole located at: ',num2str(poles(1))]);
        else           
        txtpolesk=['poles located at:'];
         for j=1:size(poles,2)
            if isreal(poles(j)),                
                txtpolesk=[txtpolesk,' ',num2str(poles(j))];               
            else
                txtpolesk=[txtpolesk,' ',num2str(real(poles(j))),'±',num2str(imag(poles(j))),'i'];               
            end
            if j<size(poles,2),txtpolesk=[txtpolesk,','];end
         end
        disp(txtpolesk);
        end   
      end
    end
    if any(strcmp(PLOT,sPlot)),%si step o all en gain
       
 %       if ~isempty(NUMC)||~isempty(DENC),%si no hay compensadores
        
%        else%si no hay compensadores
        txt=[txt,')'];
        txtl=[txtl,',''Location'',''Best'')'];
        %'all' grafica todo
        if strcmp(PLOT,plotOn{1}),hold off ;end
        figure('Name',[p.Results.name,': Given gain'],'NumberTitle','off')        
        eval(txt)
        eval(txtl)    
  %      end
        
    end
end
if isempty(TESTPOINT)&&isempty(GAIN),
    if any(strcmp(PLOT,sPlot)),
          if strcmp(PLOT,plotOn{1}),hold off;end%deja de mantener la figura 1 para pasar a la figura 2
        
        %en este punto ya grafico rlocus si es que PLOT es 'all', y si es 'all' hay que desactivar HOLD
        %llegado a est punto la linea debajo sera la ultima figura que se ploteara
        if strcmp(p.Results.name,'Compensated'),
           if strcmp(PLOT,plotOn{1}),%si plot es all significa que ya grafico rlocus, y step es la 2
           figure(2),hold on
           else
           figure(1),hold on
           end 
           step(feedback(tf(NUM,DEN),1))
           title('Step response for compensated and original systems')
           legend('Original','Compensated','Location','Best')
        else
        figure('Name','Step response','NumberTitle','off');          
        step(feedback(tf(NUM,DEN),1))
        title('Original')
        end
    end
end


%AGREGAR COMPENSADOR
if ~isempty(NUMC)||~isempty(DENC),
    if any(strcmp(PRINT,printOn)),
    disp('------COMPUTING DATA FOR COMPENSATED SYSTEM')
    end
   
    if isempty(NUMC),
    NUM2=NUM;
    else
        [NUMC,~]=filternumden(NUMC,1);
        NUM2=conv(NUM,NUMC);
    end
    if isempty(DENC),
    DEN2=DEN;
    else
        [~,DENC]=filternumden(1,DENC);
        DEN2=conv(DEN,DENC);
    end
     zc=p.Results.z;
     posc=p.Results.pos;
   rlokis(NUM2,DEN2,'testpoint',TESTPOINT,'k',GAIN,'z',zc,'pos',posc,'tp',TP,...
       'ts',TS,'criteria',CRITERIA,'name',validName{2},'p',PRINT,'g',PLOT)
end 

end
function printdataforTestPoint(testpoint,criteria)
wn=abs(testpoint);
z=-cos(angle(testpoint));
pos=100*exp(-z*pi/sqrt(1-z^2));
ts=-log(criteria*.01*sqrt(1-z^2))/z/wn;
tp=pi/wn/sqrt(1-z^2);
disp(['Damping=',num2str(z)])
disp(['Freq(rad/s)=',num2str(wn)])
disp(['Overshoot(%)=',num2str(pos)])
disp(['Time max peak(s)=',num2str(tp)])
    disp(['Settling time for ',num2str(criteria),'% (s)=',num2str(ts)])
end

