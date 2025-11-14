classdef bitcrush
   

    properties
        bits = 0;
        sampleRate
        inter = 0;
        delta = 0;
    end

    methods
        function obj = bitcrush(bits,sampleRate)
            obj.bits = bits;
            obj.sampleRate = sampleRate;
        end

        function y = process(obj,x)
            obj.delta = 2 / (2^obj.bits - 1);
            y = (obj.delta * round((x-1)/obj.delta) + 1);
            %y2 = ((round((x+1)/2 * (2^obj.bits - 1))) / (2^obj.bits - 1)) * 2 - 1; 
            % Normalises the signal into [0,1] first then applies the
            % quanisation - it makes more sense in my head but the top
            % version is literally the text book definition of quanisation
            % and performs less steps. They both literally do the same
            % thing
            % https://www.desmos.com/calculator/tejmq4dqm5
        end
        function updateBits(obj,bits)
            obj.bits = bits;
        end
        
    end
end