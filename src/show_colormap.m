function [h,meta] = show_colormap(lut,format,varargin)
%SHOW_COLORMAP Display a truecolor legend with optional annotated axes.
% Name/value arguments shared with colormap_legend, plus Parent (axes),
% Title, Limits and Label. PNG transparency: use colormap_legend + imwrite.
p=inputParser; p.KeepUnmatched=true;
p.addParameter('Parent',[],@(x)isempty(x)||isgraphics(x,'axes'));
p.addParameter('Title','',@(x)ischar(x)||isstring(x));
p.addParameter('Limits',[0 1],@(x)isnumeric(x)&&numel(x)==2&&all(isfinite(x))&&x(2)>x(1));
p.addParameter('Label','',@(x)ischar(x)||isstring(x));
p.addParameter('TickValues',[],@(x)isnumeric(x)&&isvector(x)||isempty(x));
p.addParameter('TickLabels',{},@(x)iscellstr(x)||isstring(x));
p.parse(varargin{:}); o=p.Results;
args={}; names=fieldnames(p.Unmatched);
for k=1:numel(names), args=[args {names{k},p.Unmatched.(names{k})}]; end %#ok<AGROW>
[rgb,a,meta]=colormap_legend(lut,format,args{:});
ax=o.Parent; if isempty(ax), figure('Color','w'); ax=axes; end
if strcmp(meta.Format,'horizontal') || strcmp(meta.Format,'swatches')
    h=image(ax,'XData',o.Limits,'YData',[0 1],'CData',rgb,'AlphaData',a);
    set(ax,'YTick',[],'YDir','normal'); xlabel(ax,o.Label); xlim(ax,o.Limits);
    if ~isempty(o.TickValues), xticks(ax,o.TickValues); end
    if ~isempty(o.TickLabels), xticklabels(ax,o.TickLabels); end
elseif strcmp(meta.Format,'vertical')
    h=image(ax,'XData',[0 1],'YData',o.Limits,'CData',flipud(rgb),'AlphaData',flipud(a));
    set(ax,'XTick',[],'YDir','normal'); ylabel(ax,o.Label); ylim(ax,o.Limits);
    if ~isempty(o.TickValues), yticks(ax,o.TickValues); end
    if ~isempty(o.TickLabels), yticklabels(ax,o.TickLabels); end
else
    h=image(ax,'XData',[-1 1],'YData',[-1 1],'CData',rgb,'AlphaData',a);
    set(ax,'YDir','reverse'); axis(ax,'image'); axis(ax,'off');
    if ~isempty(o.TickValues)
        ticks=o.TickValues; labels=cellstr(string(ticks));
        if ~isempty(o.TickLabels)
            if numel(o.TickLabels)~=numel(ticks), error('ccmap:TickLabels','TickValues and TickLabels must match in length.'); end
            labels=cellstr(o.TickLabels);
        end
        holdState=ishold(ax); hold(ax,'on');
        if strcmp(meta.Format,'eccentricity')
            r=(ticks-meta.RadialLimits(1))/diff(meta.RadialLimits);
            plot(ax,[0 1],[0 0],'-','Color',[.2 .2 .2]);
            for k=1:numel(ticks), text(ax,r(k),.1,labels{k},'HorizontalAlignment','center','BackgroundColor','w'); end
        else
            s=1; if strcmp(meta.Direction,'clockwise'), s=-1; end
            angle=meta.OriginDegrees+s*360*(ticks-o.Limits(1))/diff(o.Limits);
            for k=1:numel(ticks)
                text(ax,1.13*cosd(angle(k)),-1.13*sind(angle(k)),labels{k},'HorizontalAlignment','center');
            end
        end
        if ~holdState, hold(ax,'off'); end
        xlim(ax,[-1.3 1.3]); ylim(ax,[-1.3 1.3]);
    end
end
title(ax,o.Title,'Interpreter','none');
end
