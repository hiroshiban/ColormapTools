function meta = export_colormap(filename,lut,varargin)
%EXPORT_COLORMAP Write a normalized sRGB CSV and matching JSON provenance.
% All options describe the supplied LUT; they never change its colors.
lut=ccmap.validate_rgb(lut,true);
p=inputParser;
p.addParameter('Cyclic',false,@(x)islogical(x)&&isscalar(x));
p.addParameter('Source','user supplied LUT',@(x)ischar(x)||isstring(x));
p.addParameter('Notes','',@(x)ischar(x)||isstring(x));
p.parse(varargin{:}); o=p.Results;
[folder,name,ext]=fileparts(filename);
if ~strcmpi(ext,'.csv'), error('ccmap:Export','Export filename must end in .csv.'); end
if ~isempty(folder) && ~isfolder(folder), error('ccmap:Export','Destination directory must exist.'); end
writematrix(lut,filename);
meta=struct('schema_version',1,'name',name,'rows',size(lut,1), ...
    'color_space','display-encoded sRGB','whitepoint','D65','range',[0 1], ...
    'cyclic',o.Cyclic,'source',char(o.Source),'notes',char(o.Notes), ...
    'scalar_mapping','index=min(N,floor(N*u)+1); cyclic uses mod(u,1)', ...
    'matlab_version',version,'csv_sha256',ccmap.file_hash(filename));
fid=fopen(fullfile(folder,[name '.json']),'w','n','UTF-8');
if fid<0, error('ccmap:Export','Cannot open metadata file.'); end
closer=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(meta,'PrettyPrint',true));
end
