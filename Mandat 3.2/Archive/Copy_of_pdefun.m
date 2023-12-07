function [c,f,s] = pdefun(x,t,T,dT_dx)
global tswitch Tinit Phase;

rho_c_eq = 1377727.357;
k_eq = 1.031301;
rho_c_gaz = (-53.15281*x)+476.52;

if(Phase == 1)
    u =((-0.125*t)+25.63)/3600;
else
    if(Phase == 2)
        u = ((0.0727*t)+11.4)/3600;
    else
        u = -25.85/3600;
    end
end

c = rho_c_eq;
m = 0;
f = k_eq*dT_dx;
s = -rho_c_gaz*u*dT_dx;
end