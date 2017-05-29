function p = processargs(p)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
validPlotOn={'a','r','s'};
rlocusCell={'a','r'};
stepCell={'a','s'};
validPlot={'a','r','s','o'};
validPrint={'a','as','r','i','t','k','o'};
validPrintOn={'a','as','r','i','t','k'};
%checkParam=@(x) isrow(x);
addParamValue(p,'testpoint',[],@isnumeric)
addParamValue(p,'k',[],@isnumeric)
addParamValue(p,'z',[],@isnumeric)
addParamValue(p,'pos',[],@isnumeric)%overshot %
addParamValue(p,'nc',[],@isnumeric)%numerator compensator
addParamValue(p,'dc',[],@isnumeric)%denominator compensator
addParamValue(p,'g','o',@(x) any(strcmp(x,validPlot)))%g stands for graphic
addParamValue(p,'p','a',@(x) any(strcmp(x,validPrint)))%s stands for suprime
addParamValue(p,'name','System 1',@ischar)
addParamValue(p,'tp',[],@isnumeric)
addParamValue(p,'ts',[],@isnumeric)
addParamValue(p,'criteria',2,@isnumeric)
addParamValue(p,'kx',[],@isnumeric)

end

