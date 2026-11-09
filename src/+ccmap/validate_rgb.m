function rgb = validate_rgb(rgb,allowGray)
%VALIDATE_RGB Validate normalized display-encoded sRGB values without clipping.
if nargin<2, allowGray=false; end
validateattributes(rgb,{'numeric'},{'real','finite','2d','nonempty'},mfilename,'RGB');
rgb=double(rgb);
if allowGray && size(rgb,2)==1, rgb=repmat(rgb,1,3); end
if size(rgb,2)~=3 || any(rgb(:)<0 | rgb(:)>1)
    error('ccmap:InvalidRGB','Expected a nonempty N-by-3 RGB array in [0,1].');
end
end
