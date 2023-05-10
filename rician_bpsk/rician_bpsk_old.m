% Modulator = comm.DBPSKModulator;
% Demodulator = comm.DBPSKDemodulator;
close all;
clear;
clc;
format long;

%% Simulation Parameters

fs = 10000;      % Sample rate (Hz)
sps = 4;         % Samples per symbol
M = 2;           % Modulation order
k = log2(M);     % Bits per symbol

%% Channel Parameters Calculation

OpticalchannelParametersLoader();
%RadiochannelParametersLoader();



%% Message
rng(1993)        % Set seed for repeatable results
barker = comm.BarkerCode(...
    'Length',13,'SamplesPerFrame',13);  % For preamble
msgLen = 1e4;
numFrames = 10;
frameLen = msgLen/numFrames;  
messageGeneration();

%% BPSK Modulation Object
Modulator = comm.PSKModulator('ModulationOrder',M,'PhaseOffset',0);
Demodulator = comm.PSKDemodulator('ModulationOrder',M,'PhaseOffset',0);


%% Channel
%Configure a Rician channel object
chan = comm.RicianChannel(...
    'SampleRate',1e6,...
    'PathDelays',PathDelays,...
    'AveragePathGains',PathLosses,...
    'KFactor',K,...
    'DirectPathDopplerShift',50,...
    'DirectPathInitialPhase',0.5,...
    'MaximumDopplerShift',50,...
    'DopplerSpectrum',doppler('Bell', 8),...
    'RandomStream','mt19937ar with seed', ...
    'Seed',73, ...
    'PathGainsOutputPort',true);

% Findings
% Only Pathdelays messed up the BER, Pathdelays less than 1e-8 produce bad result
% AveragePathGains should be higher for higher PathDelays

% SampleRate greater than 1e5 works well, may be, there is relation between
% msg length and SampleRate

% Lower K value decrease BER

% For debugging purpose
% chan = comm.RayleighChannel('SampleRate',1e6,'MaximumDopplerShift',10);
% fadedSig = chan(chanIn);
% scatterplot(fadedSig);

%% Modulation
chanIn = Modulator(msg);
scatterplot(chanIn);

%% Propagation throught channel
[fadedSig, RicianPathGains] = chan(chanIn);
scatterplot(fadedSig);
release(chan);

%% Removing phase components of path gains
fadedSig = RicianPathGains(:,1).*exp(-1j*angle(fadedSig));
% Nice, it decreases the BER 10 folds

%% Adding AWGN
SNR = 10;
chanOut = awgn(fadedSig,SNR);   % Add Gaussian noise
scatterplot(chanOut);

%% Demodulation
rxData = Demodulator(chanOut);

errorCalc = comm.ErrorRate;
berVec = errorCalc(msg,rxData);
[NumOfErr,BER_bpsk] = symerr(msg, rxData)


%% Compute error rate for different values of SNR.
SNR = -5:1:20; % Range of SNR values, in dB.
numSNR = length(SNR);
BER_bpsk = zeros(1, numSNR);

for n = 1:numSNR
   rxSig = awgn(fadedSig,SNR(n));   % Add Gaussian noise
   rx = Demodulator(rxSig);  % Demodulate
   reset(Demodulator);
   
   % Compute error rate.
   [nErrors, BER_bpsk(n)] = biterr(msg,rx);
end

% Plot BER results.
figure(4);
semilogy(SNR,BER_bpsk,'r*');
legend('Empirical BER');
xlabel('SNR (dB)'); ylabel('BER');
title('BPSK over Rician Fading Channel');











