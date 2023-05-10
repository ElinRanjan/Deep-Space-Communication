clc;
clear;

%%%
% With QPSK 
%% Simulation Parameters
fs = 1e6;      % Sample rate (Hz)
sps = 4;         % Samples per symbol
M = 4;          % Modulation order
bps = log2(M);     % Bits per symbol


%% Channel parameter Loader
OpticalchannelParametersLoader();

%% Add preambles to each frame
%which are used later when performing phase 
%ambiguity resolution. Generate random data symbols, and apply QPSK modulation.
rng(1993)        % Set seed for repeatable results
barker = comm.BarkerCode(...
    'Length',13,'SamplesPerFrame',13);  % For preamble

msgLen = 1.5e3;
numFrames = 10;
frameLen = msgLen/numFrames;  
messageGeneration();

%% Error Correction Code
%turboCoder();       %Works with M = 2
%BCHCoder();


RSCoder();
encodedData = ECEncoder(msg);

%% Creating System Objects
SystemObjectsCreation();

%% Modulation
modSig = Modulator(encodedData);

%% Channel Propagation
[fadedSig, RicianPathGains] = chan(modSig);

SNR = 10;
rxSig = awgn(fadedSig,SNR);
scatterplot(rxSig)


%% Compensation
syncCoarse = coarse(rxSig);
syncSignal = carrierSync(syncCoarse);


%% Demodulation
rxData = Demodulator(syncSignal);

%% Error Correction Decoding

% rxData = ECDecoder(2*rxData-1);     %Only for Turbo Coder
rxData = ECDecoder(rxData);

%% BER Calculation
[ErrorWithoutPhsComp,BERWithoutPhsComp] = biterr(msg,rxData)


%% Phase Compensation
% Phase ambiguity in the received signal might cause bit errors. 
% Using the preamble, determine phase ambiguity. 
% Remove this phase ambiguity from the synchronized signal to reduce bit
% errors.

phaseOffsetCalculation()
rxSigComp = exp(1i*MeanphsOffset) * syncSignal;




%% BER Calculation
rxDataComp = Demodulator(rxSigComp);

% rxDataComp = ECDecoder(2*rxDataComp-1);     %Only for Turbo Coder
rxDataComp = ECDecoder(rxDataComp);

[ErrorsAfterPhsComp, BERAfterPhsComp] = biterr(msg,rxDataComp)




%% Compute error rate for different values of SNR.
SNR = -5:1:20; % Range of SNR values, in dB.
numSNR = length(SNR);
BER_qpsk = zeros(1, numSNR);

for n = 1:numSNR
    rxSig = awgn(fadedSig,SNR(n));
    syncCoarse = coarse(rxSig);
    syncSignal = carrierSync(syncCoarse);
     
    phaseOffsetCalculation()
    rxSigComp = exp(1i*MeanphsOffset) * syncSignal;
    rxDataComp = Demodulator(rxSigComp); % Demodulate
    
    %rxDataComp = ECDecoder(2*rxDataComp-1);     %Only for Turbo Coder
    rxDataComp = ECDecoder(rxDataComp);
    
    
    reset(Demodulator);
    reset(carrierSync);
    reset(coarse);
    reset(ECDecoder);
   
   % Compute error rate.
   [nErrors, BER_qpsk(n)] = biterr(msg,rxDataComp);
end

% Plot BER results.
figure(4);
plot(SNR,BER_qpsk,'b*');
legend('Empirical BER');
xlabel('SNR (dB)'); ylabel('BER');
title('QPSK over Rician Fading Channel');
grid;


