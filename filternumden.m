function [ n,d ] = filternumden( NUM,DEN )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%n=1;d=1;

if size(NUM,1)>1,
% for i=1:size(NUM,1),
%     n=conv(n,NUM(i,:));
% end
%turn=reshape(NUM,1,size(NUM,1))
n=poly(NUM');
elseif NUM==0
    n=[1 0];
else
    n=NUM;
end
if size(DEN,1)>1,
% for i=1:size(DEN,1),
%     d=conv(d,DEN(i,:));
% end
d=poly(DEN');
elseif DEN==0,
    d=[1 0];
else
   d=DEN;
end

% nz=find(n~=0);
% dp=find(d~=0);
% if nz(1)>1,  
% for i=1:nz(1)-1
%  n(1)=[];
% end
% end 
% 
% if dp(1)>1,  
% for i=1:dp(1)-1
%  d(1)=[];
% end
% end 

end

