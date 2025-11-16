function outFolders = createOutFolders(outputFolder,transducers)

omniOutDir = transducers.omni.outDir;
binauralOutDir = transducers.binaural.outDir;
bformatOutDir = transducers.bFormat.outDir;

% Impulse response folders
irRoot = createSubfolder(outputFolder,'IRs');
outFolders.ir.root = irRoot;
outFolders.ir.omni = createSubfolder(irRoot,omniOutDir);
outFolders.ir.binaural = createSubfolder(irRoot,binauralOutDir);
outFolders.ir.bFormat = createSubfolder(irRoot,bformatOutDir);

% Calculations folders
calcsRoot = createSubfolder(outputFolder,'calcs');
outFolders.calcs.root = calcsRoot;
outFolders.calcs.omni = createSubfolder(calcsRoot,omniOutDir);
outFolders.calcs.binaural = createSubfolder(calcsRoot,binauralOutDir);
outFolders.calcs.bFormat = createSubfolder(calcsRoot,bformatOutDir);

end

function createFolder(folderFullPath)
if ~exist(folderFullPath, 'dir')
    mkdir(folderFullPath);
end
end

function subfolder = createSubfolder(root,subfolder)

subfolder = fullfile(root,subfolder);
createFolder(subfolder);

end