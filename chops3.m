clear all; close all;
addpath("modules/"); % make class folders visible to this file
%% Setup
fs = 44100; % Define Sample Rate
% [x,fs] = audioread("TesseracT - War Of Being - 04 Legion.wav");
x = zeros(1 * fs,1);
x(1,1) = 1;
T = 1/fs; % Length of Single Sample
L = 1; % Length of Simulation
N = fs; % Number of Samples in Simulation
y = zeros(L*fs,1);

% os_amount = 10;
% os_store = zeros(1 * (fs * os_amount),1);

%lowPass = singlePole(0.9);


%os = oversample(os_amount,fs);

Q = 0.707;
fc = 500;

w0 = 2 * pi * (fc / fs);
a = sin(w0) / (2 * Q);

a0 = 1 + a;
a1 = -2 * cos(w0);
a2 = 1 - a;
b0 = (1 - cos(w0)) / 2;
b1 = 1 - cos(w0);
b2 = (1 - cos(w0)) / 2;



b0 = b0 / a0;
b1 = b1 / a0;
b2 = b2 / a0;
a1 = a1 / a0; 
a2 = a2 / a0;


x1 = 0;
x2 = 0;
y1 = 0;
y2 = 0;

quad = biQuadCas(8,Q,fc,fs,"HPF");
quad2 = biQuadCas(2,Q,fc+2000,fs,"LPF");
% y_os = zeros(N * os_amount, 1);
% y_os_idx = 1;
% y_os_idx_end = 0;

for n = 1:N

    % pre allocate the output array to be the size of the oversampled array
    % meaning that you don't have to insert zeros inbetween samples but
    % instead insert the samples into the expanded array

    % as n is incrementing up to the size of the array before expanding
    % every sample needs to be written to the (n * os_amount) - 1 sample

    % literally you need to do is
    %   make array of size fs * os_amount
    %   append x(n) to os_store((n * os_amount) - 1)
    %   apply processing
    %   deflate array (inverse of appending)
    %   bosh

    y(n) = quad2.process(quad.process(x(n)));

    % os_store = os.expand(x(n,1));
    % 
    % y_os_idx = (n-1) * os_amount + 1;
    % y_os_idx_end =      n * os_amount;


    % os_store((n * os_amount) - 1, 1) = x(n);
    % for k = 1:os_amount
    %     os_store(n+k,1) = lowPass.process(os_store(n+k,1));
    % end
    
    %y(n) = os_store((n * os_amount) - 1);
    %y(n) = b0 * x(n) + b1 * x1 + b2 * x2 - a1*y1 - a2*y2;
    % 
    % y2 = y1;
    % x2 = x1;
    % y1 = y(n);
    % x1 = x(n);
    % 
    % %y(n) = quad.process(x(n,1));
    % y_os(y_os_idx:y_os_idx_end) = os_store;
    % 
    % % n = 1
    % % n 1 2 3 4
    % y(n) = os.deflate(y_os(y_os_idx:y_os_idx_end));


    
    
end

%plot(os_store);
% hold on
% 
% soundsc(os_store,fs*os_amount);
plot(linspace(0,fs,length(y)),20*log10(abs(fft(y))))

% 
%figure(2)
% 
% plot(linspace(0,fs,length(x)),20*log10(abs(fft(x))))
% plot(y-x(1:441000,1))
