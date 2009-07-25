function [matrix, extra] = read_mat(fn);

% READ_MAT reads a matrix from an ascii or binary MBF format file
%
%  Usage: m         = loadmat('file');
%     or  [m,extra] = loadmat('file');
%  
%  LOADMAT('file') returns the matrix stored in 'file' and
%  the extra information stored at the bottom of that file.
%  LOADMAT works for binary as well as asci matrix files.
%  
%  See also WRITE_MAT

% Copyright (C) 1998, Thom Oostendorp 
%
% $Log: not supported by cvs2svn $
% Revision 1.1  2009/01/14 09:24:45  roboos
% moved even more files from fileio to fileio/privtae, see previous log entry
%
% Revision 1.3  2008/09/30 07:47:04  roboos
% replaced all occurences of setstr() with char(), because setstr is deprecated by Matlab
%
% Revision 1.2  2003/03/11 15:24:51  roberto
% updated help and copyrights
%

f=fopen(fn);
if (f==-1)
  fprintf('\nCannot open %s\n\n', fn);
  result=0;
  extra='';
  return;
end

[N,nr]=fscanf(f,'%d',2);
if (nr~=2)
  fclose(f);
  f=fopen(fn);
  [magic ,nr]=fread(f,8,'char');
  if (char(magic')==';;mbfmat')
    fread(f,1,'char');
    hs=fread(f,1,'long');
    fread(f,1,'char');
    fread(f,1,'char');
    fread(f,1,'char');
    N=fread(f,2,'long');
    M=fread(f,[N(2),N(1)],'double');
  else
    fclose(f);
    f=fopen(fn);
    N=fread(f,2,'long');
    M=fread(f,[N(2),N(1)],'float');
  end
else
  M=fscanf(f,'%f',[N(2) N(1)]);
end

[extra,nextra]=fread(f,1000,'char');
fclose(f);
S=sprintf('\n%s contains %d rows and %d columns\n', fn, N(1), N(2));
disp(S);
if (nextra~=0)
  S=sprintf('%s contains the following extra information:\n', fn);
  disp(S);
  disp(char(extra'));
end

matrix=M';
extra=char(extra');

