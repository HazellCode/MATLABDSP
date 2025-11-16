classdef circularQuadBuffer < handle
    %% DESCRIPTION
    % A Modulated Circular Buffer with a Linear Interpolator added to the
    % end to reduce zipping and allow for fractional read points
    % Currently a Mono Class 
    %   - Planned expansion to multi channel for sunk LFO's 
    %% TODO
    % Stop tape machine button
    %% METHODS

    properties

        % Define Delay Times and Buffer
        sDelMs; % Sample Delay in Milliseconds
        sDelBaseFloat; % Sample Delay with Fractional Part in Samples
        sDelBaseTarget; % Target Value for the base float after update
        sDel; % Floor (sDelBaseFloat)
        cBuf; % Buffer (2 channel - at the moment)
        sDelSp; % Smoothed Delay Time

        % Pointers
        write = 0; % write pointer
        read = 0; % read pointer
        rawRead = 0; 
        boundRead = 0;
        readPrev = 0; % read pointer - 1
        read1 = 0; % $ read pointer - 2
        read2 = 0; % read pointer - 3
        readFrac = 0; % fractional read pointer
        frac = 0; % Fractional Component (0-1)
        prevDel = 0;
        delD = 0;
        readSpeed = 0;

        % Single Read 
        x0 = 0; % Read Pointer
        x1 = 0; % Read Pointer - 1
        x2 = 0; % Read Pointer + 1
        x3 = 0; % Read Pointer + 2

        a0 = 0;
        a1 = 0;
        a2 = 0;
        a3 = 0;

        % LFO
        LFO = 0; % Storage
        depthraw = 500; % Depth of the LFO in Samples
        depth = 0; 
        phase = 0; % Phase
        offset = 0; % LFO Offset
        rateraw = 2; % LFO Rate in Hz
        rate = 0;
        depthsp = 0;
        ratesp = 0;

        % Circuit Bending Stuff
        smoothersCutoff = 0.1; % Allow the user to change the speed of the smoothers on the rate, depth and delay time controls
        % Low = Very slow - lots of pitch bending
        % High = Very fast - high pitch squeek then 

        % Delay Compensation
        err = 0;
        currentDelayTime = 0;


        % Max Constraights
        maxDelayTimeMs = 0; % Length of Circular Buffer in Ms
        maxDelayLength = 0; % Length of Circular Buffer in Samples
        readVelo = 10; % Max speed in samples the read head can move when delay time is changed

        % Environment Settings
        T = 0; % Length of Single Sample
        fs = 0; % Sample Rate

    end

    methods
        function obj = circularQuadBuffer(delayTimeMs,maxDelayTimeSeconds,fs, numChannels);
            obj.T = 1/fs; % Set T 
            obj.fs = fs; % Set Sample Rate
            obj.maxDelayLength = maxDelayTimeSeconds * (fs); % Convert Seconds to Samples
            obj.sDelMs = delayTimeMs;% set sDelMs
            obj.sDelBaseFloat = obj.sDelMs * (fs/1000); % Convert Milliseconds to Samples
            % obj.sDelBaseFloat = delayTimeMs;
            obj.sDelBaseTarget = obj.sDelBaseFloat;
            obj.sDel = floor(obj.sDelBaseFloat); % Int Sample Delay (no fractional part)
            obj.cBuf = zeros(obj.maxDelayLength, numChannels); % Create Circular Buffer
            obj.write = 1; % Set Write Pointer at start of Buffer
            obj.read = obj.write - obj.sDel + obj.maxDelayLength; % Set read pointer at sDel samples back from write pointer
            obj.rawRead = obj.read - obj.sDelBaseFloat;
            obj.rawRead = mod(obj.rawRead - 1,obj.maxDelayLength)+1;
            obj.readFrac = obj.write - obj.sDel + obj.maxDelayLength;
            obj.readPrev = obj.write - obj.sDel + obj.maxDelayLength -1;
            obj.read1 = obj.write - obj.sDel + obj.maxDelayLength +1;
            obj.read2 = obj.write - obj.sDel + obj.maxDelayLength +2;
            obj.depthsp = biQuad(0.5,0.707,fs,"LPF",0); % Create Depth Smoother
            obj.depthsp.setBase(obj.depth); % Initalise Depth Smoother (stops the massive jumps when delay time changed)
            obj.ratesp = biQuad(0.1,0.707,fs,"LPF",0); % Create Rate Smoother
            obj.ratesp.setBase(obj.rate); % Initalise Rate Smoother (stops the massive jumps when delay time changed)
            obj.sDelSp = biQuad(1,0.3,fs,"LPF",0); % Create Delay Time Smoother
            obj.sDelSp.setBase(obj.sDelBaseFloat); % Initalise Time Smoother (stops the massive jumps when delay time changed)
        end

        function [y] = processBuffer(obj)
            obj.depth = obj.depthsp.process(obj.depthraw);
            obj.rate = obj.ratesp.process(obj.rateraw);
            % New smoothing code
            % Issue was that the biQuad smoother was causing the read
            % pointer to overshoot the write pointer causing either no
            % sound at all or a breif look back into the past :(
            % The slewClamp seems to be optional as now with the biquad set
            % to 0.3 Q rather than 0.707 the overshoot is gone
            % Its taken me 5 hours to find that chaning one value fixes
            % this - at least i made brownies in that time 
            obj.sDelBaseFloat = obj.sDelSp.process(obj.sDelBaseTarget);
            % obj.sDelBaseFloat = obj.slewClamp(obj.sDelBaseFloat, obj.sDelBaseTarget, 10);
            obj.LFO = obj.sDelBaseFloat + (sin(obj.phase) * obj.depth); % Calculate LFO for this sample
            % Calculate read pointer from write pointer - LFO but bound [0 < x < maxDelayLength]
            obj.rawRead = obj.write - obj.LFO; % write pointer - modulated read pointer

            obj.readFrac = mod(obj.rawRead - 1,obj.maxDelayLength)+1; % bind the read pointer within the bounds of the delay line
            
            obj.read = floor(obj.readFrac); % make read pointer an in
            obj.frac = obj.readFrac - obj.read; % store the fractional part of the pointer
            % Calculate other read pointers
            obj.readPrev = obj.read - 1;
            obj.read1 = obj.read + 1;
            obj.read2 = obj.read + 2;

            % Bind the other read pointers within the delay line
            % constraighnts 
            if obj.readPrev < 1
                obj.readPrev = obj.readPrev + obj.maxDelayLength;
            elseif obj.readPrev > obj.maxDelayLength
                obj.readPrev = obj.readPrev - obj.maxDelayLength; 
            end

            if obj.read1 < 1
                obj.read1 = obj.read1 + obj.maxDelayLength;
            elseif obj.read1 > obj.maxDelayLength
                obj.read1 = obj.read1 - obj.maxDelayLength;            
            end
            if obj.read2 < 1
                obj.read2 = obj.read2 + obj.maxDelayLength;
            elseif obj.read2 > obj.maxDelayLength
                obj.read2 = obj.read2 - obj.maxDelayLength;
            end


            % Get the values from cBuf using the four read pointers
            obj.x3 = obj.cBuf(obj.readPrev); % n - 1
            obj.x2 = obj.cBuf(obj.read); % n
            obj.x1 = obj.cBuf(obj.read1); % n + 1
            obj.x0 = obj.cBuf(obj.read2); % n + 2
            
            


            % Calculate the quadratic coeffcients
            obj.a0 = (-0.5*obj.x3) + (1.5*obj.x2) - (1.5*obj.x1) + (0.5*obj.x0);
            obj.a1 = obj.x3 - (2.5*obj.x2) + (2*obj.x1) - (0.5*obj.x0);
            obj.a2 = (-0.5*obj.x3) + (0.5*obj.x1);
            obj.a3 = obj.x2;

            
            % Output the modulated delay line
            y = ((obj.a0 * obj.frac + obj.a1) * obj.frac + obj.a2) * obj.frac + obj.a3;
            % LFO = obj.read;
            % write = obj.write;
            obj.inc; % Increment Pointers

        end


        function push(obj, x)
            obj.cBuf(obj.write) = x; % Add input into the buffer
        end

      

        function inc(obj)

            % Increment and Wrap Write Pointer
            obj.write = obj.write + 1;
            if obj.write > obj.maxDelayLength
                obj.write = 1;
            end 
            % Increment and Wrap Phase
            obj.phase = obj.phase + 2*pi*obj.rate*obj.T;
            if obj.phase > 2*pi
                obj.phase = obj.phase - 2*pi;
            end
        end
        function setLFO(obj, rate, depth)
            obj.rateraw = rate;
            obj.depthraw = depth;
        end
        function smoothed(obj,sma)
            % update the smoothed amount;
            obj.depthsp.updateCutoff(sma)
            obj.ratesp.updateCutoff(sma)
            obj.sDelSp.updateCutoff(sma)

        end
        function delTime(obj, delTime)
            obj.sDelMs = delTime; % set sDelMs
            obj.sDelBaseTarget = obj.sDelMs * (obj.fs/1000); % Convert Milliseconds to Samples
            obj.sDel = floor(obj.sDelBaseFloat); % Int Sample Delay (no fractional part)

            
            
        end

        function val = slewClamp(obj,cur, tar, velo)
            % delta = difference between current value and desired change
            delta = tar - cur;
            if abs(delta) > velo
                delta = sign(delta) * velo;
            end
            val = cur + delta;
        end
    end

end