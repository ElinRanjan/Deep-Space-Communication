%% PathLoss Calculation
fc = 8.3e9;    %Ka Band 26.5–40 GHz, X band 8-12 GHz
lambda = physconst('LightSpeed')/fc;
k = 2*pi/lambda; %wave number of carrier


%% Tweakable parameters are
% SEP, (1.4-5 degree)
% l_0, Turbulence outer scale (1e7 - 7e7 m)


%% For Ka and X band channel model
% From paper https://ipnpr.jpl.nasa.gov/progress_report/42-129/129A.pdf
% and "Deep space communication channel characteristics under solar scintillation"
% Tong WU et. el.

% m is very close to 1 for SEP less than 1 degree.
% m falls quickly close to zero within SEP = 1 to 2 degree re = 2.82e-15; %Classical electron radius


% Link distance related parameter
Lse = 1.5e11; % earth to sun distance in m
Lsp = 1.5*Lse; %probe(mars) to sun distance in m

% Very sensitive to SEP
SEP = 1.5; %alpha - SEP angle in degree 1.4-5 range
SPE = 1; %beta - SPE angle in degree

L1 = Lse*cos(deg2rad(SEP));
L2 = Lsp*cos(deg2rad(SPE));
L = L1 + L2; %Link disrance in m


% Electron density fluctuation
R_sun = 6.96e8; %Solar radius in m
r = Lse*sin(deg2rad(SEP)); % distance between Sun and communication link, closed approach
Ne = 4e14*(R_sun/r)^10 + 3e14*(R_sun/r)^6; 


l_0 = 1e11 ; %Turbulence outer scale (1e7 m < l_o < 7e7 m)

a1 = 0.85;
ksi = 0.563*k^(7/6)*sqrt(pi)*a1*r*(L1*L2/L)^(5/6)*(55.59*Ne/(fc^2*l_0^(1/3)))^2;


% Scintilation index m
m = sqrt(4*ksi);
K = sqrt(1-m^2)/(1-sqrt(1-m^2));


%% Pathloss
% Link distance L, from upper section

% Pathloss in dB
PathLoss = fspl(L,lambda);


%% Fading Parameters
NumPath = 10;
PathDelays = linspace(0,1,NumPath)*1e-1; %Unpredictable, Less than 1e-8 makes things nasty
PathLosses = linspace(1,1.1,NumPath)*(-PathLoss);


























