%% Parameters

trellis_half=poly2trellis(7,[171 133]); %(7,1/2) conv code %constraint length=7
K = log2(trellis_half.numInputSymbols); % Number of input bit streams
N = log2(trellis_half.numOutputSymbols); % Number of output bit streams
%K/N=1/2 rate

%% Encoder
ECEncoder = comm.ConvolutionalEncoder('TrellisStructure',trellis_half);

% convenc(msg,trellis_half);


%% Decoder
% tb = 5; %traceback depth (collected: works good for 1/2 rate bleh)
% rxDataComp = vitdec(rxDataComp,trellis_half,tb,'trunc','hard');

ECDecoder = comm.ViterbiDecoder('TrellisStructure',trellis_half,...
    'InputFormat','Hard','TracebackDepth',5);


