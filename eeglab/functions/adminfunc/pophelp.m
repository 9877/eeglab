% pophelp() - Same as hthelp() but does not crash under windows.
%
% Usage: >> pophelp( function );
%        >> pophelp( function, nonmatlab );
%
% Inputs:
%   function  - string for a Matlab function name 
%               (with or without the '.m' extension).
%   nonmatlab - [0|1], 1 the file is not a Matlab file
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: eeglab() 

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: not supported by cvs2svn $
% Revision 1.2  2002/07/29 15:50:15  arno
% can also read non-matlab files
%
% Revision 1.1  2002/04/05 17:39:45  jorn
% Initial revision
%
% 01-25-02 reformatted help & license -ad 
% 3/19/02 Edited help message (below) -sm 

function pophelp( funct, nonmatlab );

if nargin <1
	help pophelp;
	return;
end;
if nargin <2
	nonmatlab = 0;
end;

doc = {};

if nonmatlab
	fid = fopen( funct, 'r');
else
	if findstr( funct, '.m')
		fid = fopen( funct, 'r');
	else
		fid = fopen( [funct '.m'], 'r');
	end;
end;

if fid == -1
	error('File not found');
end;

if nonmatlab
	str = fgets( fid );
	while ~feof(fid)
		str = deblank(str(1:end-1));
		
		doc = { doc{:} str(2:end) };
		str = fgets( fid );
	end;
else
	str = fgets( fid );
	while (str(1) == '%')
		str = deblank(str(1:end-1));
		
		doc = { doc{:} str(2:end) };
		str = fgets( fid );
	end;
end;

textgui(doc);
return;
