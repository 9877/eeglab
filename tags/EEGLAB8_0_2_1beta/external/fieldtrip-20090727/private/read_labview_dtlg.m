function [dat] = read_labview_dtlg(filename, datatype);

% READ_LABVIEW_DTLG
%
% Use as
%   dat = read_labview_dtlg(filename, datatype)
% where datatype can be 'int32' or 'int16'
%
% The output of this function is a structure.

% Copyright (C) 2007, Robert Oostenveld
%
% $Log: not supported by cvs2svn $
% Revision 1.1  2009/01/14 09:24:45  roboos
% moved even more files from fileio to fileio/privtae, see previous log entry
%
% Revision 1.5  2008/09/30 08:01:04  roboos
% replaced all fread(char=>char) into uint8=>char to ensure that the
% chars are read as 8 bits and not as extended 16 bit characters. The
% 16 bit handling causes problems on some internationalized OS/Matlab
% combinations.
%
% the help of fread specifies "If the precision is 'char' or 'char*1', MATLAB
% reads characters using the encoding scheme associated with the file.
% See FOPEN for more information".
%
% Revision 1.4  2007/10/30 09:48:42  roboos
% hopefully fixed problem for files with version [8 0 128 0], where the variable descriptor length could not be determined. Instead of relying on the variable descriptor length, determine whether there are additional offset blocks by looking at "nd"
%
% Revision 1.3  2007/10/08 12:59:32  roboos
% fixed bug in ordering of dimensions (c/fortran)
%
% Revision 1.2  2007/10/04 11:54:45  roboos
% fixed bug in estimating the number of dimensions
%
% Revision 1.1  2007/10/02 15:42:45  roboos
% initial implementation
%


fid     = fopen(filename, 'r', 'ieee-be');

header  = fread(fid, 4, 'uint8=>char')';
if ~strcmp(header, 'DTLG')
  error('unsupported file, header should start with DTLG');
end

version     = fread(fid, 4, 'char')'; % clear version
nd          = fread(fid, 1, 'int32');
p           = fread(fid, 1, 'int32');

% the following seems to work for files with version [7 0 128 0]
% but in files files with version [8 0 128 0] the length of the descriptor is not correct
ld          = fread(fid, 1, 'int16');
descriptor  = fread(fid, ld, 'uint8=>char')';

% ROBOOS: the descriptor should ideally be decoded, since it contains the variable
% name, type and size

% The first offset block always starts immediately after the data descriptor (at offset p, which should ideally be equal to 16+ld)
if nd<=128
  % The first offset block contains the offsets for all data sets.
  % In this case P points to the start of the offset block.
  fseek(fid, p, 'bof');
  offset = fread(fid, 128, 'uint32')';
else
  % The first offset block contains the offsets for the first 128 data sets.
  % The entries for the remaining data sets are stored in additional offset blocks.
  % The locations of those blocks are contained in a block table starting at P.
  offset = [];
  fseek(fid, p, 'bof');
  additional = fread(fid, 128, 'uint32');
  for i=1:sum(additional>0)
    fseek(fid, additional(i), 'bof');
    tmp    = fread(fid, 128, 'uint32')';
    offset = cat(2, offset, tmp);
  end
  clear additional i tmp
end

% ROBOOS: remove the zeros in the offset array for non-existing datasets
offset = offset(1:nd);

% ROBOOS: how to determine the data datatype?
switch datatype
  case 'uint32'
    datasize = 4;
  case 'int32'
    datasize = 4;
  case 'uint16'
    datasize = 2;
  case 'int16'
    datasize = 2;
  otherwise
    error('unsupported datatype');
end

% If the data sets are n-dimensional arrays, the first n u32 longwords in each data
% set contain the array dimensions, imediately followed by the data values.

% ROBOOS: how to determine whether they are n-dimensional arrays?

% determine the number of dimensions by looking at the first array
% assume that all subsequent arrays have the same number of dimensions
if nd>1
  estimate = (offset(2)-offset(1)); % initial estimate for the number of datasize in the array
  fseek(fid, offset(1), 'bof');
  n = fread(fid, 1, 'int32');
  while mod(estimate-4*length(n), (datasize*prod(n)))~=0
    % determine the number and size of additional array dimensions
    n = cat(1, n, fread(fid, 1, 'int32'));
    if datasize*prod(n)>estimate
      error('could not determine array size');
    end
  end
  ndim = length(n);
  clear estimate n
else
  estimate = filesize(fid)-offset;
  fseek(fid, offset(1), 'bof');
  n = fread(fid, 1, 'int32');
  while mod(estimate-4*length(n), (datasize*prod(n)))~=0
    % determine the number and size of additional array dimensions
    n = cat(1, n, fread(fid, 1, 'int32'));
    if datasize*prod(n)>estimate
      error('could not determine array size');
    end
  end
  ndim = length(n);
  clear estimate n 
end

% read the dimensions and the data from each array
for i=1:nd
  fseek(fid, offset(i), 'bof');
  n = fread(fid, ndim, 'int32')';
  % Labview uses the C-convention for storing data, and Matlab uses the Fortran convention
  n = fliplr(n);
  data{i} = fread(fid, n, datatype);
end
clear i n ndim

fclose(fid);

% put all local variables into a structure, this is a bit unusual programming style
% the output structure is messy, but contains all relevant information
tmp = whos;
dat = [];
for i=1:length(tmp)
  if isempty(strmatch(tmp(i).name, {'tmp', 'fid', 'ans', 'handles'}))
    dat = setfield(dat, tmp(i).name, eval(tmp(i).name));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% local helper function to determine the size of the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function siz = filesize(fid)
fp = ftell(fid);
fseek(fid, 0, 'eof');
siz = ftell(fid);
fseek(fid, fp, 'bof');

