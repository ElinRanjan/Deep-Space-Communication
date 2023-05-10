%% Optical Link parameters

fc = 300e12;    %Optical band 190-500THz
lambda = physconst('LightSpeed')/fc;
k = 2*pi/lambda; %wave number of carrier


%% Tunable parameters are

% SEP, (0.19-0.8 degree)
% p, Non-Kolmogorov spectral index (3.4-4)
% n, Relative solar wind density fluctuation factor (0.05-0.2)
% l_0, Turbulence outer scale (1e7 - 7e7 m)


%% Non-Kolmogorov for optical communication
% From paper https://www.osapublishing.org/oe/fulltext.cfm?uri=oe-27-9-13344&id=409364
% Only models situation during superior solar conjunction, mars is oposite
% to the sun


re = 2.82e-15; %Classical electron radius


% Link distance related parameter
Lse = 1.5e11; % earth to sun distance in m
Lsp = 1.5*Lse; %probe(mars) to sun distance in m

% Very sensitive to SEP
SEP = 0.23; %alpha - SEP angle in degree 0.225-0.8 range
SPE = 0.5; %beta - SPE angle in degree


L = Lse*cos(deg2rad(SEP)) + Lsp*cos(deg2rad(SPE)); %Link disrance in m


% Electron density fluctuation
R_sun = 6.96e8; %Solar radius in m
r = Lse*sin(deg2rad(SEP)); % distance between Sun and communication link
Ne = 4e14*(R_sun/r)^10 + 3e14*(R_sun/r)^6; 



p = 3.5 ; %Non-Kolmogorov spectral index p (3.4 - 4) 
l_0 = 3.5e7 ; %Turbulence outer scale (1e7 m < l_o < 7e7 m)
n = 0.15 ; %Relative solar wind density fluctuation factor(5% < η < 20%)



% ksi Index
ksi = - ((p-3)*gamma(p/2)*re^2*(2*pi)^(5.5-p)*pi*n^2*Ne^2*...
    l_0^(3-p)*L^(p/2)*k^(-(p/2)-1)*sec(pi*p/4))/(8*gamma((p-1)/2)*gamma(1+p/2));

% Scintilation index m
m = sqrt(4*ksi); %For valid result 0<m<0.5
K = sqrt(1-m^2)/(1-sqrt(1-m^2));

%% Pathloss
% Link distance L, from upper section

% Pathloss in dB
PathLoss = fspl(L,lambda);


%% Fading Parameters
NumPath = 10;
PathDelays = linspace(0,1,NumPath)*1e-1; %Unpredictable, Less than 1e-8 makes things nasty
PathLosses = linspace(1,1.1,NumPath)*(-PathLoss);






















