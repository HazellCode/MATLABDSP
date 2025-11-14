 clear all; close all; 
addpath(genpath("modules/")); % make class folders visible to this file
%% Setup
fs = 44100; % Define Sample Rate

x = zeros(5 * fs,2);
N = length(x);
L = N / fs;
x(1,:) = 1;
% x(1,2) = 1;
L = 1; % Length of Simulation
% [x,fs] = audioread("OS_AD_95_piano_chords_hieroglyphics_Am.wav");
N = L * fs; % Number of Samples in Simulation
T = 1/fs; % Length of Single Sample


y = zeros(L*fs,2);


bufferL = circularQuadBuffer(315.79, 10,fs,1);
bufferR = circularQuadBuffer(315.79, 10,fs,1);
bufferL.setLFO(0.5, 400);
bufferR.setLFO(0.5, 400);


a = 0.001;
b = 1 - a;
val = 0;

gain = 1;

inputL = 0;
inputR = 0;x
fbL = 0;
fbR = 0;
fb = 0.5;

outL = 0;
outR = 0;

crushLvl = 10;

crushL = bitcrush(crushLvl,fs);
crushR = bitcrush(crushLvl,fs);


dw = 0.5; % 0 = dry - 1 = wet; 

% osL = oversample(4);
% osR = oversample(4);
 
outputFilter = 16000;


outputLPL = biQuad(outputFilter,0.707,fs,"LPF");
outputLPR = biQuad(outputFilter,0.707,fs,"LPF");


for n = 1:N



    inputL = x(n,1) + (fb * fbL);
    inputR = x(n,2) + (fb * fbR);

    bufferL.push(inputL);
    bufferR.push(inputR);    

    % [y(n,1),LFO(n)] = bufferL.processBuffer;
    % [y(n,2),] = bufferR.processBuffer;



    outL = crushL.process(bufferL.processBuffer);
    outR = crushR.process(bufferR.processBuffer);
    % 
    fbL = outL;
    fbR = outR;
    % 
    gain = 4;
    drive = 3.7;

    outL = outL*gain;
    outR = outR*gain;

    % if outL <= -1
    %     outL = -2/3;
    % elseif (-1 >= outL) && (x <= outL)
    %     outL = outL - ((outL^3) / 3);
    % elseif outL >= 1
    %     outL = 2/3;
    % end
    % 
    %  if outR <= -1
    %     outR = -2/3;
    % elseif (-1 >= outR) && (x <= outR)
    %     outR = outR - ((outR^3) / 3);
    % elseif outR >= 1
    %     outR = 2/3;
    % end

    y(n,1) = outputLPL.process(tanh(outL));
    y(n,2) = outputLPR.process(tanh(outR));


    % y(n,:) = outL + (gain * sin(drive*outL));
   

    % y(n,1) = (dw * outL) + ((1 - dw) * inputL);
    % y(n,2) = (dw * outR) + ((1 - dw) * inputR);

end


%stem(y);
% 
figure(2);
plot(y);
% plot(linspace(0,fs,length(y(:,1))),20*log10(abs(fft(y(:,1)))))
%soundsc(y,fs);


%plot(LFO)


% figure(2);
% plot(y(:,1),color="red");
% hold on
% plot(y(:,2),color="green");
% 






