function computeParameters(irFile,outputName,outFolders)

acouParProcess(irFile.omni,outFolders.calcs.omni,outputName,mode="omni");
acouParProcess(irFile.binaural,outFolders.calcs.binaural,outputName,mode="bin");
acouParProcess(irFile.wy,outFolders.calcs.bFormat,outputName,mode="wy");

fprintf('\n✅ Acoustic Parameters extracted with AcouPar.\n\n\n');

end