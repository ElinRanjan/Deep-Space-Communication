phsOffsets = zeros(1,numFrames);
for i = 1 : numFrames
    idx = (i-1)*frameLen + (1:barker.Length); 

    phOffset = angle(modSig(idx) .* conj(syncSignal(idx)));
    phsOffsets(1,i) = mean(phOffset);
    %phOffset = round((2/pi) * phOffset); % -1, 0, 1, +/-2
    %phOffset(phOffset==-2) = 2; % Prep for mean operation
    %phsOffsets(1,i) = mean((pi/2) * phOffset); % -pi/2, 0, pi/2, or pi
end
MeanphsOffset = mean(phsOffsets);
%disp(['Estimated mean phase offset = ',num2str(MeanphsOffset*180/pi),' degrees'])