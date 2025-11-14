classdef oversample
    %OVERSAMPLE Summary of this class goes here
    %   Detailed explanation goes here

    properties
      os_amount = 1;
      os_store = 0;
      os_store_dec = 0;
      lowPass = 0;
      lowPassDec = 0;
    end

    methods
        function obj = oversample(os_amount,fs)
            obj.os_amount = os_amount;
            obj.os_store = zeros(os_amount,1);
            obj.os_store_dec = zeros(os_amount, 1);
            obj.lowPass = biQuadCas(os_amount,0.707,fs/2,fs);
            obj.lowPassDec = biQuadCas(os_amount,0.707,fs/2,fs);
            
        end

        function y = expand(obj, x)
           % insert x into os_store at index os_store((n * os_amount) - 1)
           obj.os_store(1,1) = x;
           for k = 1:obj.os_amount
               obj.os_store(k) = obj.lowPass.process(obj.os_store(k));
           end
           y = obj.os_store;
        end

        function y = deflate(obj,x)
            % re filter the matrix
            % just select the first same from the array and return
            for k = 1:obj.os_amount
               obj.os_store_dec(k) = obj.lowPassDec.process(x(k));
            end
            y = obj.os_store_dec(1,1);
            
        end
    end
       

       

end