
fig = gcf;
ax = fig.CurrentAxes;

legend(ax,["Theodoric - ground","Theodoric - lv1"])

ylim([0 0.5]);

outPath = fullfile("test_dataset","Teodorico-figures");
if ~isfolder(outPath)
    mkdir(outPath)
end

fig.OuterPosition = [0 0 800 500];

ax.FontName = 'Palatino';
ax.FontSize = 14;

ax.Title.String = "J_{LFC}";
ax.Title.FontSize = 18;


%% Lines style
lines = ax.Children;

line1 = lines(2); % teodorico lv0
line2 = lines(1); % teodorico lv1
% line3 = lines(1); % san galgano

line1.Color = [0.0667 0.4431 0.7451]; % blue
line1.LineWidth = 1.5;
line1.Marker = "o";
line1.MarkerSize = 8;

line2.Color = [0.87, 0.33 0.00]; % red
line2.LineWidth = 1.5;
line2.Marker = "square";
line2.MarkerSize = 8;

% line3.Color = [0.9294    0.6941    0.1255]; % yellow
% line3.LineWidth = 1.5;
% line3.Marker = "diamond";
% line3.MarkerSize = 8;

% Fix D50 y axis
% yticklabels(ax,num2cell(yticks/100));
% ylabel(ax,"");

%% Export
filename = erase(ax.Title.String," ") + ".fig";
outFile = fullfile(outPath,filename);
saveas(gca,outFile);

filename = erase(ax.Title.String," ") + ".pdf";
outFile = fullfile(outPath,filename);
exportgraphics(gca,outFile,"Resolution",300);