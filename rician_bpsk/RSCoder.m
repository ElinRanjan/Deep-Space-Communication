rng(1993);     % Seed random number generator for repeatable results

CodewordLength = 7;         % RS codeword length
MessageLength = 5;         % RS message length




ECEncoder = comm.RSEncoder('BitInput',true,...
    'CodewordLength',CodewordLength,'MessageLength',MessageLength);
ECDecoder = comm.RSDecoder('BitInput',true,...
    'CodewordLength',CodewordLength,'MessageLength',MessageLength);