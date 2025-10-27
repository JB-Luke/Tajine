function s = runtimeVersionString()
v = getVersion();
matlabVer = sprintf('%s (R%s)', version('-release'), version);

s = sprintf('v%s (git: %s)\nmatlab: %s', v.semver, v.gitInfo, matlabVer);

end