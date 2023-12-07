import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
from scipy.optimize import curve_fit
import datetime
from tqdm import tqdm



data = pd.read_excel("temp_tt.xlsx")

temp_ext = data["Temp max.(°C)"]

start_data = "2022-01-01"
end_data = "2022-12-31"
data_linspace = pd.date_range(start_data, end_data, freq="D")

print(data_linspace)

print(f"Average cold temperature is {np.mean(temp_ext)}")

c_min = np.zeros_like(temp_ext)
    
# convert from scfm to m3/s

scfm_text = 2000
scfm_t13 = 6000

def scfm_to_m3s(scfm, temp):
    return scfm * 0.00047 * temp / 288.706

# hot temperature

temp_hot = 214.9  # average du excel de Alcoa
cp_hot = 1026

debit_massique_hot = scfm_to_m3s(scfm_t13, temp_hot+273.15) * 0.72
print(f"The debit massique hot is {debit_massique_hot}")
# cold temperature

def rho_cold(temp_kelvin):
    return -0.00466 * temp_kelvin + 2.5612

cp_cold = 1005
debit_massique_cold = scfm_to_m3s(scfm_text, temp_ext+273.15) * rho_cold(temp_ext+273.15)

print("The average debit massique cold is", np.mean(debit_massique_cold))
print(f"The average temperature outside is {np.mean(temp_ext)}")
# compute c_min

for i, cold_temp in enumerate(temp_ext):
    c_min[i] = min(cp_hot * debit_massique_hot, cp_cold * debit_massique_cold[i])

# compute qmax

qmax = c_min * (temp_hot - temp_ext) * 24 * 3600

print(f"The average qmax is {np.mean(qmax)/(10**(9))}")

print(f"The average qmax is {1163 * (temp_hot - 11)}")



plt.style.use("https://raw.githubusercontent.com/dccote/Enseignement/master/SRC/dccote-errorbars.mplstyle")

fig, ax = plt.subplots(figsize=(12, 8))
ax.plot(data_linspace, qmax/(10**(9)), "-", linewidth=2.5, color="black")
ax.set_xlabel("Mois de l'année", fontsize=22)
ax.set_ylabel("Transfert de chaleur maximal [GJ]", fontsize=22)
ax.tick_params(labelsize=22)
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m'))
ax.set_xlim([datetime.date(2022, 1, 1), datetime.date(2022, 12, 31)])
plt.savefig("qmax_vs_date.pdf", dpi=600)
plt.show()


fig, ax = plt.subplots(figsize=(12, 8))
qmax_cumsum_gj = np.cumsum(qmax/(10**(9)))
money_saved = qmax_cumsum_gj * 7.32

ax.plot(data_linspace, money_saved, "-", linewidth=2.5, color="black")
ax.set_xlabel("Mois de l'année", fontsize=22)
ax.set_ylabel("Économie potentielle cumulative [$]", fontsize=22)
ax.tick_params(labelsize=22)
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m'))
ax.set_xlim([datetime.date(2022, 1, 1), datetime.date(2022, 12, 31)])
plt.savefig("money_saved_vs_date.pdf", dpi=600)
plt.show()



def calc_eff_crossflow(T_cold_in, T_hot_in, dimensions, cold_properties, hot_properties, exchanger_properties, q_max, T_hot_out, T_cold_out):
    volume = dimensions[0]*dimensions[1]*dimensions[2]
    A_section = exchanger_properties[0]*dimensions[1]
    D_h = 4*A_section/(2*(exchanger_properties[0]+dimensions[0])) #hydraulic diameter
    Nu = 7.54   #Nusselt
    T_f_cold, T_f_hot = (T_cold_in+T_cold_out)/2, (T_hot_in+T_hot_out)/2#températures du film
    h_hot, h_cold = conduc_air(T_f_hot)*Nu/D_h, conduc_air(T_f_cold)*Nu/D_h  #coefficients de convection
    R_tot_surf = 1/(h_hot) + exchanger_properties[1]/exchanger_properties[2] + 1/(h_cold)  #résistance totale surfacique
    U = 1/R_tot_surf  #coefficient de transfert global
    C_min = min(cold_properties[4]*cold_properties[3]*1000, hot_properties[4]*hot_properties[3]*1000)
    C_max = max(cold_properties[4]*cold_properties[3]*1000, hot_properties[4]*hot_properties[3]*1000)
    C_r = C_min/C_max
    n_canal = round(dimensions[2]/(exchanger_properties[0]+exchanger_properties[1]))
    print(f"n_canal is {n_canal}")
    A_parois = n_canal * dimensions[0] * dimensions[1] #aire totale de toutes les aires d'échange entre les canaux
    NTU = U * A_parois / C_min
    efficiency = 1 - 2.718**((1/C_r)*(NTU**0.22)*(2.718**(-C_r*(NTU**0.78))-1))     #Efficiency of cross-flow exchanger
                                                                                    #when the fluids aren't mixed
    vitesse_cold, vitesse_hot = 2*cold_properties[4]/(cold_properties[1]*dimensions[0]*dimensions[2]), 2*hot_properties[4]/(hot_properties[1]**dimensions[0]*dimensions[2])
    
    speed_hot = hot_properties[4]/(hot_properties[1]*dimensions[0]*dimensions[2])
    #print(f"Speed hot is {speed_hot}")
    speed_cold = cold_properties[4]/(cold_properties[1]*dimensions[0]*dimensions[2])
    #print(f"Speed cold is {speed_cold}")
    q = efficiency*q_max
    T_cold_out = q/(cold_properties[4]*cold_properties[3]*1000) + T_cold_in
    T_hot_out = -q/(hot_properties[4]*hot_properties[3]*1000) + T_hot_in
    
    #print(f"The EFFICIENCY of the CROSS FLOW HEAT EXCHANGER de volume {volume}m^3 is {efficiency*100} % and returns the following parameters")
    #print(f"Hydraulic diameter = {D_h} \nNusselt = {Nu} \nh_hot = {h_hot}, h_cold = {h_cold}")
    #print(f"R_tot_surf = {R_tot_surf} \nU = {U} \n Nombre de canaux = {n_canal}, Aire totale des parois = {A_parois}")
    #print(f"C_min = {C_min}, C_max = {C_max}, C_r = {C_r} \nNTU = {NTU}")
    #print(f"vitesse froide = {vitesse_cold}, vitesse chaude = {vitesse_hot}")
    #print(f"q = {q}")
    #print(f"T_cold_out = {T_cold_out}, T_hot_out = {T_hot_out}")
    #print(f"EFFICIENCY = {efficiency}")
    return efficiency, T_hot_out, T_cold_out

