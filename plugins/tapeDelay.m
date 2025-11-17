classdef tapeDelay < audioPlugin
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
        bicL = 0;
        bicR = 0;
        outLPL = 0;
        outLPR = 0; 

        outputLPL
        outputLPR

        fs = 48000; % default sample rate

        pregain = 1; % default pregain
        postgain = 1; % default postgain

        fbL = 0; 
        fbR = 0;
        inL = 0;
        inR = 0;
        outL = 0;
        outR = 0;

        fb_mix = 0;
        dw = 1;
        outputFilter = 12000;

        delay_Time = 1;
        lfo_depth = 1;
        lfo_rate = 0.5;
        bit_depth = 16;
        fb = 0;


        
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
         PluginInterface = audioPluginInterface( ...
                audioPluginParameter('delay_Time','Mapping',{'log',1,5000},'DisplayName', 'Delay Time', 'Label','ms', 'Style', 'rotaryknob', 'Layout',[2,1],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('lfo_depth','Mapping',{'log',1,800},'DisplayName', 'Depth', 'Label','funny units', 'Style', 'rotaryknob', 'Layout',[2,2],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('lfo_rate','Mapping',{'lin',0,20},'DisplayName', 'Rate', 'Label','funny units', 'Style', 'rotaryknob', 'Layout',[2,3],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('fb','Mapping',{'lin',0,1},'DisplayName', 'FB', 'Label','yelps / s', 'Style', 'rotaryknob', 'Layout',[2,4],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('bit_depth','Mapping',{'lin',1,16},'DisplayName', 'Bitdepth', 'Label','bean(s)', 'Style', 'vslider', 'Layout',[2,5],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('dw','Mapping',{'lin',0,1},'DisplayName', 'Dry/Wet', 'Label','water is wet', 'Style', 'vslider', 'Layout',[4,1],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('pregain','Mapping',{'lin',0,5},'DisplayName', 'PreGain', 'Label','louds', 'Style', 'vslider', 'Layout',[4,2],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('postgain','Mapping',{'lin',0,5},'DisplayName', 'PostGain', 'Label','louds', 'Style', 'vslider', 'Layout',[4,3],'DisplayNameLocation', 'above'), ...
                audioPluginGridLayout('RowHeight',[100,100,100,100], 'ColumnWidth', [100,100,100,100,100]),...
                'VendorName', 'FSA', 'PluginName', 'Tape', 'VendorVersion', '0.1', 'InputChannels',2,'OutputChannels',2);

    end
    methods
        function plugin = tapeDelay()
            plugin.bufferL = circularQuadBuffer(300,10,plugin.fs,1);
            plugin.bufferR = circularQuadBuffer(300,10,plugin.fs,1);
            plugin.bufferL.setLFO(0.5,30)
            plugin.bufferR.setLFO(0.5,30)


            plugin.preL = biQuad(200, 0.2,plugin.fs,"peak",2);
            plugin.preR = biQuad(200, 0.2,plugin.fs,"peak",2);

            plugin.bicL = bitcrush(3, plugin.fs);
            plugin.bicR = bitcrush(3, plugin.fs);

            plugin.outLPL = biQuad(plugin.outputFilter,0.707,plugin.fs,"LPF",0);
            plugin.outLPR = biQuad(plugin.outputFilter,0.707,plugin.fs,"LPF",0);


        end
        function out = process(plugin,in)
            % This section contains instructions to produce the output
            % audio signal. Use plugin.MyProperty to access a property of
            % your plugin. Use getSamplesPerFrame(plugin) to get the frame
            % size used by the environment.

            [N,M] = size(in);
            out = zeros(N,M);

            for n = 1:N
                % Sample Buffer
                plugin.inL = in(n,1) + (plugin.fbL * plugin.fb);
                plugin.inR = in(n,2) + (plugin.fbR * plugin.fb);

                plugin.preLout = plugin.preL.process(plugin.inL);
                plugin.preRout = plugin.preR.process(plugin.inR);

                plugin.bufferL.push(tanh(plugin.preLout * plugin.pregain))
                plugin.bufferR.push(tanh(plugin.preRout * plugin.pregain))

                plugin.outL = plugin.bufferL.processBuffer();
                plugin.outR = plugin.bufferR.processBuffer();

                plugin.fbL = plugin.outL;
                plugin.fbR = plugin.outR;

                plugin.outL = tanh(plugin.bicL.process(plugin.outL)*plugin.postgain);
                plugin.outR = tanh(plugin.bicR.process(plugin.outR)*plugin.postgain);
                

                out(n,1) = (plugin.dw * plugin.outLPL.process(plugin.outL)) + (1 - plugin.dw) * plugin.inL;
                out(n,2) = (plugin.dw * plugin.outLPR.process(plugin.outR)) + (1 - plugin.dw) * plugin.inR;


            end


        end
        function reset(plugin)
            % This section contains instructions to reset the plugin
            % between uses, or when the environment sample rate changes.
            plugin.fs = plugin.getSampleRate;
            plugin.bufferL = circularQuadBuffer(300,10,plugin.fs,1);
            plugin.bufferR = circularQuadBuffer(300,10,plugin.fs,1);
            plugin.bufferL.setLFO(plugin.lfo_rate,plugin.lfo_depth)
            plugin.bufferR.setLFO(plugin.lfo_rate,plugin.lfo_depth)
            plugin.preL = biQuad(200, 0.2,plugin.fs,"peak",2);
            plugin.preR = biQuad(200, 0.2,plugin.fs,"peak",2);

            plugin.bicL = bitcrush(6, plugin.fs);
            plugin.bicR = bitcrush(6, plugin.fs);

            plugin.outLPL = biQuad(plugin.outputFilter,0.707,plugin.fs,"LPF",0);
            plugin.outLPR = biQuad(plugin.outputFilter,0.707,plugin.fs,"LPF",0);
        end

        function set.delay_Time(plugin, val)
            plugin.bufferL.delTime(val)
            plugin.bufferR.delTime(val)
            plugin.delay_Time = val;
            temp_depth = plugin.lfo_depth;
            plugin.lfo_depth = plugin.bufferL.setLFOdepth(temp_depth);
            plugin.bufferR.setLFOdepth(temp_depth);

        end


        function set.lfo_depth(plugin, val)
            plugin.lfo_depth = plugin.bufferL.setLFOdepth(val);
            plugin.bufferR.setLFOdepth(val);
            
            
        end


        function set.bit_depth(plugin,val)
            plugin.bit_depth = val;
            plugin.bicL.updateBits(val);
            plugin.bicR.updateBits(val);

        end
        

        function set.lfo_rate(plugin, val)
            plugin.lfo_rate = val;
            plugin.bufferL.setLFOrate(val)
            plugin.bufferR.setLFOrate(val)
        end

        function set.dw(plugin, val)
            plugin.dw = val;
        end

        function set.fb(plugin, val)
            plugin.fb = val;
        end
        function set.pregain(plugin,val)
            plugin.pregain = val;
        end
        function set.postgain(plugin,val)
            plugin.postgain = val;
        end
    end
end