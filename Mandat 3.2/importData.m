%{ 
%% Importation des donnees empiriques
filename = 'Données_brutes_Biotox-GMC-3005_VF.xlsx';

% Specify the range of data to read
dataRange = 'C8:AC728';

% Read the data from the Excel file
dataTable = readtable(filename, 'Range', dataRange);

% Convert the relevant columns to numeric arrays
realTime = dataTable{:,1};
BU12 = dataTable{:,3};
Text = dataTable{:,4};
T1 = dataTable{:,5};
T2 = dataTable{:,6};
L3 = dataTable{:,7};
T3 = dataTable{:,8};
T4 = dataTable{:,9};
T5 = dataTable{:,10};
L2 = dataTable{:,11};
T6 = dataTable{:,12};
T7 = dataTable{:,13};    
T8 = dataTable{:,14};
L1 = dataTable{:,15};
T9 = dataTable{:,16};
T10 = dataTable{:,17};
T11 = dataTable{:,18};
BU11 = dataTable{:,19};
T12 = dataTable{:,20};
T13 = dataTable{:,21};
V3 = dataTable{:,22};
V6 = dataTable{:,23};
V2 = dataTable{:,24};
V5 = dataTable{:,25};
V1 = dataTable{:,26};
V4 = dataTable{:,27};

%% Interpolation des données pour augmenter la définition
originalTime = min(realTime):1:max(realTime);

interpolatedBU12 = interp1(realTime, BU12, originalTime);
interpolatedText = interp1(realTime, Text, originalTime);
interpolatedT1 = interp1(realTime, T1, originalTime);
interpolatedT2 = interp1(realTime, T2, originalTime);
interpolatedL3 = interp1(realTime, L3, originalTime);
interpolatedT3 = interp1(realTime, T3, originalTime);
interpolatedT4 = interp1(realTime, T4, originalTime);
interpolatedT5 = interp1(realTime, T5, originalTime);
interpolatedL2 = interp1(realTime, L2, originalTime);
interpolatedT6 = interp1(realTime, T6, originalTime);
interpolatedT7 = interp1(realTime, T7, originalTime);
interpolatedT8 = interp1(realTime, T8, originalTime);
interpolatedL1 = interp1(realTime, L1, originalTime);
interpolatedT9 = interp1(realTime, T9, originalTime);
interpolatedT10 = interp1(realTime, T10, originalTime);
interpolatedT11 = interp1(realTime, T11, originalTime);
interpolatedBU11 = interp1(realTime, BU11, originalTime);
interpolatedT12 = interp1(realTime, T12, originalTime);
interpolatedT13 = interp1(realTime, T13, originalTime);
interpolatedV3 = interp1(realTime, V3, originalTime);
interpolatedV6 = interp1(realTime, V6, originalTime);
interpolatedV2 = interp1(realTime, V2, originalTime);
interpolatedV5 = interp1(realTime, V5, originalTime);
interpolatedV1 = interp1(realTime, V1, originalTime);
interpolatedV4 = interp1(realTime, V4, originalTime);
%} 

%% Importation des donnees empiriques
filename = 'Donnees brutes.xlsx';

% Specify the range of data to read
dataRange = 'A1:D33';

% Specify the sheet name
sheetName = 'Sheet3';

% Read the data from the specified sheet in the Excel file
dataTable = readtable(filename, 'Sheet', sheetName, 'Range', dataRange);

time_calib = dataTable{:,1};
T3_calib = dataTable{:,2};
T4_calib = dataTable{:,3};
T5_calib = dataTable{:,4};

X = time_calib';
Y = linspace(0, 1.6, 3);
Z = [T3_calib T4_calib T5_calib];

Xq = 0:330/256:330
Yq = 0:1.6/16:1.6
Zq = interp2(Z, 3, 'cubic');
figure
surf(Yq, Xq, Zq, 'edgecolor', 'none')

%{
%% Importation des donnees empiriques
filename = 'Données_brutes_Biotox-GMC-3005_VF - V2.xlsx';

% Specify the range of data to read
dataRange = 'A3:M37';

% Specify the sheet name
sheetName = 'Chambre 3';

% Read the data from the specified sheet in the Excel file
dataTable = readtable(filename, 'Sheet', sheetName, 'Range', dataRange);

T4_valid = dataTable{:,5};
%}
%{ 
%% Visualisation de quelques données
% Plotting some of the interpolated data for visualization
figure;

% Example plot for BU12
subplot(3,1,1);
plot(originalTime, interpolatedBU12);
title('BU12 over Time');
xlabel('Time');
ylabel('BU12');

% Example plot for T1
subplot(3,1,2);
plot(originalTime, interpolatedT1);
title('T1 over Time');
xlabel('Time');
ylabel('T1');

% Example plot for V1
subplot(3,1,3);
plot(originalTime, interpolatedV1);
title('V1 over Time');
xlabel('Time');
ylabel('V1');

%} 