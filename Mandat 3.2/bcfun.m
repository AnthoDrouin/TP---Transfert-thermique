function [pl,ql,pr,qr] = bcfun(xl,Tl,xr,Tr,t)
global Phase Tinit tswitch


if Phase == 1
    pl = Tl - (773 - (t/tswitch)); 
    ql = 0;

    pr = 0;
    qr = 1;
elseif Phase == 2
    pl = Tl - (773 - (t/tswitch));  
    ql = 0;

    pr = 0;
    qr = 1;
elseif Phase == 3
    pl = 0;
    ql = 1;
     
    pr = Tr - (1083 - (t/tswitch)); 
    qr = 0;
end