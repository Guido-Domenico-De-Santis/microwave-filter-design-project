# microwave-filter-design-project
Microwave filter design project 
This repository contains my work on microwave filter design, focusing on low-pass filters implemented with transmission lines. The project combines classical filter theory (lumped-element prototypes) with distributed implementations using Richards' transformation and Kuroda identities, plus EM verification.

## Goals

- Design and analyze microwave filters (e.g., 5th-order Chebyshev/Butterworth LPFs).
- Meet specific specs such as:
  - Cutoff frequency around 3 GHz
  - Passband ripple (e.g. 0.5 dB)
  - Target attenuation (e.g. ≥ 15 dB at 4.5 GHz)
- Convert lumped-element prototypes to transmission-line implementations using:
  - Richards' transformation
  - Kuroda identities
- Implement and simulate the final design in ADS (schematic + Momentum/EM).
- Document the full workflow for future reference and reuse.
