close all;
clear;
format long;
%% Channel Parameters Calculation
OpticalchannelParametersLoader();


%% GMSK Modulation
fs = 1e6;
sps = 2;        %Sample per symbol
Modulator = comm.GMSKModulator('BitInput', true,'SamplesPerSymbol',sps,...
                'InitialPhaseOffset', 0);
Demodulator = comm.GMSKDemodulator('BitOutput', true, 'SamplesPerSymbol',sps,...
                'InitialPhaseOffset', 0);
                
            
% Error rate calculator, account for the delay caused by the Viterbi algorithm
ErrorRate = comm.ErrorRate('ReceiveDelay', Demodulator.TracebackDepth);

%Message
msgLen = 1500;
msg = randi([0 1],msgLen,1);

%% Error Correction Code (Turbocode)
%turboCoder();
%BCHCoder();
%ConvolutionalCoder();

RSCoder();

encodedData = ECEncoder(msg);


%% Generate a random GMSK signal
chanIn = Modulator(encodedData);
scatterplot(chanIn);

%% Channel
%Configure a Rician channel object
chan = comm.RicianChannel(...
    'SampleRate',fs,...
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

%% Removing phase components of path gains
fadedSig = conj(RicianPathGains(:,1).*exp(-1j*angle(fadedSig)));
% Dunno, but conjugating the fadedSig works like magic

%% Add AWGN
SNR = 10;
chanOut = awgn(fadedSig,SNR);   % Add Gaussian noise
scatterplot(chanOut);

%% Demodulation
rxData = Demodulator(chanOut);

%% Error Correction Decoding

%rxData = ECDecoder(2*rxData-1);     %Only for Turbo Coder
rxData = ECDecoder(rxData);


%% BER
ErrorRate(msg, rxData);
errorStats = ErrorRate(msg, rxData);
fprintf('Error rate = %f\nNumber of errors = %d\n', ...
  errorStats(1), errorStats(2))
%% Compute error rate for different values of SNR.
SNR = -5:1:20; % Range of SNR values, in dB.
numSNR = length(SNR);
BER_gmsk = zeros(1, numSNR);

for msgLen = 1:numSNR
   rxSig = awgn(fadedSig,SNR(msgLen));   % Add Gaussian noise
   rx = Demodulator(rxSig);         % Demodulate
   
   
   %rxData = ECDecoder(2*rxData-1); %for turbo
   rx = ECDecoder(rx);
   
   
   reset(Demodulator);
   reset(ECDecoder);
   
   % Compute error rate.
   temp = ErrorRate(msg,rx);
   BER_gmsk(1,msgLen) = temp(1);
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






