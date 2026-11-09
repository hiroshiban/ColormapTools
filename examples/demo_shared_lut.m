% Example of an explicit LUT and data-to-color mapping for cross-tool use.
lut=generate_colormap('vtk-hsv',361,'Quantize',true);
v=reshape(linspace(0,360,10000),100,100);
[rgb,a]=apply_colormap(v,lut,'Limits',[0 360]);
figure('Color','w'); image(rgb,'AlphaData',a); axis image;
% export_colormap('vtk-hsv.csv',lut,'Source','VTK v9.5.2 formula, S-curve');
