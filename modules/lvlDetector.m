classdef lvlDetector
    %LVLDETECTOR Summary of this class goes here
    %   Detailed explanation goes here

    properties
        lvl = 0;
    end

    methods
        function obj = lvlDetector(peaklvl)
           obj.lvl = peaklvl;
        end

        function y = calc(obj,x)
            if 20*log10(x) > obj.lvl
                y = 1;
            else
                y = 0;
            end
        end

    end
end