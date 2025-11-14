clear all; close all; 
%% Setup
fs = 44100; % Define Sample Rate

x = zeros(5 * fs,1);

x(1,1) = 1;
[x,fs] = audioread("04 Song For The Dead.m4a");
T = 1/fs; % Length of Single Sample
L = 20; % Length of Simulation
N = L * fs; % Number of Samples in Simulation
y = zeros(L*fs,1);

maxDelayLengthSeconds = 10;
maxDelayLength = maxDelayLengthSeconds * fs;
sDelms = 20;
sDelBaseFloat = sDelms * (fs/1000);
sDelFloat = 0;
sDel = floor(sDelBaseFloat);
frac = sDelBaseFloat - sDel;
cBuf = zeros(maxDelayLength, 1);

write = 1;

readOut = 0;
read1Out = 0;


read = write - sDel + maxDelayLength;
readNext = 0; 
readFrac = 0;

eta = 0;
ap_temp = 0;
yOut = 0;


LFO = 0;
depth = 600;
phase = 0;
offset = 0;
rate = 0.5;


for n = 1:N

   

    output(n,1) = LFO;
    cBuf(write) = x(n);

    LFO = sDelBaseFloat +( sin(phase) * depth);
    readFrac = mod(write - LFO, maxDelayLength); 
    read = floor(readFrac);


    frac = readFrac - read;
    frac = max(0.001, min(0.999, frac));

    etaTarget = (1 - frac) / (1 + frac);
    alpha = 0.001;             
    eta = alpha * etaTarget + (1 - alpha) * eta;


    fraclog(n) = frac;
        
      
    
    read = read + 1;
    if read > maxDelayLength
        read = read - maxDelayLength;
    elseif read < 1
        read = read + maxDelayLength;
    end


    readNext = read + 1;
    if readNext > maxDelayLength
        readNext = 1;
    end

    % All Pass
    %ap_temp = cBuf(read1) + (eta * (cBuf(read) - ap_temp));
   
    %ap_temp = (eta * (cBuf(read) - ap_temp)) + cBuf(read1);

    readOut = cBuf(read);
  

   
 


   
    % y(n) = eta * (cBuf(read) - yOut) + cBuf(readNext);
    % yOut = y(n);

    x0 = cBuf(read);
    x1 = cBuf(readNext);
    y(n) = x0 + frac * (x1 - x0);

    %y(n) = eta * (readOut - yOut) + read1Out;
    
    %read1Out = readOut;
   

  
    etalog(n) = eta; 

   

   
    
    write = write + 1;
    if write > maxDelayLength
        write = 1;
    end 


    phase = phase + 2*pi*rate*T;
    if phase > 2*pi
        phase = phase - 2*pi;
    end

    y(n) = 0.5*y(n);

   
end


stem(y);
% 
%figure(2);
% plot(linspace(0,fs,length(y)),20*log10(abs(fft(y))))
soundsc(y,fs);


figure(2);
plot(fraclog);


