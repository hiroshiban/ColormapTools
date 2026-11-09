function demo_rgb_colormaps
%DEMO_RGB_COLORMAPS Build two-to-four-anchor maps without custom routines.
root=fileparts(fileparts(mfilename('fullpath')));addpath(fullfile(root,'src'));
colors=[1 0 0;1 1 1;0 0 1];
linear=generate_colormap_from_rgb(colors,257,'Method','linear');
smooth=generate_colormap_from_rgb(colors,257,'Method','sinusoidal');
f=figure('Color','w');layout=tiledlayout(f,2,1);
show_colormap(linear,'horizontal','Parent',nexttile(layout),'Title','RGB anchors: linear');
show_colormap(smooth,'horizontal','Parent',nexttile(layout),'Title','RGB anchors: sinusoidal');
end
