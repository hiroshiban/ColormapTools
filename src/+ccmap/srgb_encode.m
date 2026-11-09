function rgb = srgb_encode(linear)
%SRGB_ENCODE IEC sRGB transfer curve; negative values use the linear branch.
rgb=12.92*linear; mask=linear>0.0031308;
rgb(mask)=1.055*linear(mask).^(1/2.4)-0.055;
end
