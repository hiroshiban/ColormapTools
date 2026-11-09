% Run from the project directory after addpath('src').
lut=generate_colormap('hsv-scurve',360);
figure('Color','w'); tl=tiledlayout(2,2);
ax=nexttile(tl); show_colormap(lut,'ring','Parent',ax,'Limits',[0 360], ...
    'TickValues',[0 90 180 270],'Title','Polar angle, clockwise from north');
ax=nexttile(tl); show_colormap(lut,'semicircle','Parent',ax,'Title','Hemifield key');
ax=nexttile(tl); show_colormap(generate_colormap('black-white',256),'eccentricity', ...
    'Parent',ax,'RadialLimits',[0 12],'TickValues',[0 4 8 12],'Title','Eccentricity, degrees');
ax=nexttile(tl); show_colormap(generate_colormap('owp',257),'horizontal', ...
    'Parent',ax,'Limits',[-1 1],'Label','Correlation','Title','Diverging scalar');
% Transparent export has no dependency on a figure window.
[rgb,a,metadata]=colormap_legend(lut,'ring','Size',601);
% imwrite(rgb,'phase-key.png','Alpha',a);
