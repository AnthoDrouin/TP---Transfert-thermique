function [t0, tf, J_m2] = integ(x, t, prop, distT)
% INTEG réalise la méthode trapz dans MATLAB pour trouver l'air 
%   des surfaces définient dans le main()

xmin = x(1);
xmax = x(2);
discrx = x(3);

tmin = t(1)+1; % Première ligne de la matrice distT
tmax = t(2);   % Dernière ligne de la matrice distT

cp = prop(1);
rho = prop(2);
meshx = linspace(xmin, xmax, discrx);

% Effectue l'intégrale trapézoïdale pour le temps t = 0 et = 330s ;
t0 = cp*rho*trapz(distT(tmin,:)+273, meshx)*(1/1000);   % en [kJ/m^2];
tf = cp*rho*trapz(distT(tmax, :)+273, meshx)*(1/1000);  % en [kJ/m^2];

J_m2 = (t0 - tf)/1000;          % Différence des résultats en [kJ/m^2];
end

