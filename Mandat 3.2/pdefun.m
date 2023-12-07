function [c,f,s] = pdefun(x,t,T,dudx)
global Phase

rho_c_eq = 1300.22*1049.5; 
k_eq = 1.029;
rho_c_gaz = 0.4354*1099;
v = 1.6;

if Phase == 1
    u = -v; 
elseif Phase == 2
    u = -v; 
elseif Phase == 3
    u = 2*v; 
end

c = rho_c_eq;
f = k_eq*dudx;
s = rho_c_gaz*u*dudx;
end