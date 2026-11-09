function [rgb,info] = generate_colormap_from_rgb(colors,n,varargin)
%GENERATE_COLORMAP_FROM_RGB Connect two to four RGB anchor colors.
% RGB=generate_colormap_from_rgb([1 0 0;1 1 1;0 0 1],257)
% [RGB,INFO]=generate_colormap_from_rgb(colors,257,'Method','sinusoidal')
%
% [input]
% colors : 2-to-4-by-3 finite display-encoded sRGB values in [0,1].
%          Normalize byte RGB explicitly, e.g. double(byteColors)/255.
% n      : number of output rows, default 256. Zero returns 0-by-3;
%          one samples the first anchor. Open paths include both endpoints.
%
% [options]
% Method    : 'linear' (default) or 'sinusoidal'; 'cosine' is an alias.
%             Sinusoidal uses w=(1-cos(pi*u))/2 in each anchor interval.
% Positions : increasing anchor positions from 0 to 1; default equal spacing.
% Reverse   : false (default). Reverse the generated output rows.
% Quantize  : false (default). Round the generated colors to 8-bit levels.
%
% [output]
% rgb  : n-by-3 normalized sRGB LUT, compatible with MATLAB colormap.
% info : generation metadata, anchor RGB/positions and interpolation rule.
%
% Sinusoidal interpolation has zero first derivative at the anchors before
% quantization. It does not enforce equal perceptual color steps. This is
% an open path; use generate_colormap / generate_phase_colormap for cycles.
if nargin<1,error('ccmap:RGBAnchors','Provide two to four RGB anchor rows.');end
if nargin<2||isempty(n),n=256;end
colors=ccmap.validate_rgb(colors,false);
if size(colors,1)<2||size(colors,1)>4
    error('ccmap:AnchorCount','Expected two to four RGB anchor rows.');
end
validateattributes(n,{'numeric'},{'scalar','real','finite','integer','nonnegative'});
p=inputParser;
p.addParameter('Method','linear',@(x)ischar(x)||isstring(x));
p.addParameter('Positions',[],@(x)isnumeric(x)&&(isempty(x)||isvector(x)));
p.addParameter('Reverse',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('Quantize',false,@(x)islogical(x)&&isscalar(x));
p.parse(varargin{:});o=p.Results;
method=validatestring(lower(char(o.Method)),{'linear','sinusoidal','cosine'});
coreMethod=method;if strcmp(coreMethod,'sinusoidal'),coreMethod='cosine';end
positions=o.Positions;
if isempty(positions),positions=linspace(0,1,size(colors,1))';else,positions=double(positions(:));end
if ~isreal(positions)||numel(positions)~=size(colors,1)||any(~isfinite(positions))|| ...
        positions(1)~=0||positions(end)~=1||any(diff(positions)<=0)
    error('ccmap:Positions','Positions must match the anchors, increase strictly and cover [0,1].');
end
[rgb,info]=generate_colormap(colors,n,'Method',coreMethod,'Positions',positions, ...
    'Cyclic',false,'Reverse',o.Reverse,'Quantize',o.Quantize);
info.Source='numeric RGB anchors';info.SourceKind='rgb-anchors';
info.RequestedMethod=method;info.Reverse=o.Reverse;info.AnchorRGB=colors;info.AnchorPositions=positions;
info.InterpolationDefinition='linear: w=u; sinusoidal/cosine: w=(1-cos(pi*u))/2';
end
