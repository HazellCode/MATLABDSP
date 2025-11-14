classdef circularIntBuffer < handle
    % A Modulated Circular Buffer with a Linear Interpolator added to the
    % end to reduce zipping and allow for fractional read points
    % Currently a Mono Class 
    %   - Planned expansion to multi channel for sunk LFO's 
    properties

        % Define Delay Times and Buffer
        sDelMs; % Sample Delay in Milliseconds
        sDelBaseFloat; % Sample Delay with Fractional Part in Samples
        sDel; % Floor (sDelBaseFloat)
        cBuf; % Buffer (2 channel - at the moment)

        % Pointers
        write = 0; % write pointer
        read = 0; % read pointer
        readPrev = 0; % read pointer - 1
        readFrac = 0; % fractional read pointer
        frac = 0; % Fractional Component (0-1)

        % Single Read 
        x0 = 0; % Read Pointer
        x1 = 0; % Read Pointer - 1

        % LFO
        LFO = 0; % Storage
        depthraw = 100; % Depth of the LFO in Samples
        depth = 0;
        phase = 0; % Phase
        offset = 0; % LFO Offset
        rateraw = 0.5; % LFO Rate in Hz
        rate = 0;

       
        depthsp = 0;
        ratesp = 0;

        % Max Constraights
        maxDelayTimeMs = 0; % Length of Circular Buffer in Ms
        maxDelayLength = 0; % Length of Circular Buffer in Samples

        % Environment Settings
        T = 0; % Length of Single Sample
        fs = 0; % Sample Rate

    end

    methods
        function obj = circularIntBuffer(delayTimeMs,maxDelayTimeSeconds,fs, numChannels);
            obj.T = 1/fs; % Set T 
            obj.fs = fs; % Set Sample Rate
            obj.maxDelayLength = maxDelayTimeSeconds * (fs); % Convert Seconds to Samples
            obj.sDelMs = delayTimeMs; % set sDelMs
            obj.sDelBaseFloat = obj.sDelMs * (fs/1000); % Convert Milliseconds to Samples
            obj.sDel = floor(obj.sDelBaseFloat); % Int Sample Delay (no fractional part)
            obj.cBuf = zeros(obj.maxDelayLength, numChannels); % Create Circular Buffer
            obj.write = 1; % Set Write Pointer at start of Buffer
            obj.read = obj.write - obj.sDel + obj.maxDelayLength; % Set read pointer at sDel samples back from write pointer
            obj.readFrac = obj.write - obj.sDel + obj.maxDelayLength;
            obj.readPrev = obj.write - obj.sDel + obj.maxDelayLength -1;
            obj.depthsp = singlePole(0.00005);
            obj.ratesp = singlePole(0.00005);
           
        end

        function y = processBuffer(obj)
            obj.depth = obj.depthsp.process(obj.depthraw);
            obj.rate = obj.ratesp.process(obj.rateraw);
           

            obj.LFO = obj.sDelBaseFloat + (sin(obj.phase) * obj.depth); % Calculate LFO for this sample
             % Calculate read pointer from write pointer - LFO but bound [0 < x < maxDelayLength]
            % Calculate Read Pointer
            obj.readFrac = mod(obj.write - obj.LFO, obj.maxDelayLength);
            obj.read = floor(obj.readFrac); % Strip fractional part from the read pointer
            obj.frac = obj.readFrac - obj.read; % Store the fractional part of the read pointer
   
            
            obj.calculateRead; % Calculate the read pointer and the readPrev pointer
            

          


            

            % Assign values to variable so I only need to read the buffer
            % twice rather than three times.
            obj.x0 = obj.cBuf(obj.read); % Current Read Sample
            obj.x1 = obj.cBuf(obj.readPrev); % Previous Read Sample

            
             % Linear Interpolation 
            y = obj.x0 + obj.frac * (obj.x1 - obj.x0); % B * Frac * (A-B)

            obj.inc; % Increment Pointers

        end

        function setLFO(obj, rate, depth)
            obj.rateraw = rate;
            obj.depthraw = depth;
        end
        function push(obj, x)
            obj.cBuf(obj.write) = x; % Add input into the buffer
        end
        function calculateRead(obj)
            % Wrap read pointer to bounds of buffer length and minimum
            % length
            if obj.read > obj.maxDelayLength
                obj.read = obj.read - obj.maxDelayLength;
            elseif obj.read < 1
                obj.read = obj.read + obj.maxDelayLength;
            end
            
            % Increment and wrap previous read pointer
            obj.readPrev = obj.read + 1;
            if obj.readPrev > obj.maxDelayLength
                obj.readPrev = 1;
            end
        end
        function inc(obj)
           
            % Increment and Wrap Read Pointer
            obj.read = obj.read + 1; %
            if obj.read > obj.maxDelayLength
                obj.read = obj.read - obj.maxDelayLength;
            elseif obj.read < 1
                obj.read = obj.read + obj.maxDelayLength;
            end

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
        function smoothed(obj,sma)
            % update the smoothed amount;
            obj.depthsp.updateSmoothingAmount(sma);
            obj.ratesp.updateSmoothingAmount(sma);

        end
    end
end