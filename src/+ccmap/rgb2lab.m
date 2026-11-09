function [lab,Y] = rgb2lab(rgb)
%RGB2LAB CIELAB, sRGB primaries, D65 white, CIE 1931 2-degree observer.
% Diagnostic model only. Delta E76 is not a behavioral performance score.
linear=ccmap.srgb_decode(rgb);
xyz=linear*[0.4124564 0.2126729 0.0193339; ...
            0.3575761 0.7151522 0.1191920; ...
            0.1804375 0.0721750 0.9503041];
Y=xyz(:,2);
v=xyz./[0.95047 1 1.08883];
d=6/29; f=v/(3*d*d)+4/29; mask=v>d^3; f(mask)=v(mask).^(1/3);
lab=[116*f(:,2)-16,500*(f(:,1)-f(:,2)),200*(f(:,2)-f(:,3))];
end
