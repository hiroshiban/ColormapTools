function hex = file_hash(filename)
%FILE_HASH SHA-256 of the exact file bytes using the MATLAB JVM.
fid=fopen(filename,'rb'); if fid<0, error('ccmap:File','Cannot open %s',filename); end
cleanup=onCleanup(@()fclose(fid));
bytes=fread(fid,Inf,'*uint8');
md=java.security.MessageDigest.getInstance('SHA-256'); md.update(bytes);
hex=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
end
