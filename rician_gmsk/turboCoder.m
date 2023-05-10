%% Parameters
trellis = poly2trellis(4,[13 15],13);
codeword_length = log2(trellis.numOutputSymbols);
mLen = log2(trellis.numStates);
fullOut = (1:(mLen+msgLen)*2*codeword_length)';
outLen = length(fullOut);
netRate = msgLen/outLen;
intIndices  = randperm(msgLen);

%% Encoder
ECEncoder = comm.TurboEncoder('TrellisStructure',trellis);
ECEncoder.InterleaverIndices = intIndices;
ECEncoder.OutputIndicesSource = 'Property';
ECEncoder.OutputIndices = fullOut;


%% Decoder
ECDecoder = comm.TurboDecoder('TrellisStructure',trellis);
ECDecoder.InterleaverIndices = intIndices;
ECDecoder.InputIndicesSource = 'Property';
ECDecoder.InputIndices = fullOut;
