clear all 
close all
%% Setup
fs = 44100; % Define Sample Rate
%[x,fs] = audioread("04 Song For The Dead.m4a");
x = zeros(1 * fs,1);
x(1,1) = 1;
T = 1/fs; % Length of Single Sample
L = 10; % Length of Simulation
N = L * fs; % Number of Samples in Simulation
y = zeros(L*fs,3);

delayTimeMs = 230; 
delaySampels = floor(delayTimeMs * (fs/1000));
ddl_length = 10 * fs;
ddl = zeros(ddl_length, 2); %stereo delay 10 second buffer
ddl_read = ddl_length - delaySampels;
ddl_readdel = ddl_read - 1;
ddl_write = 1;

ddl_wread = ddl_length - delaySampels;
ddl_wreaddel = ddl_read - 1;
frac = 0.5;
eta = (1 - frac) / (1 + frac);


LFO = 0;
phase = 0;
rate = 0;
frac = 0;
depth = 0.1;
offset = 0; 

ap_g = 0.7;
ap_temp = 0;
ap_eta = 0.5;

read_log = zeros(L*fs,2);
wait = 0;


for n = 1:N


   
    LFO = depth * sin(phase) + offset;
   


    y(n,1) = ddl_wread;
    y(n,2) = ddl_wreaddel;
    y(n,4) = ddl_write;
    y(n,6) = LFO;
    y(n,5) = frac;

    
    ddl_wread = floor(ddl_read);
    ddl_wreaddel = floor(ddl_readdel);
    frac = ddl_read - ddl_wread;
    ap_eta = (1-frac) / (1+frac);
    ddl(ddl_write) = x(n,1);
    
    

    %y(n,3) = ((1 - frac ) * ddl(ddl_wread)) + (frac * ddl(ddl_wreaddel)); %linear interpolator
    

    % temp_b0_AP4 = ap_b0_3_out + ap_b0_4_g * ap_b0_4(ap_b0_4_idx);
    % ap_b0_4_out = -ap_b0_4_g * temp_b0_AP4 + ap_b0_4(ap_b0_4_idx);
    % ap_b0_4(ap_b0_4_idx) = temp_b0_AP4;



    ap_temp = eta * (ddl(ddl_read) - ap_temp) + ddl(ddl_wreaddel);
    
    y(n,3) = ap_temp; 
 
    


    

    if ddl_read + LFO > ddl_length
        ddl_read = (ddl_read + LFO) - ddl_length;
    elseif ddl_read + LFO < 1
        ddl_read = (ddl_read + LFO) + ddl_length;
    else
        ddl_read = ddl_read + LFO;
    end

    if ddl_readdel + LFO > ddl_length
        ddl_readdel = (ddl_readdel + LFO) - ddl_length;
    elseif ddl_readdel + LFO < 1
        ddl_readdel = (ddl_readdel + LFO) + ddl_length;
    else
        ddl_readdel = ddl_readdel + LFO;
    end


    ddl_read = ddl_read + 1 + LFO;



    ddl_readdel = ddl_readdel + 1;
    ddl_write = ddl_write + 1;




    if ddl_read > ddl_length
        ddl_read = 1;
    end
    if ddl_readdel > ddl_length
        ddl_readdel = 1;
    end
    if ddl_write > ddl_length
        ddl_write = 1;
    end

    phase = phase + 2*pi*rate*T;
    if phase > 2*pi
        phase = phase - 2*pi;
    end

end

%soundsc(y(:,3),fs);

% plot(y(:,1));
% hold on
%plot(y(:,3));
plot(linspace(0,fs,length(x(:,1))),20*log10(abs(fft(x(:,1)))))

