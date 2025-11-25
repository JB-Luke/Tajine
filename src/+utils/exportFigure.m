
legend(gca,["Teodorico GF","Teodorico FF","Eremo Montesiepi"])

outPath = fullfile("test_dataset","Teodorico-Eremo-comparison");
if ~isfolder(outPath)
    mkdir(outPath)
end

ax = gca;
ax.FontName = 'Georgia';

% Fix D50 y axis
% yticklabels(ax,num2cell(yticks/100));
% ylabel(ax,"");

filename = erase(ax.Title.String," ") + ".fig";
outFile = fullfile(outPath,filename);
saveas(gca,outFile);

filename = erase(ax.Title.String," ") + ".pdf";
outFile = fullfile(outPath,filename);
exportgraphics(gca,outFile,"Resolution",300);