def conduc_air(temperature):
    return (18.1+0.075*(temperature-200))*10**(-3)





def itération_températuresortie_crossflow(T_cold_in, T_hot_in, q_max, amount_iterations=5, dimensions=(1, 1, 1.5), cold_properties=(284, 1.23, 17.6*10**(-6), 1.007, 1.15, 25.02*10**(-3)), hot_properties=(487, 0.717, 26.5*10**(-6), 1.019, 3.43, 39.8*10**(-3)), exchanger_properties=(0.0045, 0.0005, 205)):
    T_hot_out, T_cold_out = T_cold_in, T_hot_in
    for i in range(amount_iterations):
        efficiency, T_hot_out, T_cold_out = calc_eff_crossflow(T_cold_in, T_hot_in, dimensions, cold_properties, hot_properties, exchanger_properties, q_max, T_hot_out, T_cold_out)
        print(f"EFFICIENCY AT {i}th iteration: {efficiency}")
    return efficiency

nb_cannal = np.linspace(10, 272, 3000)


epsilon_nb_cannal = []

for canal in tqdm(nb_cannal):
    epsilon_nb_cannal.append(itération_températuresortie_crossflow(np.min(temp_ext)+273.15, temp_hot+273.15, np.mean(qmax)/(3600 * 24), exchanger_properties=(1.5/canal, 0.0005, 205), amount_iterations=15))



fig = plt.figure(figsize=(12, 8))
plt.plot(nb_cannal, epsilon_nb_cannal, "-", linewidth=2.5, color="black")
plt.xlabel("Nombre de canaux", fontsize=22)
plt.ylabel(r"$\epsilon$", fontsize=26)  
plt.tick_params(labelsize=22)
plt.savefig("epsilon_vs_nb_cannal.pdf", dpi=600)
plt.show()




epsilon = []

for i, temp in enumerate(temp_ext):
    epsilon.append(itération_températuresortie_crossflow(temp+273.15, temp_hot+273.15, qmax[i]/(3600 * 24), exchanger_properties=(1.5/272, 0.0005, 205), amount_iterations=15))

print(f"minimum epsilon is {np.min(epsilon)}, maximum epsilon is {np.max(epsilon)}")
fig, ax = plt.subplots(figsize=(12, 8))

ax.plot(data_linspace, epsilon, "-", linewidth=2.5, color="black")
ax.set_xlabel("Mois de l'année", fontsize=22)
ax.set_ylabel(r"$\epsilon$", fontsize=26)
ax.tick_params(labelsize=22)
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m'))
ax.set_xlim([datetime.date(2022, 1, 1), datetime.date(2022, 12, 31)])
plt.savefig("epsilon_vs_date.pdf", dpi=600)
plt.show()


q = np.array(epsilon) * qmax
q_cumsum_gj = np.cumsum(q/(10**(9)))
money_saved = q_cumsum_gj * 7.32

fig, ax = plt.subplots(figsize=(12, 8))

ax.plot(data_linspace, money_saved, "-", linewidth=2.5, color="black")
ax.set_xlabel("Mois de l'année", fontsize=22)
ax.set_ylabel("Économie cumulative [$]", fontsize=22)
ax.tick_params(labelsize=22)
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m'))
ax.set_xlim([datetime.date(2022, 1, 1), datetime.date(2022, 12, 31)])
plt.savefig("money_saved_vs_date_real.pdf", dpi=600)
plt.show()



q_true = np.array(epsilon) * qmax

ges_saved = (q_true/(10**(9))) * 26.217

print(f"Total ges saved is {np.sum(ges_saved)}")