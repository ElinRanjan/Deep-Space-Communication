clc, clear, close;
%% Tunable parameters are

% SEP, (0.19-0.8 degree)
% p, Non-Kolmogorov spectral index (3.4-4)
% n, Relative solar wind density fluctuation factor (0.05-0.2)
% l_0, Turbulence outer scale (1e7 - 7e7 m)
%% Main script
l0 = linspace(1e7,7e7,2); %Turbulence outer scale (1e7 m < l_o < 7e7 m)
for i = 1:length(l0)
    assignin('base', 'SEP', 0.23);
    assignin('base', 'l_0', l0(i));
    rician_bpsk_ECC();
end
sep = linspace(0.23,0.8,2);
%%
for i = 1:length(sep)
    assignin('base', 'SEP', sep(i));
    rician_bpsk_ECC();
end
