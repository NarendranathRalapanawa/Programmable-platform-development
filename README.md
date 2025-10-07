🔹 1. What is a “programmable metasurface”?

A metasurface is like an artificial surface made of many small “pixels” (we call them meta-atoms or unit cells).

Each pixel can change how it interacts with electromagnetic waves (like phase, amplitude, frequency).

If we make these pixels programmable (using electronics like diodes, varactors, MEMS, or FPGA control), we can dynamically change how waves are reflected, transmitted, or absorbed.

👉 Think of it like a digital mirror: instead of only showing your reflection, it can redirect, split, or change the color (frequency) of waves.

Here I am trying to build a programable platform to STMM. When considering more about meta surfaces (here you can find more details about meta structures by refering the note that written by me)[Notes_251003_233927.pdf](https://github.com/user-attachments/files/22711295/Notes_251003_233927.pdf) 

🔹 2. Static vs. Space-Time Programmable Surfaces

Static metasurface → fixed pattern, can bend beams or focus, but once built, it doesn’t change.

Programmable (space-only) → you can electronically change the surface at different positions. For example, change the phase at pixel 1 vs pixel 2 to steer a beam.

Space-time programmable → you also change things with time. For example:

At 1 ns the surface looks one way,

At 2 ns it changes,

At 3 ns it changes again.
This adds a time dimension, letting you do crazy things like frequency shifting or non-reciprocal wave control.

🔹 3. Why code a simulation first?

Before building actual hardware, I made numerical simulations of how waves interact with programmable metasurfaces. 

I defined a metasurface modulation pattern (how the surface changes with space and time).

I multiplied them → meaning the surface applies its modulation to the wave.

Then I visualized what happens.
