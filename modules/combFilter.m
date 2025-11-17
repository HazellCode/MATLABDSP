classdef combFilter < handle
    %COMBFILTER Summary of this class goes here
    %   Detailed explanation goes here

    properties
        idx = 1;
        sdel = 0;
        ddl = 0;
        rt60 = 0;
        fs = 0;
        g = 0;
    end

    methods
        function obj = combFilter(sampleDelay,time,fs)
            obj.sdel = sampleDelay;
            obj.rt60 = time;
            obj.fs = fs;
            obj.ddl = zeros(sampleDelay,1);
            obj.g = 10 ^ ((-1 * length(obj.ddl)) / (time*obj.fs));
        end

        function y = process(obj,x)
            y = obj.ddl(obj.idx);
            obj.ddl(obj.idx) = x + (obj.ddl(obj.idx) * obj.g);
            
            obj.idx = obj.idx + 1;
            if obj.idx > obj.sdel
                obj.idx = 1;
            end
           
        end
        function calcRT60(obj, time)
            obj.g = 10 ^ ((-3 * length(obj.ddl)) / (time*obj.fs));
        end
    end
end