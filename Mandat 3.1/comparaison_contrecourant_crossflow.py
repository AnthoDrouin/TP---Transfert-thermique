import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm


def epsilon_cross_flow(NTU, Cr):
    return 1 - np.exp((1/Cr)*(NTU)**(0.22) * (np.exp(-Cr*(NTU)**(0.78)) - 1))

def epsilon_counter_flow(NTU, Cr):
    return (1-np.exp(-NTU*(1-Cr)))/(1-Cr*np.exp(-NTU*(1-Cr)))

def epsilon1(NTU, Cr):
    return 2*((1+Cr+(1+Cr**2)**0.5) * (1+np.exp(-(NTU)*(1+Cr**2)**(0.5)))/(1-np.exp(-(NTU)*(1+Cr**2)**(0.5))))**(-1)

def epsilon_shell_tube(NTU, Cr, n):
    epsilon_1 = epsilon1(NTU, Cr)
    return (((1 - epsilon_1 * Cr)/(1 - epsilon_1))**(n) - 1)*(((1-epsilon_1*Cr)/(1-epsilon_1))**(n) - Cr)**(-1)


NTU = np.linspace(0, 10, 10000)
Cr = 0.335




epsilon_counter = []
epsilon_cross = []
epsilon_n4 = []
#epsilon_n10 = []
#epsilon_n100 = []

for ntu in tqdm(NTU):
    epsilon_counter.append(epsilon_counter_flow(ntu, Cr))
    epsilon_cross.append(epsilon_cross_flow(ntu, Cr))
    epsilon_n4.append(epsilon_shell_tube(ntu, Cr, 2))
    #epsilon_n10.append(epsilon_shell_tube(ntu, Cr, 10))
    #epsilon_n100.append(epsilon_shell_tube(ntu, Cr, 100))


plt.style.use("https://raw.githubusercontent.com/dccote/Enseignement/master/SRC/dccote-errorbars.mplstyle")

fig = plt.figure(figsize=(12, 8))

plt.plot(NTU, epsilon_counter, "-", label="Contre courant", linewidth=2.5, color="black")
plt.plot(NTU, epsilon_cross, "--", label="Flux croisés", linewidth=2.5, color="black")
#plt.plot(NTU, epsilon_n4, "-.", label="n = 2", linewidth=2.5, color="black")
#plt.plot(NTU, epsilon_n10, ":", label="n = 10", linewidth=2.5, color="black")
#plt.plot(NTU, epsilon_n100, "-.", label="n = 100", linewidth=2.5, color="black")
plt.legend(frameon=False, fontsize=22)
plt.xlabel("NTU", fontsize=22)
plt.ylabel(r"$\epsilon$", fontsize=22)
plt.xticks(fontsize=22)
plt.yticks(fontsize=22)
plt.savefig("epsilon_diff.pdf", dpi=600)
plt.show()



