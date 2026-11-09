function rgb = sample(lut,t,method,cyclic,positions)
%SAMPLE Resample an sRGB path. Cyclic output omits a duplicate endpoint.
if nargin<3, method='linear'; end
if nargin<4, cyclic=false; end
m=size(lut,1);
if m==1, rgb=repmat(lut,numel(t),1); return; end
if nargin<5 || isempty(positions)
    if cyclic
        if max(abs(lut(1,:)-lut(end,:)))<1e-12
            lut(end,:)=[]; m=m-1;
        end
        positions=(0:m-1)'/m;
    else
        positions=linspace(0,1,m)';
    end
end
if cyclic
    if positions(1)~=0 || positions(end)>=1
        error('ccmap:Positions','Cyclic anchor positions must start at 0 and end below 1.');
    end
    positions=[positions;1]; lut=[lut;lut(1,:)];
    t=mod(t(:),1);
else
    t=min(1,max(0,t(:)));
end
if numel(positions)==1, rgb=repmat(lut(1,:),numel(t),1); return; end
if any(strcmp(method,{'linear','nearest','pchip'}))
    rgb=interp1(positions,lut,t,method);
else
    % Local easing keeps each channel inside the convex hull of its anchors.
    idx=discretize(t,positions);
    idx(t==positions(end))=numel(positions)-1;
    u=(t-positions(idx))./(positions(idx+1)-positions(idx));
    switch method
        case 'cosine', w=(1-cos(pi*u))/2;
        case 'smoothstep', w=u.^2.*(3-2*u);
        case 'smootherstep', w=u.^3.*(10-15*u+6*u.^2);
        otherwise, error('ccmap:Method','Unsupported interpolation method.');
    end
    rgb=lut(idx,:)+(lut(idx+1,:)-lut(idx,:)).*w;
end
% PCHIP/easing are bounded here; remove floating point excursions only.
if any(rgb(:)<-1e-12 | rgb(:)>1+1e-12)
    error('ccmap:InterpolationGamut','Interpolation produced values outside sRGB.');
end
rgb=min(1,max(0,rgb));
end
