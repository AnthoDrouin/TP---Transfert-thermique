clear, close all, clc
global tswitch Tinit Phase dx discr

%% Initiation des données: DONNÉES DES CYCLES DU RROT
imax = 10;            % Nombre d'itérations maxaximale; 
discr = 1000;          % Nombre d'élément de discrétisation de l'espace;
xmax = [1.6];      % Hauteur(s) du garnissage;
Tinit = 900*ones(discr); % Initialisation des températures comme étant
                         % uniformes dans le garnissage et à tampérature
                         % ambiante soit environ XXX °K ;

% Gère le temps de simulation maximal pour pas trop se faire chier à
% attendre que ça finisse de calculer;
tstart = cputime;       % Temps 0 du début des calculs;
tlim = 30;            % Temps maximum de calcul secondes;
flag = 0;

% Calcul et mise graphique de la solution de l'équation de chaleur;
figure
while flag == 0
    % Boucle qui exécute la simulation pour tout les valeurs de xmax du
    % garnissage ;
    for j = 1:length(xmax)
        
        x = linspace(0, xmax(j), discr);
        dx = x(2) - x(1);
        tswitch = 110;            % Un cycle dure environ 110 secondes
                                  % selon les donnees du Excel ;
        t = linspace(0, tswitch, discr);

        % Boucle qui résoud l'EDP de chaleur pour imax cycle ;
            m = 0;
        for  i = 1:imax
            i
            if cputime - tstart > tlim
                fprintf('Temps de calcul trop long, change dequoi parce que ca finira pu de finir!\n')
                flag = flag + 1;
                break
            else
                Phase = 1;
                sol1 = pdepe(m, @pdefun, @icfun, @bcfun, x, t); % sol = T(t, x)
                Tinit = sol1(discr,:);  % Assigne les toutes les températures 
                                    % au dernier temps de la solution de la 
                                    % Phase 1 à la solution initiale pour 
                                    % la Phase 2 qui va suivre ;
                Phase = 2;
                sol2 = pdepe(m, @pdefun, @icfun, @bcfun, x, t); % sol = T(t, x)
                Tinit = sol2(discr,:);  % Assigne les toutes les températures 
                                    % de la solution de la Phase 2
                                    % à la solution initiale pour 
                                    % la Phase 3 qui va suivre ;
                Phase = 3;
                sol3 = pdepe(m, @pdefun, @icfun, @bcfun, x, t); % sol = T(t, x)
                Tinit = sol3(discr,:);  % Assigne les toutes les températures 
                                    % de la solution de la Phase 3
                                    % à la solution initiale pour 
                                    % la Phase 1 qui va suivre ;
            end
        end
        % Remettre en °C ;
        sol1 = sol1 - 273;
        sol2 = sol2 - 273;
        sol3 = sol3 - 273;

        soltot = [sol1; sol2; sol3];
        t = linspace(0, 3*tswitch, 3*discr);
        % Enregistrement de la solution pour la hauteur de garnissage à
        % sa valeur t = tswitch dans l'aluminerie soit h = 1.6 [m] ;
        if xmax(j) == 1.6 && i == imax
            x16 = x;
            tx16 = t;
            solx16 = soltot;
        end 
        
        % Tracer de la figure comparative pour les différentes hauteur
        % de garnissage saisie dans le vecteur « xmax » (entre les lignes 6 à 12) ;
        subplot(length(xmax), 1, j), surf(x, t, soltot, 'edgecolor', 'none'), hold on
        title('Distribution de °T dans le garnissage pour une hauteur en mètres de', xmax(j))
        xlabel('Hauteur garnissage [m]'), ylabel('Temps [sec]'), zlabel('Température [°C]')
        colorbar

        % Condition pour briser la boucle « while » si une solution est
        % trouvée avant l'atteinte de la limite de temps -tlim- ;
        if j == length(xmax) && i == imax
            fprintf('Convergence avant la fin du chrono!\n')
            
            figure
            surf(x16, tx16, solx16, 'edgecolor', 'none')
            title('Distribution de °T dans le garnissage pour une hauteur de 1.6 [m]')
            xlabel('Hauteur garnissage [m]'), ylabel('Temps [sec]'),
            zlabel('Température [°C]'), colorbar
            
            return  % Permet de sortir de tous les loops en même temps;
        end
    end
end

% --------------------- Si la simulation est arrêter par la fin du chrono ;
% Figure avec seulement le résultat de simulation pour xmax = 1.6 [m];
fprintf('Figure de la distribution de °T au temps limite de simulation!\n')
figure
surf(x16, tx16, solx16, 'edgecolor', 'none')
title('Distribution de °T dans le garnissage pour une hauteur de 1.6 [m]')
xlabel('Hauteur garnissage [m]'), ylabel('Temps [sec]'), zlabel('Température [°C]'), colorbar
