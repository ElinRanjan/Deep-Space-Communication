
%% Parameters
trellis_half = poly2trellis(7,[171 133]); %(7,1/2) conv code %constraint length=7
K = log2(trellis_half.numInputSymbols); % Number of input bit streams
N = log2(trellis_half.numOutputSymbols); % Number of output bit streams