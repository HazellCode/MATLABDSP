clear all 
close all
%% Setup
fs = 44100; % Define Sample Rate


T = 1/fs; % Length of Single Sample
L = 10; % Length of Simulation
x = zeros(L * fs, 1);
x(1,1) = 1;
[x,fs] = audioread("AudioFiles/newsnare.wav");
N = L * fs; % Number of Samples in Simulation
y = zeros(L*fs,3);


rt60 = 0.5;

APFin1 = APF(round(0.04 * fs),0.8);
APFin2 = APF(round(0.03 * fs),0.8);


comb = combFilter(1693, rt60, fs);
comb1 = combFilter(2083, rt60, fs);
comb2 = combFilter(1609, rt60, fs);
comb3 = combFilter(2089,rt60, fs);
comb4 = combFilter(1709, rt60, fs);
comb5 = combFilter(2039, rt60, fs);
comb6 = combFilter(1523, rt60, fs);
comb7 = combFilter(2063, rt60, fs);
comb8 = combFilter(2287, rt60, fs);

APF1 = APF(round(0.005 * fs),0.8);
APF2 = APF(round(0.004 * fs),0.8);
APF3 = APF(round(0.009 * fs),0.8);
APF4 = APF(round(0.008 * fs),0.8);

for n = 1:N
    % APFinout = APFin1.process(x(n,1));
    % APF1inout = APFin2.process(APFinout);

    APF1inout = x(n,1);
        
    c0out = comb.process(APF1inout);
    c1out = comb1.process(APF1inout);
    c2out = comb2.process(APF1inout);
    c3out = comb3.process(APF1inout);
    c4out = comb4.process(APF1inout);
    c5out = comb5.process(APF1inout);
    c6out = comb6.process(APF1inout);
    c7out = comb7.process(APF1inout);
    c8out = comb8.process(APF1inout);
    
    APFout = APF1.process((c0out + c1out + c2out + c3out) /4);
    APF2out = APF2.process(APFout);
    APF3out = APF3.process(APF2out);
    APF4out = APF4.process(APF3out);
    y(n,1) = APF4out;
  
end

plot(y(:,1))
soundsc(y(:,1),fs);
