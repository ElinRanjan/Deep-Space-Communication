% clc;
% clear;

% With BPSK 
%% Simulation Parameters
fs = 1e6;           % Sample rate (Hz)
sps = 4;            % Samples per symbol
M = 2;              % Modulation order
bps = log2(M);        % Bits per symbol

%% Add preambles to each frame
%which are used later when performing phase 
%ambiguity resolution. Generate random data symbols, and apply QPSK modulation.
rng(1993)        % Set seed for repeatable results

barker = comm.BarkerCode(...
    'Length',13,'SamplesPerFrame',13);  % For preamble


msgLen = 1.5e4;
numFrames = 10;
frameLen = msgLen/numFrames;  


messageGeneration();    %in msg array
%% Error Correction Code (Turbocode)
%turboCoder();
%BCHCoder();
RSCoder();          %msgLen must be multiple of 15


encodedData = ECEncoder(msg);
%% Creating different System Objects
SystemObjectsCreation();

%% Modulation
modSig = Modulator(encodedData);

%% Channel Propagation
[fadedSig, RicianPathGains] = chan(modSig);

SNR = 1;
rxSig = awgn(fadedSig,SNR);
% scatterplot(rxSig)

%% Compensation
syncCoarse = coarse(rxSig);
syncSignal = carrierSync(syncCoarse);

%% Demodulation
rxData = Demodulator(syncSignal);

%% Error Correction Decoding
%rxData = ECDecoder(2*rxData-1);     %Only for Turbo Coder
rxData = ECDecoder(rxData);

reset(ECDecoder);
%% BER Calculation before phase compensation
%ErrorRate = comm.ErrorRate('ComputationDelay',3,'ReceiveDelay', 34);
%ErrorRate(msg,rxData)

[ErrorWithoutPhsComp,BERWithoutPhsComp] = biterr(msg,rxData)


%% Phase Compensation
% Phase ambiguity in the received signal might cause bit errors. 
% Using the preamble, determine phase ambiguity. 
% Remove this phase ambiguity from the synchronized signal to reduce bit
% errors.
phaseOffsetCalculation()
rxSigComp = exp(1i*MeanphsOffset) * syncSignal;

%% BER Calculation after phase compensation
rxDataComp = Demodulator(rxSigComp);

%rxDataComp = ECDecoder(2*rxDataComp-1);     %Only for Turbo Coder
rxDataComp = ECDecoder(rxDataComp);
reset(ECDecoder);

[ErrorsAfterPhsComp, BERAfterPhsComp] = biterr(msg,rxDataComp)


%% Compute error rate for different values of SNR.
SNR = -5:1:20; % Range of SNR values, in dB.
numSNR = length(SNR);
BER_bpsk = zeros(1, numSNR);

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
   [nErrors, BER_bpsk(n)] = biterr(msg,rxDataComp);
end

berCurveFit = berfit(SNR,BER_bpsk,SNR);
% Plot BER results.
figure(1);
% semilogy(SNR,BER_bpsk,'b*');hold on;
semilogy(SNR,berCurveFit);hold on
legend('Empirical BER');
xlabel('SNR (dB)'); ylabel('BER');
title('BPSK over Rician Fading Channel');
grid;


save('BER_RS.mat','berCurveFit')


%% Comparision
bch = load('BER_bch.mat').berCurveFit;
turbo = load('BER_turbo.mat').berCurveFit;
RS = load('BER_RS.mat').berCurveFit;


% figure(2);
% semilogy(SNR,bch);hold on;
% xlabel('SNR (dB)'); ylabel('BER');
% title('BPSK over Rician Fading Channel With BCH ECC');
% grid;
% 
% figure(3);
% semilogy(SNR,turbo);hold on;
% xlabel('SNR (dB)'); ylabel('BER');
% title('BPSK over Rician Fading Channel With Turbo ECC');
% grid;

figure(4)
semilogy(SNR,RS);hold on;
xlabel('SNR (dB)'); ylabel('BER');
title('BPSK over Rician Fading Channel With RS(7,5) ECC');
grid;

% legend('BCH','Turbo','RS(7,5)');
% xlabel('SNR (dB)'); ylabel('BER');
% title('BPSK over Rician Fading Channel With differen ECC');
% grid;


