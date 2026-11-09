function [imageRGB,alpha,meta] = colormap_legend(lut,format,varargin)
%COLORMAP_LEGEND Render a legend image without opening a figure.
% Formats: horizontal, vertical, swatches, wheel, ring, wedge, semicircle,
% eccentricity, phase-amplitude. Returns truecolor RGB, alpha and metadata.
% OriginDegrees: 0=right, 90=up (Cartesian). Default 90 (12 o'clock).
% Direction: clockwise (default) or counterclockwise, in displayed image.
% Angular value 0 occurs at OriginDegrees. PhaseDegrees advances the LUT.
% Circular center is undefined and transparent for angle-based formats.
% A phase-amplitude disk mixes toward NeutralColor in encoded sRGB; this is
% a visualization option, not a perceptually uniform bivariate encoding.
lut=ccmap.validate_rgb(lut,true);
if nargin<2 || isempty(format), format='horizontal'; end
format=validatestring(lower(char(format)),{'horizontal','vertical','swatches','wheel','ring','wedge','semicircle','eccentricity','phase-amplitude'});
p=inputParser;
p.addParameter('Size',401,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>=3&&fix(x)==x);
p.addParameter('Thickness',40,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>=1&&fix(x)==x);
p.addParameter('OriginDegrees',90,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x));
p.addParameter('Direction','clockwise',@(x)ischar(x)||isstring(x));
p.addParameter('PhaseDegrees',0,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x));
p.addParameter('InnerRadius',.65,@(x)isnumeric(x)&&isscalar(x)&&x>=0&&x<1);
p.addParameter('AngleRange',[0 90],@(x)isnumeric(x)&&numel(x)==2&&all(isfinite(x))&&x(2)>x(1)&&diff(x)<=360);
p.addParameter('Cyclic',[],@(x)isempty(x)||(islogical(x)&&isscalar(x)));
p.addParameter('Method','bins',@(x)ischar(x)||isstring(x));
p.addParameter('Reverse',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('RadialScale','linear',@(x)ischar(x)||isstring(x));
p.addParameter('RadialLimits',[0 1],@(x)isnumeric(x)&&numel(x)==2&&all(isfinite(x))&&x(2)>x(1));
p.addParameter('NeutralColor',[1 1 1],@(x)isnumeric(x)&&numel(x)==3);
p.parse(varargin{:}); o=p.Results;
direction=validatestring(lower(char(o.Direction)),{'clockwise','counterclockwise'});
method=validatestring(lower(char(o.Method)),{'bins','nearest','linear','cosine','smoothstep','smootherstep','pchip'});
scale=validatestring(lower(char(o.RadialScale)),{'linear','log'});
neutral=ccmap.validate_rgb(reshape(o.NeutralColor,1,3));
if strcmp(scale,'log') && o.RadialLimits(1)<=0, error('ccmap:RadialLimits','Log radial limits must be positive.'); end
angular=any(strcmp(format,{'wheel','ring','wedge','semicircle','phase-amplitude'}));
cyclic=angular; if ~isempty(o.Cyclic), cyclic=o.Cyclic; end
if o.Reverse, lut=flipud(lut); end
N=o.Size;
if any(strcmp(format,{'horizontal','vertical','swatches'}))
    if cyclic, u=(0:N-1)/N; else, u=linspace(0,1,N); end
    if strcmp(format,'swatches')
        colors=legend_sample(lut,(0:N-1)/N+o.PhaseDegrees/360,'bins',cyclic);
    else
        colors=legend_sample(lut,u+o.PhaseDegrees/360,method,cyclic);
    end
    imageRGB=repmat(reshape(colors,[1 N 3]),[o.Thickness 1 1]);
    if strcmp(format,'vertical'), imageRGB=flipud(permute(imageRGB,[2 1 3])); end
    alpha=ones(size(imageRGB,1),size(imageRGB,2));
    values=repmat(u,o.Thickness,1);
    if strcmp(format,'vertical'), values=flipud(values'); end
    radius=[]; angle=[];
else
    % Positive y points upward although raster rows increase downward.
    coords=linspace(-1,1,N); [x,y]=meshgrid(coords,-coords);
    radius=hypot(x,y); angle=atan2d(y,x);
    if strcmp(direction,'clockwise'), phi=mod(o.OriginDegrees-angle,360); else, phi=mod(angle-o.OriginDegrees,360); end
    u=phi/360;
    alpha=double(radius<=1);
    if angular, alpha(radius<1/max(1,N-1))=0; end
    if strcmp(format,'ring'), alpha(radius<o.InnerRadius)=0; end
    if any(strcmp(format,{'wedge','semicircle'}))
        range=o.AngleRange; if strcmp(format,'semicircle'), range=[0 180]; end
        phase=mod(phi-range(1),360);
        alpha(phase>diff(range))=0;
    end
    if strcmp(format,'eccentricity')
        if strcmp(scale,'log')
            radialValue=o.RadialLimits(1)+min(radius,1)*diff(o.RadialLimits);
            u=log(radialValue/o.RadialLimits(1))/log(o.RadialLimits(2)/o.RadialLimits(1));
        else
            u=min(radius,1);
        end
    end
    colors=legend_sample(lut,u(:)+o.PhaseDegrees/360,method,cyclic);
    imageRGB=reshape(colors,[N N 3]);
    if strcmp(format,'phase-amplitude')
        weight=min(radius,1);
        imageRGB=imageRGB.*weight+reshape(neutral,1,1,3).*(1-weight);
    end
    values=u;
end
function colors=legend_sample(lut,u,method,cyclic)
if strcmp(method,'bins')
    if cyclic, u=mod(u(:),1); else, u=min(1,max(0,u(:))); end
    idx=min(size(lut,1),floor(u*size(lut,1))+1);
    colors=lut(idx,:);
else
    colors=ccmap.sample(lut,u,method,cyclic);
end
end
meta=struct('Format',format,'OriginDegrees',o.OriginDegrees,'Direction',direction, ...
    'PhaseDegrees',o.PhaseDegrees,'Cyclic',cyclic,'Reverse',o.Reverse, ...
    'RadialScale',scale,'RadialLimits',o.RadialLimits,'Method',method, ...
    'NormalizedValue',values,'Radius',radius,'AngleDegrees',angle);
end
