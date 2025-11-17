clear all; close all; 
addpath(genpath("modules/"));
addpath(genpath("plugins/"));% make class folders visible to this file
%% Setup
fs = 44100; % Define Sample Rate

x = zeros(10 * fs,2);
N = length(x);
L = N / fs;
x(6*fs,:) = 1;
% x(1,2) = 1;
L = 10; % Length of Simulation
[x,fs] = audioread("AudioFiles/CO_PC_100_guitar_acoustic_writerready_Dmaj.wav");
N = L * fs; % Number of Samples in Simulation
T = 1/fs; % Length of Single Sample

y = zeros(fs * L, 2);


bufferL = circularQuadBuffer(600,10,fs,1);
bufferR = circularQuadBuffer(600,10,fs,1);
feedbackbuffer = circularQuadBuffer(300, 5, fs, 1);
feedbackbuffer.setLFO(0.5, 800);

preL = biQuad(200, 0.2,fs,"peak",2);
preR = biQuad(200, 0.2,fs,"peak",2);
preLout = 0;
preRout = 0;
% 
bufferL.setLFO(0.5,100);
bufferR.setLFO(0.5,100);

bicL = bitcrush(8, fs);
bicR = bitcrush(8, fs);

inL = 0;
inR = 0;

pregain = 2;
postgain = 1.2;
% Block Diagram as of 14th November 2025

%x (mix in fb) - > pre emphasis -> soft soft -> circular buffer (fb output as well)-> Bitcrush ->
%saturation -> lowpass -> output 

fbL = 0;
fbR = 0;

fb_mix = 0.2;


dw = 1;

 
outputFilter = 6000;


outLPL = biQuad(outputFilter,0.707,fs,"LPF",0);
outLPR = biQuad(outputFilter,0.707,fs,"LPF",0);





for n = 1:N

    inL = x(n,1) + (fbL * fb_mix);
    inR = x(n,2) + (fbR * fb_mix);
   

    % pre emphasis
    preLout = preL.process(inL);
    preRout = preR.process(inR);


    bufferL.push(tanh(preLout * pregain));
    bufferR.push(tanh(preRout * pregain));

    outL = bufferL.processBuffer;
    outR = bufferR.processBuffer;

    feedbackbuffer.push((outL+outR)/2);
    fbL = feedbackbuffer.processBuffer;
    fbR = fbL;
    outL = tanh(bicL.process(outL)*postgain);
    outR = tanh(bicR.process(outR)*postgain);

        
    y(n,1) = (dw * outLPL.process(outL)) + (1 - dw) * inL;
    y(n,2) = (dw * outLPR.process(outR)) + (1 - dw) * inR;
    % % 
    % y(n,1) = fbL;
    % y(n,2) = fbR;
    % 
    % y(n,1) = x(n,1)+bufferL.processBuffer;
    % y(n,2) = bufferR.processBuffer;

    


end

plot(y(:,1));

% 
% plot(read);
% hold on
% plot(write);


soundsc(y,fs);