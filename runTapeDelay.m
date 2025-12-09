% adds modules and plugins to the path then runs the plugin
% because i keep having to close and re-open matlab

clear all; close all; 
addpath(genpath("modules/"));
addpath(genpath("plugins/"));% make class folders visible to this file

audioTestBench(tapeDelay)