classdef Delay_2Tap
    %DELAY_2TAP Summary of this class goes here
    %   Detailed explanation goes here

    properties
        in
        Del1Sampels
        Del2Sampels
        readHead
        writeHead
    end

    methods
        function obj = Delay_2Tap(input, Del1, Del2)
            
            obj.in = input;
            obj.Del1Sampels = Del1;
            obj.Del2Sampels = Del2;
            readHead = 
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end