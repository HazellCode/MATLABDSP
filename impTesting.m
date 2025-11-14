clear all; close all; 
format longE
addpath("modules/"); % make class folders visible to this file
%% Setup
fs = 44100; % Define Sample Rate

x = zeros(0.1 * fs,1);
N = length(x);
L = N / fs;
x(1,1) = 0.5;
T = 1/fs; % Length of Single Sample


y = zeros(L*fs,2);


bufferL = circularIntBuffer(40, 10,fs,1);
bufferR = circularIntBuffer(40, 10,fs,1);
bufferL.setLFO(0.5, 100);
bufferR.setLFO(0.5, 100);

pole = singlePole(0.01);





a = 0.3;
b = 1 - a;
val = 0;


b1 = 500;
sm = 0;


lvl = lvlDetector(-7);
gain = 2;

for n = 1:N

  y(n) = tanh(gain * x(n));

   
end



hold on











