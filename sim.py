import numpy as np
import matplotlib.pyplot as plt

# Parameters
c = 3e8                     # speed of light
f0 = 10e9                   # carrier frequency (10 GHz)
lambda0 = c / f0
k0 = 2 * np.pi / lambda0     # wave number
omega0 = 2 * np.pi * f0

# Space-time grid
Nx, Nt = 200, 300
x = np.linspace(-5*lambda0, 5*lambda0, Nx)   # space axis
t = np.linspace(0, 5/f0, Nt)                 # time axis
X, T = np.meshgrid(x, t)

# Incident wave (plane wave)
E_inc = np.cos(k0 * X - omega0 * T)

# Programmable metasurface modulation
# Example: sinusoidal modulation in time and space
modulation_frequency = 1e9   # 1 GHz modulation
modulation_wavenumber = k0/2 # half of incident wavevector
modulation = np.cos(modulation_wavenumber * X - 2*np.pi*modulation_frequency * T)

# Output field after metasurface
E_out = E_inc * modulation

# Plot at a snapshot in time
plt.figure(figsize=(10,5))
plt.imshow(E_out[50:150,:], aspect='auto', 
           extent=[x[0]/lambda0, x[-1]/lambda0, t[50]*1e9, t[150]*1e9],
           cmap='jet')
plt.colorbar(label='Field Amplitude')
plt.xlabel('Position (λ0)')
plt.ylabel('Time (ns)')
plt.title('Space-Time Modulated Field Pattern')
plt.show()
