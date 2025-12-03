%% Chebyshev LPF -> Richards -> Kuroda -> all-open-shunt-stub values
clear; clc;

%% 0) Specs
Fp  = 3e9;      % cutoff / passband edge
Ap  = 0.5;      % passband ripple [dB]
Fs  = 4.5e9;    % stopband spec frequency
As  = 15;       % stopband attenuation [dB]
Ord = 5;        % filter order
Z0sys = 50;     % system impedance

%% 1) Lumped Chebyshev LC filter
r = rffilter("FilterType","Chebyshev", ...
             "ResponseType","Lowpass", ...
             "Implementation","LC Pi", ...
             "PassbandFrequency",Fp, ...
             "PassbandAttenuation",Ap, ...
             "StopbandFrequency",Fs, ...
             "StopbandAttenuation",As, ...
             "FilterOrder",Ord);

frequencies = linspace(0,5*Fp,1001);

figure;
rfplot(r,frequencies);
title('Lumped Chebyshev LC filter');

%% 2) Richards transform -> stub network at 3 GHz
txCkt = richards(r,Fp);

disp('--- After Richards (stubs only) ---');
tableCircuitProperties(txCkt,'Name','StubMode','Termination','Z0');

%% 3) First round: insert unit elements, then Kuroda
% Insert 50-ohm lines at input and output
txCktUE = insertUnitElement(txCkt,'C_tx',1,Fp,Z0sys);
txCktUE = insertUnitElement(txCktUE,'C_2_tx',2,Fp,Z0sys);

disp('--- After 1st set of unit elements ---');
tableCircuitProperties(txCktUE,'Name','StubMode','Termination','Z0');

% First Kuroda transformations
txCkt_Kur = kuroda(txCktUE,'C_tx_p1_elem_UE','C_tx');
txCkt_Kur = kuroda(txCkt_Kur,'C_2_tx','C_2_tx_p2_elem_UE');

disp('--- After 1st Kuroda (mixed series/short, shunt/open) ---');
tableCircuitProperties(txCkt_Kur,'Name','StubMode','Termination','Z0');

%% 4) Second round: get all-open-shunt-stub topology (txCkt_Kur2)

% Insert unit elements again at the edges of txCkt_Kur
txCkt_UE2 = insertUnitElement(txCkt_Kur, ...
    'Kuroda2_R2L_of_C_tx_p1_elem_UE', 1, Fp, Z0sys);
txCkt_UE2 = insertUnitElement(txCkt_UE2, ...
    'Kuroda1_L2R_of_C_2_tx_p2_elem_UE', 2, Fp, Z0sys);

disp('--- After 2nd set of unit elements ---');
tableCircuitProperties(txCkt_UE2,'Name','StubMode','Termination','Z0');

% Second Kuroda transformations
txCkt_Kur2 = kuroda(txCkt_UE2, ...
    'Kuroda2_R2L_of_C_tx_p1_elem_UE_p1_elem_UE', ...
    'Kuroda2_R2L_of_C_tx_p1_elem_UE');

txCkt_Kur2 = kuroda(txCkt_Kur2, ...
    'Kuroda2_R2L_of_C_tx', 'L_tx');

txCkt_Kur2 = kuroda(txCkt_Kur2, ...
    'Kuroda1_L2R_of_C_2_tx_p2_elem_UE', ...
    'Kuroda1_L2R_of_C_2_tx_p2_elem_UE_p2_elem_UE');

txCkt_Kur2 = kuroda(txCkt_Kur2, ...
    'L_1_tx', 'Kuroda1_L2R_of_C_2_tx');

disp('--- Final all-open-shunt-stub topology (txCkt_Kur2) ---');
tableCircuitProperties(txCkt_Kur2,'Name','StubMode','Termination','Z0');

%% 5) Values to copy into ADS (Z0 and θ at 3 GHz)
fprintf('\n=== Elements for ADS (Z0 and electrical length at 3 GHz) ===\n');
for k = 1:numel(txCkt_Kur2.Elements)
    el      = txCkt_Kur2.Elements(k);
    name    = txCkt_Kur2.ElementNames{k};
    Z0      = el.Z0;
    theta_d = el.ElectricalLength * 180/pi;  % radians -> degrees

    fprintf('%2d: %-60s  Z0 = %7.3f Ω,  θ = %6.2f°  (%s, %s)\n', ...
        k, name, Z0, theta_d, el.StubMode, el.Termination);
end
