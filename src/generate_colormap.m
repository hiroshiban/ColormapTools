function [rgb,info] = generate_colormap(source,n,varargin)
%GENERATE_COLORMAP Generate a named map or resample an RGB LUT/CSV file.
% [RGB,INFO]=generate_colormap('owp',257,'Method','cosine')
% RGB=generate_colormap('hsv-scurve',360)
% RGB=generate_colormap('vtk-hsv',361,'Quantize',true)
% RGB=generate_colormap('my_lut.csv',256,'Cyclic',true)
% Methods: linear (default), cosine, smoothstep, smootherstep, pchip, nearest.
% Built-in anchor names read data/anchors/*.csv, so additions need no code.
% Input/output are normalized display-encoded sRGB, NOT linear-light RGB.
% Cyclic uses [0,1); open paths use [0,1]. N=1 samples the first color.
% VTK presets implement vtkLookupTable ForceBuild (VTK v9.5.2).
% Quantize=true applies its uint8 conversion rules.
if nargin<1 || isempty(source), source='owp'; end
if nargin<2 || isempty(n), n=256; end
validateattributes(n,{'numeric'},{'scalar','real','finite','integer','nonnegative'});
p=inputParser;
p.addParameter('Method','linear',@(x)ischar(x)||isstring(x));
p.addParameter('Cyclic',[],@(x)isempty(x)||(islogical(x)&&isscalar(x)));
p.addParameter('Reverse',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('Quantize',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('HueRange',[],@(x)isnumeric(x)&&(isempty(x)||numel(x)==2));
p.addParameter('Positions',[],@(x)isnumeric(x)&&isvector(x)||isempty(x));
p.parse(varargin{:}); o=p.Results;
method=validatestring(lower(char(o.Method)),{'linear','cosine','smoothstep','smootherstep','pchip','nearest'});
info=struct('Source','','Cyclic',false,'Method',method,'Sampling','closed', ...
    'ColorSpace','display-encoded sRGB','Quantized',o.Quantize,'SourceKind','');
special=''; lut=[];
if isnumeric(source)
    lut=ccmap.validate_rgb(source,true); info.Source='numeric LUT'; info.SourceKind='lut';
else
    name=char(source); info.Source=name;
    if isfile(name)
        lut=ccmap.validate_rgb(readmatrix(name),true); info.SourceKind='csv';
    else
        name=lower(name);
        switch name
            case {'hsv','hsv-scurve','vtk-hsv','vtk-rygb'}
                special=name; info.SourceKind='analytic';
                info.Cyclic=any(strcmp(name,{'hsv','hsv-scurve'}));
            otherwise
                anchorPath=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data','anchors',[name '.csv']);
                if ~isfile(anchorPath), error('ccmap:UnknownMap','Unknown map or CSV file: %s',name); end
                lut=ccmap.validate_rgb(readmatrix(anchorPath),true); info.SourceKind='anchors';
        end
    end
end
if ~isempty(o.Cyclic), info.Cyclic=o.Cyclic; end
if info.Cyclic, info.Sampling='half-open'; end
if n==0, rgb=zeros(0,3); return; end
if info.Cyclic, t=(0:n-1)'/n; elseif n==1, t=0; else, t=linspace(0,1,n)'; end
if ~isempty(special)
    if ~strcmp(method,'linear') || ~isempty(o.Positions)
        error('ccmap:AnalyticOptions','Analytic HSV maps use their defining formula; Method/Positions apply to LUTs.');
    end
    hueRange=o.HueRange;
    if isempty(hueRange)
        switch special
            case 'vtk-hsv', hueRange=[0 .9];
            case 'vtk-rygb', hueRange=[0 .66667];
            otherwise, hueRange=[0 1];
        end
    end
    validateattributes(hueRange,{'numeric'},{'real','finite','>=',0,'<=',1,'numel',2});
    h=hueRange(1)+(hueRange(2)-hueRange(1))*t;
    rgb=hsv2rgb([h ones(n,2)]);
    if any(strcmp(special,{'hsv-scurve','vtk-hsv','vtk-rygb'}))
        % Use VTK's expression to match floating point truncation as closely
        % as MATLAB and the C++ platform allow (no rounding for S-curve).
        rgb=(1+cos((1-rgb)*pi))/2;
        info.Method='component S-curve';
        if o.Quantize, rgb=floor(255*rgb)/255; end
    elseif o.Quantize
        rgb=floor(255*rgb+.5)/255;
    end
    info.HueRange=hueRange;
else
    if ~isempty(o.HueRange), error('ccmap:HueRange','HueRange only applies to analytic HSV maps.'); end
    positions=o.Positions;
    if ~isempty(positions)
        positions=double(positions(:));
        if numel(positions)~=size(lut,1) || any(~isfinite(positions)) || any(diff(positions)<=0) || ...
                positions(1)~=0 || positions(end)>1 || (~info.Cyclic && size(lut,1)>1 && positions(end)~=1)
            error('ccmap:Positions','Positions must be strictly increasing, match the LUT, start at 0 and cover [0,1].');
        end
    end
    rgb=ccmap.sample(lut,t,method,info.Cyclic,positions);
    if o.Quantize, rgb=floor(255*rgb+.5)/255; end
end
if o.Reverse, rgb=flipud(rgb); end
end
