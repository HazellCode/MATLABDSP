classdef tapeDelay (path = "./modules")< audioPluginSource
    % myBasicSourcePlugin is a template for a basic source plugin. Use this
    % template to create your own basic source plugin.
    
    properties
        bufferL
        bufferR
        crushL
        crushR


        outputLPL
        outputLPR
    end
    properties (Access = private)
        % Use this section to initialize properties that the end-user does
        % not interact with directly.

        bufferL = circularQuadBuffer()
    end
    properties (Constant)
        % This section contains instructions to build your audio plugin
        % interface. The end-user uses the interface to adjust tunable
        % parameters. Use audioPluginParameter to associate a public
        % property with a tunable parameter.
    end
    methods
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