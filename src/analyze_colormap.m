function result = analyze_colormap(rgb,varargin)
%ANALYZE_COLORMAP Report separate continuity, lightness and Delta E76 metrics.
% Cyclic=true includes the last-to-first adjacent step; it does not assume
% the last row duplicates the first. Interpretation depends on map topology.
p=inputParser;
p.addParameter('Cyclic',false,@(x)islogical(x)&&isscalar(x));
p.parse(varargin{:}); cyclic=p.Results.Cyclic;
rgb=ccmap.validate_rgb(rgb,true); [lab,Y]=ccmap.rgb2lab(rgb);
if cyclic, a=[rgb;rgb(1,:)]; b=[lab;lab(1,:)]; else, a=rgb; b=lab; end
d=diff(a,1,1); de=sqrt(sum(diff(b,1,1).^2,2));
dl=diff(lab(:,1)); nz=sign(dl(abs(dl)>1e-6));
if numel(nz)>1, turns=sum(diff(nz)~=0); else, turns=0; end
if isempty(de), mn=NaN; cv=NaN; near=NaN; ratio=NaN; else
    mn=mean(de); cv=std(de,1)/max(eps,mn);
    near=mean(de<.05*mn); ratio=norm(lab(end,:)-lab(1,:))/max(eps,mn);
end
if cyclic && size(d,1)>1, dd=diff([d;d(1,:)],1,1); else, dd=diff(d,1,1); end
if isempty(dd), curvature=NaN; else, curvature=max(sqrt(sum(dd.^2,2))); end
result=struct('N',size(rgb,1),'Cyclic',cyclic,'LightnessMin',min(lab(:,1)), ...
    'LightnessMax',max(lab(:,1)),'LightnessTurns',turns,'MeanDeltaE76',mn, ...
    'DeltaE76CV',cv,'NearStationaryFraction',near,'EndpointDeltaE76',norm(lab(end,:)-lab(1,:)), ...
    'SeamToMeanStep',ratio,'MaxRGBSecondDifference',curvature, ...
    'Unique8BitColors',size(unique(floor(rgb*255+.5),'rows'),1), ...
    'Lightness',lab(:,1),'RelativeLuminance',Y,'DeltaE76',de,'RGBSteps',d);
for mode={'protan','deutan','tritan'}
    [c,info]=simulate_color_vision(rgb,mode{1}); lc=ccmap.rgb2lab(c);
    if cyclic, delta=lc([2:end 1],:)-lc; else, delta=diff(lc,1,1); end
    steps=sqrt(sum(delta.^2,2));
    result.([mode{1} 'MeanDeltaE76'])=mean(steps);
    result.([mode{1} 'ClippedFraction'])=info.ClippedChannelFraction;
end
end
