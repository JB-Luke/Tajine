function v = getVersion()
% VERSION  Project version (single source of truth)
%   returns a struct with fields .semver, .build, .git

v.semver    = readVersionFile();       % semantic version
v.gitInfo   = gitQuery('git describe --tags --abbrev=7'); % git tag-commitsAheadTag-hash
v.gitTag    = gitQuery('git describe --tags --abbrev=0 2>nul'); 

end

function i = gitQuery(command)

[status, i] = system(command);

if status == 0
    i = strtrim(i);
else
    i = '';
end

end