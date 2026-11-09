function [rgb,info] = generate_phase_colormap(source,n,varargin)
%GENERATE_PHASE_COLORMAP Explicit periodic sampling and phase convention.
% PhaseDegrees is the source phase at output row 1. Positive phase advances
% the source. Reverse changes the direction of phase progression. Cycles
% must be a positive integer; Alternating=true traverses an OPEN map forward
% then backward (each traversal counts as one cycle).
if nargin<1 || isempty(source), source='hsv-scurve'; end
if nargin<2 || isempty(n), n=360; end
validateattributes(n,{'numeric'},{'scalar','integer','nonnegative','finite'});
p=inputParser;
p.addParameter('PhaseDegrees',0,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x));
p.addParameter('Cycles',1,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>=1&&fix(x)==x);
p.addParameter('Reverse',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('Alternating',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('Method','linear',@(x)ischar(x)||isstring(x));
p.parse(varargin{:}); o=p.Results;
if isnumeric(source), lut=ccmap.validate_rgb(source,true); else
    lut=generate_colormap(source,4096,'Cyclic',~o.Alternating);
end
method=validatestring(lower(char(o.Method)),{'linear','cosine','smoothstep','smootherstep','pchip','nearest'});
t=(0:n-1)'/max(1,n); s=1; if o.Reverse, s=-1; end
phase=s*o.Cycles*t+o.PhaseDegrees/360;
if o.Alternating
    q=mod(phase,2); u=1-abs(1-q);
    rgb=ccmap.sample(lut,u,method,false);
else
    rgb=ccmap.sample(lut,mod(phase,1),method,true);
end
info=struct('PhaseDegrees',o.PhaseDegrees,'Cycles',o.Cycles,'Reverse',o.Reverse, ...
    'Alternating',o.Alternating,'Sampling','half-open','Method',method);
end
