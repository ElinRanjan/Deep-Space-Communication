
preamble = (1+barker())/2;  % Length 13, unipolar
msg = zeros(msgLen,1);
for idx = 1 : numFrames
    payload = randi([0 M-1],frameLen-barker.Length,1);
    msg((idx-1)*frameLen + (1:frameLen)) = [preamble; payload];
end