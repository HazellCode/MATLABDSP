classdef tapeDelay < audioPluginSource
    % myBasicSourcePlugin is a template for a basic source plugin. Use this
    % template to create your own basic source plugin.
    
    properties
        bufferL = 0;
        bufferR = 0;
        crushL = 0;
        crushR = 0;
        preL = 0;
        preR = 0; 
        preLout = 0;
        preRout = 0;

        outputLPL
        outputLPR

        fs = 48000; % default sample rate

        pregain = 1; % default pregain
        postgain = 1; % default postgain

        fbL = 0; 
        fbR = 0;

        fb_mix = 0.2;
        dw = 0.5;
        outputFilter = 8000;


        
    end
    properties (Access = private)
        % Use this section to initialize properties that the end-user does
        % not interact with directly.

        
    end
    properties (Constant)
        % This section contains instructions to build your audio plugin
        % interface. The end-user uses the interface to adjust tunable
        % parameters. Use audioPluginParameter to associate a public
        % property with a tunable parameter.
    end
    methods
        function plugin = tapeDelay()
            plugin.bufferL = circularQuadBuffer(300,10,plugin.fs,1);
            plugin.bufferR = circularQuadBuffer(300,10,plugin.fs,1);

            plugin.preL = biQuad(200, 0.2,plugin.fs,"peak",2);
            plugin.preR = biQuad(200, 0.2,plugin.fs,"peak",2);

            plugin.bicL = bitcrush(10, plugin.fs);
            plugin.bicR = bitcrush(10, plugin.fs);

            plugin.outLPL = biQuad(outputFilter,0.707,plugin.fs,"LPF",0);
            plugin.outLPR = biQuad(outputFilter,0.707,plugin.fs,"LPF",0);


        end
        function out = process(plugin,in)
            % This section contains instructions to produce the output
            % audio signal. Use plugin.MyProperty to access a property of
            % your plugin. Use getSamplesPerFrame(plugin) to get the frame
            % size used by the environment.


        end
        function reset(plugin)
            % This section contains instructions to reset the plugin
            % between uses, or when the environment sample rate changes.
        end
        
    end
end