classdef APF < handle
    properties
        sdel = 0; % Sample delay
        ddl = 0; % delay line
        idx = 1; % index
        g = 0; % g value
        apf_out = 0; % all pass output
        temp_in = 0; % temporary storage value
    end
   
    methods
        function obj = APF(sample_delay, g)
               obj.sdel = sample_delay; 
               obj.ddl = zeros(obj.sdel, 1); 
               obj.g = g; 
        end
        function y = process(obj,x)
           
            obj.temp_in = x + (obj.ddl(obj.idx) * obj.g);
            obj.apf_out = (obj.temp_in * -obj.g) + obj.ddl(obj.idx);
            obj.ddl(obj.idx) = obj.temp_in;
            y = obj.apf_out;

            obj.idx = obj.idx + 1;
            if obj.idx > obj.sdel
                obj.idx = 1;
            end
        end
        
      

        function update(obj, sdel)
            obj.sdel = sdel;
            obj.ddl = zeros(obj.sdel, 1);
            obj.idx = 1;
        end 
    end
end