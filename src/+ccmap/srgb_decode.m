function linear = srgb_decode(rgb)
%SRGB_DECODE IEC sRGB transfer curve, input normalized encoded channels.
linear=rgb/12.92; mask=rgb>0.04045;
linear(mask)=((rgb(mask)+0.055)/1.055).^2.4;
end
