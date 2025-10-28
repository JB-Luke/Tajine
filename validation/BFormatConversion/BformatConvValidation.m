%% Elaboration of Bidule B-Format conversion to validate matlab version
clear; close all; clc;

addpath("BFormatConvValidation")

[bformatSweep, fs] = audioread("bformat-ext.wav");  
[invSweep,~] = audioread("INV-ESS.wav");

[irBformat,peakValBin] = deconvolve(bformatSweep,invSweep);
irBformatTrim = trimIR(irBformat,fs,0.25,4);

wy_signals = irBformatTrim(:,[1,2]);
wyFile = exportAudio(wy_signals,fs,pwd,"bformat-bidule-WY");
acouParProcess(wyFile,pwd,"bformat-bidule",mode="wy");

txtFile = "bformat-bidule-BFormat.txt";
opts = detectImportOptions(txtFile);
opts.VariableNames = replace(opts.VariableNames,'.','_');
rawData = readtable(txtFile,opts);

extParTb = transformTable(rawData,table,cellstr(txtFile),type="wy");

%% Comparison plot
load("BFormatConvValidation/bFormatParTb.mat");

par = ["Jlf","Jlfc","Lj"];

for iPar = 1:length(par)
    filename = "p2-ground-2-BFormat.txt";
    tbA_filter1 = bFormatParTb(bFormatParTb .Filename == filename,:);
    tbA_filter2 = tbA_filter1(tbA_filter1.Parameter == par(iPar),:);
    curveDataA = table2array(tbA_filter2(:,...
        ["31_5","63","125","250","500","1000","2000","4000","8000","16000"]));

    filename = "bformat-bidule-BFormat.txt";
    tbB_filter1 = extParTb(extParTb .Filename == filename,:);
    tbB_filter2 = tbB_filter1(tbB_filter1.Parameter == par(iPar),:);
    curveDataB = table2array(tbB_filter2(:,...
        ["31_5","63","125","250","500","1000","2000","4000","8000","16000"]));

    octaveBands = [31.5,63,125,250,500,1000,2000,4000,8000,16000];

    figure(iPar)
    semilogx(octaveBands,curveDataA,'LineWidth',1.2); hold on;
    semilogx(octaveBands,curveDataB,'LineWidth',1.2); hold off;
    % ylim([-10,10])
    grid on
    ylabel(tbA_filter2.Unit)
    xlabel("Freq. [Hz]")
    title(par(iPar))
    legend('matlab bformat conv','bidule bformat conversion')
end