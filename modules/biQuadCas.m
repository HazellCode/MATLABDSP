classdef biQuadCas
    %BIQUADCAS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Quad = 0;
        Quad2 = 0;
        Quad4 = 0;
        Quad6 = 0;
        Quad8 = 0; 
        order = 0;
        Q = 0;
        fc = 0;
        fs = 0; 
        type = "";
    end

    methods
        function obj = biQuadCas(order,Q,fc,fs,type)
            obj.Quad = biQuad(fc,Q,fs,type);
            obj.Quad2 = biQuad(fc,Q,fs,type);
            obj.Quad4 = biQuad(fc,Q,fs,type);
            obj.Quad6 = biQuad(fc,Q,fs,type);
            obj.Quad8 = biQuad(fc,Q,fs,type);
            obj.order = order;
            obj.Q = Q;
            obj.fc = fc;
            obj.fs = fs;
            obj.type = type;
            
        end

        function y = process(obj,x)
            if obj.order == 2
                y = obj.Quad.process(x);
            elseif obj.order == 4
                y = obj.Quad.process(obj.Quad2.process(x));
            elseif obj.order == 6
                y = obj.Quad.process(obj.Quad2.process(obj.Quad4.process(x)));
            elseif obj.order == 8
                y = obj.Quad.process(obj.Quad2.process(obj.Quad4.process(obj.Quad6.process(x))));
            elseif obj.order == 10
                y = obj.Quad.process(obj.Quad2.process(obj.Quad4.process(obj.Quad6.process(obj.Quad8.process(x)))));
            end
        end
        
    end
end