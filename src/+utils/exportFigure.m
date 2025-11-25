
legend(gca,["Groud floor","First floor"])

outPath = fullfile("test_dataset","Mausoleo-Teodorico","calcs","figures");
if ~isfolder(outPath)
    mkdir(outPath)
end

ax = gca;
ax.FontName = 'Georgia';

% Fix D50 y axis
% yticklabels(ax,num2cell(yticks/100));
% ylabel(ax,"");

filename = erase(ax.Title.String," ") + ".pdf";
outFile = fullfile(outPath,filename);
exportgraphics(gca,outFile,"Resolution",300);