clear all; close all; 
addpath(genpath("modules/")); % make class folders visible to this file
%% Setup
fs = 44100; % Define Sample Rate

x = zeros(4 * fs,2);
N = length(x);
L = N / fs;
x(1,:) = 1;
% x(1,2) = 1;
L = 4; % Length of Simulation%
%[x,fs] = audioread("AudioFiles/SO_SL_90_drum_loop_crimelord.wav");
N = L * fs; % Number of Samples in Simulation
T = 1/fs; % Length of Single Sample


peak = biQuad(150, 0.2, fs, "peak",5);

for n = 1:N

   y(n,1) = peak.process(x(n,1));
   %y(n,1) = x(n,1);


end

plot(linspace(0,fs,length(y)),20*log10(abs(fft(y))))
soundsc(y,fs);