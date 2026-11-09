function [rgb,alpha,index] = apply_colormap(values,lut,varargin)
%APPLY_COLORMAP Explicit scalar-to-LUT mapping with no implicit resampling.
% [RGB,A,INDEX]=apply_colormap(V,LUT,'Limits',[lo hi],'Cyclic',false)
% Uses floor(N*u)+1, clamped at N for u=1. Cyclic mapping uses mod(u,1).
% NaN/Inf are transparent. RGB has size [size(V),3].
lut=ccmap.validate_rgb(lut,true);
validateattributes(values,{'numeric'},{'real','2d'});
p=inputParser;
p.addParameter('Limits',[0 1],@(x)isnumeric(x)&&numel(x)==2&&all(isfinite(x))&&x(2)>x(1));
p.addParameter('Cyclic',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('Scale','linear',@(x)ischar(x)||isstring(x));
p.addParameter('OutOfRange','clamp',@(x)ischar(x)||isstring(x));
p.parse(varargin{:}); o=p.Results;
scale=validatestring(lower(char(o.Scale)),{'linear','log'});
outside=validatestring(lower(char(o.OutOfRange)),{'clamp','transparent'});
valid=isfinite(values); lim=o.Limits; v=double(values);
if strcmp(scale,'log')
    if lim(1)<=0 || o.Cyclic, error('ccmap:Scale','Log limits must be positive and noncyclic.'); end
    valid=valid & v>0; v(~valid)=lim(1); v=log(v); lim=log(lim);
end
u=(v-lim(1))/diff(lim);
if strcmp(outside,'transparent'), valid=valid & u>=0 & u<=1; end
u(~valid)=0;
if o.Cyclic, u=mod(u,1); else, u=min(1,max(0,u)); end
index=min(size(lut,1),floor(u*size(lut,1))+1);
rgb=reshape(lut(index(:),:),[size(values),3]); alpha=double(valid);
index(~valid)=0;
end
