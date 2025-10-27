function s = readVersionFile()
fid = fopen('VERSION','r');
if fid<0, error('VERSION file not found'); end
s = strtrim(fgetl(fid));
fclose(fid);
end