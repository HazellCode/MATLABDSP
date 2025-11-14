classdef singlePole < handle
    %SINGLEPOLE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        a = 0;
        b = 0;
        val = 0;
    end

    methods
        function obj = singlePole(sma)
            obj.a = sma;
            obj.b = 1 - sma;
        end

        function [y,val] = process(obj,x)
             obj.val = (obj.a * x) + (obj.b * obj.val);
             y = obj.val;
             val = obj.val; 
        end

        function updateSmoothingAmount(obj, sma)
            obj.a = sma;
            obj.b = 1 - sma;
        end

        function setBase(obj, val)
            obj.val = val;
        end
    end
end