function [out,info] = simulate_color_vision(rgb,type)
%SIMULATE_COLOR_VISION Machado et al. (2009), severity 100 matrices.
% TYPE: protan, deutan, tritan. Linear-light transform, then gamut clipping.
% Simulation is a model-based diagnostic, not an accessibility certificate.
% Matrix provenance: colorspacious 1.1.2 cvd.py (Machado supplemental tables).
rgb=ccmap.validate_rgb(rgb,true);
type=validatestring(lower(char(type)),{'protan','deutan','tritan'});
switch type
    case 'protan'
        M=[.152286 1.052583 -.204868;.114503 .786281 .099216;-.003882 -.048116 1.051998];
    case 'deutan'
        M=[.367322 .860646 -.227968;.280085 .672501 .047413;-.011820 .042940 .968881];
    case 'tritan'
        M=[1.255528 -.076749 -.178779;-.078411 .930809 .147602;.004733 .691367 .303900];
end
linear=ccmap.srgb_decode(rgb)*M';
info=struct('Type',type,'Severity',100,'ClippedChannelFraction',mean(linear(:)<0|linear(:)>1), ...
    'Model','Machado et al. 2009','TransformSpace','linear-light sRGB');
out=ccmap.srgb_encode(min(1,max(0,linear)));
end
