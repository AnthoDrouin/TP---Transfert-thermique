clear, close all, clc
global tswitch Tinit Phase dx;

%% Initiation des données: DONNÉES DES CYCLES DU RROT
imax = 25;     % NBR itération max
discr = 1000;  % Nombre d'élément de discrétisation de l'espace 
xmax = 1.6;    % Hauteur du garnissage;

x = linspace(0, xamx,discr);
dx = x(2) - x(1);
tswitch = 110;
t = linspace(0, tswitch, discr);
Tinit = 900*ones(discr);

for  i=1:imax
    Phase = 1;
    sol1 = pdepe(0, @pdefun, @icfun, @bcfun, x, t);
    Tinit = sol1(discr,:);
    
    Phase = 2;
    sol2 = pdepe(0, @pdefun, @icfun, @bcfun, x, t);
    Tinit = sol2(discr,:);
    
    Phase = 3;
    sol3 = pdepe(0, @pdefun, @icfun, @bcfun, x, t);
    Tinit = sol3(discr,:);
end

% Remettre en °C
sol1 = sol1 - 273;
sol2 = sol2 - 273;
sol3 = sol3 - 273;

soltot = [sol1; sol2; sol3];
t = linspace(0, 3*tswitch, 3*discr);
surf(x, t, soltot, 'edgecolor', 'none')
xlabel('Hauteur garnissage [m]'), ylabel('Temps [sec]'), zlabel('Température [°C]')