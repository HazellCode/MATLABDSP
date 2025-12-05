classdef biQuad <handle
    %BIQUAD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        a0 = 0;
        a1 = 0;
        a2 = 0;
        b0 = 0;
        b1 = 0;
        b2 = 0;


        w0 = 0;
        a = 0;

        Q = 0; 
        fc = 0;
        fs = 0;

        x1 = 0;
        x2 = 0;
        y1 = 0;
        y2 = 0; 

        A = 0;

        type = "";

    end

    methods
        function obj = biQuad(fc, Q, fs, type, A)
            %BIQUAD Construct an instance of this class
            %   Detailed explanation goes here

            

            obj.Q = Q;
            obj.A = 10^(A/40);
            obj.fc = fc;
            obj.fs = fs;
            obj.w0 = 2 * pi * ( obj.fc / obj.fs);
            obj.a = sin(obj.w0) / (2 * obj.Q);
            obj.type = type;
            if type == "LPF"
                obj.createLPFCo;
            elseif type == "HPF"
                obj.createHPFCo;
            elseif type == "peak"
                obj.createPeakCo;
            elseif type == "notch"
                obj.createNotchCo;
            end

            obj.b0 = obj.b0 / obj.a0;
            obj.b1 = obj.b1 / obj.a0;
            obj.b2 = obj.b2 / obj.a0;
            obj.a1 = obj.a1 / obj.a0;
            obj.a2 = obj.a2 / obj.a0;


        end

        function y = process(obj,x)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            y = obj.b0 * x + obj.b1 * obj.x1 + obj.b2 * obj.x2 - obj.a1*obj.y1 - obj.a2*obj.y2;
            obj.y2 = obj.y1;
            obj.y1 = y;
            obj.x2 = obj.x1;
            obj.x1 = x;
        end


        function createLPFCo(obj)
            obj.b0 = (1-cos(obj.w0)) / 2;
            obj.b1 = 1 - cos(obj.w0);
            obj.b2 = (1 - cos(obj.w0)) / 2;
            obj.a0 = 1 + obj.a;
            obj.a1 = -2 * cos(obj.w0);
            obj.a2 = 1 - obj.a;
        end

        function createHPFCo(obj)
            obj.b0 = (1+cos(obj.w0)) / 2;
            obj.b1 = -(1 + cos(obj.w0));
            obj.b2 = (1 + cos(obj.w0)) / 2;
            obj.a0 = 1 + obj.a;
            obj.a1 = -2 * cos(obj.w0);
            obj.a2 = 1 - obj.a;
        end

        function createPeakCo(obj)
            
            obj.a = (sin(obj.w0) / (2 * obj.Q));
            obj.b0 = 1 + (obj.a * obj.A);
            obj.b1 = -2 * (cos(obj.w0));
            obj.b2 = 1 - (obj.a * obj.A);
            obj.a0 = 1 + (obj.a/obj.A);
            obj.a1 = obj.b1;
            obj.a2 = 1 - (obj.a / obj.A);
        end


        function createNotchCo(obj)
            obj.b0 = 1;
            obj.b1 = -2 * (cos(obj.w0));
            obj.b2 = 1;
            obj.a0 = 1 + obj.a;
            obj.a1 = obj.b1;
            obj.a2 = 1 - obj.a;
        end
    
        function setBase(obj, val)
            obj.y2 = val;
            obj.y1 = val;
            obj.x2 = val;
            obj.x1 = val;
        end


        function updateCutoff(obj, fc)
            obj.fc = fc;
            % Re-evaluate coeffients
            obj.w0 = 2 * pi * ( obj.fc / obj.fs);
            obj.a = sin(obj.w0) / (2 * obj.Q);

            if obj.type == "LPF"
                obj.createLPFCo;
            elseif obj.type == "HPF"
                obj.createHPFCo;
            end

            obj.b0 = obj.b0 / obj.a0;
            obj.b1 = obj.b1 / obj.a0;
            obj.b2 = obj.b2 / obj.a0;
            obj.a1 = obj.a1 / obj.a0;
            obj.a2 = obj.a2 / obj.a0;


        end
    end
end