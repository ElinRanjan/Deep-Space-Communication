close all;
clear;
format long;
%% Channel Parameters Calculation
OpticalchannelParametersLoader();

%% GMSK Modulation
sps = 2;        %Sample per symbol
Modulator = comm.GMSKModulator('BitInput', true,'SamplesPerSymbol',sps,...
                'InitialPhaseOffset', 0);
Demodulator = comm.GMSKDemodulator('BitOutput', true, 'SamplesPerSymbol',sps,...
                'InitialPhaseOffset', 0);
                
            
% Error rate calculator, account for the delay caused by the Viterbi algorithm
ErrorRate = comm.ErrorRate('ReceiveDelay', Demodulator.TracebackDepth);

%Message
n = 1e4;
msg = randi([0 1],n,1);

%Generate a random GMSK signal
chanIn = Modulator(msg);
scatterplot(chanIn);

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

[fadedSig, RicianPathGains] = chan(chanIn);
scatterplot(fadedSig);
release(chan);

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

%% Removing phase components of path gains
fadedSig = conj(RicianPathGains(:,1).*exp(-1j*angle(fadedSig)));
% Dunno, but conjugating the fadedSig works like magic

%% Add AWGN
SNR = 10;
chanOut = awgn(fadedSig,SNR);   % Add Gaussian noise
scatterplot(chanOut);

%% Demodulation
rxData = Demodulator(chanOut);

ErrorRate(msg, rxData);
errorStats = ErrorRate(msg, rxData);
fprintf('Error rate = %f\nNumber of errors = %d\n', ...
  errorStats(1), errorStats(2))
%% Compute error rate for different values of SNR.
SNR = -5:1:20; % Range of SNR values, in dB.
numSNR = length(SNR);
BER_gmsk = zeros(1, numSNR);

for n = 1:numSNR
   rxSig = awgn(fadedSig,SNR(n));   % Add Gaussian noise
   rx = Demodulator(rxSig);         % Demodulate
   reset(Demodulator);
   
   % Compute error rate.
   temp = ErrorRate(msg,rx);
   BER_gmsk(1,n) = temp(1);
end

% Plot BER results.
figure(4);
semilogy(SNR,BER_gmsk,'r*');
legend('Empirical BER');
xlabel('SNR (dB)'); ylabel('BER');
title('GMSK over Rician Fading Channel');



%% Compasion between GMSK and BPSK
% semilogy(SNR,BER_gmsk,'r*');hold on;
% semilogy(SNR,BER_bpsk,'r*');
% legend('Empirical BER');
% xlabel('SNR (dB)'); ylabel('BER');
% title('GMSK over Rician Fading Channel');






