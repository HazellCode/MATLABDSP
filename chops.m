clear all 
close all
%% Setup
fs = 44100; % Define Sample Rate
[x,fs] = audioread("04 Song For The Dead.m4a");
T = 1/fs; % Length of Single Sample
L = 10; % Length of Simulation
N = L * fs; % Number of Samples in Simulation
y = zeros(L*fs,3);

delayTimeMs = 230; 
delaySampels = floor(delayTimeMs * (fs/1000));
ddl = zeros(delaySampels, 2); %stereo delay
ddl_read = 2;
ddl_readdel = ddl_read - 1;
ddl_write = 1;


LFO = 0;
phase = 0;
rate = 1;
frac = 0.5;
depth = 1;
offset = 0; 

read_log = zeros(L*fs,2);

for n = 1:N
    if n == 22050
        continue
    end

    LFO = depth * sin(phase) + offset;
    frac = LFO - floor(LFO);

    y(n,1) = ddl(ddl_read);
    y(n,2) = ddl(ddl_readdel); 
    y(n,3) = ((1 - frac ) * ddl(ddl_read)) + (frac * ddl(ddl_readdel));
    ddl(ddl_write) = x(n);
 
    

    ddl_read = ddl_read + 1;
    ddl_readdel = ddl_readdel + 1;
    ddl_write = ddl_write + 1;

    
    if ddl_read + floor(LFO) > delaySampels
         ddl_read = ((ddl_read + floor(LFO)) - delaySampels);
    elseif ddl_read + floor(LFO) < 0
         ddl_read = ((ddl_read + floor(LFO)) + delaySampels);
    else
        ddl_read = ddl_read + floor(LFO);
    end


    if ddl_readdel + floor(LFO) > delaySampels
         ddl_readdel = ((ddl_readdel + floor(LFO)) - delaySampels);
    elseif ddl_readdel + floor(LFO) < 0
         ddl_readdel = ((ddl_readdel + floor(LFO)) + delaySampels);
    else
        ddl_readdel = ddl_readdel + floor(LFO);
        end



    % if ddl_read > delaySampels
    %     ddl_read = 1;
    % end
    
    if ddl_write > delaySampels
        ddl_write = 1;
    end

    phase = phase + 2*pi*rate*T;
    if phase > 2*pi
        phase = phase - 2*pi;
    end

    LFOlog(n) = floor(LFO);
    fraclog(n) = frac;
    readlog(n) = ddl_read;
  
end

soundsc(y(:,3),fs);
% plot(y(:,1),color="blue")
% hold on
% plot(y(:,3),color="red")
% plot(y(:,2),color="yellow")
%plot(linspace(0,fs,length(y)),20*log10(abs(fft(s1))))

%plot(LFOlog);
hold on
plot(fraclog);
plot(LFOlog);

figure(2)
plot(readlog);


