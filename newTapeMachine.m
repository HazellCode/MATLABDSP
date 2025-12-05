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

bpm = 90;
ms = 60000 / bpm; % quarter note


[x,fs] = audioread("AudioFiles/newsnare.wav");
N = L * fs; % Number of Samples in Simulation
T = 1/fs; % Length of Single Sample

y = zeros(fs * L, 2);


bufferL = circularQuadBuffer(ms,10,fs,1);
bufferR = circularQuadBuffer(ms,10,fs,1);
feedbackbufferL = circularQuadBuffer(ms/4, 5, fs, 1);
feedbackbufferL.setLFO(0.2, 400);
feedbackbufferR = circularQuadBuffer(ms/4, 5, fs, 1);
feedbackbufferR.setLFO(0.2, 400);

preL = biQuad(200, 0.2,fs,"peak",2);
preR = biQuad(200, 0.2,fs,"peak",2);
preLout = 0;
preRout = 0;
% 
bufferL.setLFO(0.5,100);
bufferR.setLFO(0.5,100);

bicL = bitcrush(16, fs);
bicR = bitcrush(16, fs);

inL = 0;
inR = 0;

pregain = 1;
postgain = 1;
% Block Diagram as of 14th November 2025

%x (mix in fb) - > pre emphasis -> soft soft -> circular buffer (fb output as well)-> Bitcrush ->
%saturation -> lowpass -> output 

fbL = 0;
fbR = 0;

fb_mix = 0.8;



dw = 0.5;

 
outputFilter = 10000;


outLPL = biQuad(outputFilter,0.707,fs,"LPF",0);
outLPR = biQuad(outputFilter,0.707,fs,"LPF",0);


% comb = combFilter(1678,0.05, fs);
% comb1 = combFilter(2083,0.05, fs);
% apf = APF(round(0.0025*fs),0.3);
% apf1 = APF(round(0.0025*fs),0.3);


fbOut = 0;
fBDir = 0;

rt60 = 0.1;


comb = combFilter(1693, rt60, fs);
comb1 = combFilter(2083, rt60, fs);
comb2 = combFilter(1609, rt60, fs);
comb3 = combFilter(2089,rt60, fs);
comb4 = combFilter(1709, rt60, fs);
comb5 = combFilter(2039, rt60, fs);
comb6 = combFilter(1523, rt60, fs);
comb7 = combFilter(2063, rt60, fs);
APF1 = APF(round(0.005 * fs),0.5);
APF2 = APF(round(0.004 * fs),0.5);
APF3 = APF(round(0.009 * fs),0.5);
APF4 = APF(round(0.008 * fs),0.5);


outputNotchL = biQuad(600, 0.707,fs,"HPF",0);
outputNotchR = biQuad(600, 0.707,fs,"HPF",0);

Notch250L = biQuad(250, 0.33, fs, "notch",-13);
Notch250R = biQuad(250, 0.33, fs, "notch",-13);

Notch2300L = biQuad(2300, 0.41, fs, "notch",-5);
Notch2300R = biQuad(2300, 0.41, fs, "notch",-5);

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

    APF1inout = (outL/2);
    APF2inout = (outR/2);
    c0out = comb.process(APF1inout);
    c1out = comb1.process(APF1inout);
    c2out = comb2.process(APF1inout);
    c3out = comb3.process(APF1inout);

    c4out = comb4.process(APF2inout);
    c5out = comb5.process(APF2inout);
    c6out = comb6.process(APF2inout);
    c7out = comb7.process(APF2inout);

    APFout = APF1.process((c0out + c1out + c2out + c3out) /4);
    APF2out = Notch250L.process(outputNotchL.process(APF2.process(APFout)));

    APF3out = APF3.process((c4out + c5out + c6out + c7out) /4);
    APF4out = Notch250L.process(outputNotchL.process(APF4.process(APF3out)));

   
    filterL(n,1) = APF2out;
    filterR(n,1) = APF4out;

   
    

    feedbackbufferL.push(APF2out);
    feedbackbufferR.push(APF4out);

    fbL = feedbackbufferL.processBuffer;
    fbR = feedbackbufferR.processBuffer;

    outL = tanh(bicL.process(outL)*postgain);
    outR = tanh(bicR.process(outR)*postgain);

        
    y(n,1) = (dw * outLPL.process(outL)) + (1 - dw) * x(n,1);
    y(n,2) = (dw * outLPR.process(outR)) + (1 - dw) * x(n,2);
    % % 
    % y(n,1) = filterL(n,1);
    % y(n,2) = filterR(n,1);
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
