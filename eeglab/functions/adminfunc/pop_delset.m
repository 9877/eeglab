% pop_delset() - Delete a dataset into the global variable containing
%                all datasets.
%
% Usage: >> ALLEEG = pop_delset(ALLEEG, indexes);
%
% Inputs:
%   ALLEEG   - array of EEG datasets
%   indexes  - Indexes of datasets to delete. If no index is given,
%              a pop_up window asks the user to choose.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: pop_copyset(), eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

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

% uses the global variable ALLEEG CURRENTSET 

% $Log: not supported by cvs2svn $
% Revision 1.1  2002/04/05 17:46:04  jorn
% Initial revision
%
% 01-25-02 reformated help & license -ad 

% load a set and store it in the current set
% ------------------------------------------
function [ALLSET, command] = pop_delset(ALLSET, set_in);

command = '';
if nargin < 1
	help pop_delset;
	return;
end;
if isempty( ALLSET )
    return;
end;    

if nargin < 2
	% which set to delete
	% -----------------
	promptstr    = { 'Enter the dataset(s) to delete:' };
	inistr       = { int2str(CURRENTSET) };
	result       = inputdlg( promptstr, 'Delete dataset -- pop_delset()', 1,  inistr);
	size_result  = size( result );
	if size_result(1) == 0 return; end;
	set_in   	 = eval( [ '[' result{1} ']' ] );
end;

if isempty(set_in)
	return;
end;	

A = fieldnames( ALLSET );
A(:,2) = cell(size(A));
A = A';
for i = set_in
   try
   		ALLSET(i) = struct(A{:});
		%ALLSET = setfield(ALLSET, {set_in}, A{:}, cell(size(A)));
	catch
		error('Error: no such dataset');
		return;
	end;
end;

% find a new non-empty dataset
% ----------------------------   
if ismember(CURRENTSET, set_in)
	CURRENTSET = 0;
	index = 1;
	while( index <= MAX_SET)
		try, ALLSET(index).data;
			if ~isempty( ALLSET(index).data)
				CURRENTSET = index;
				break;
			end;	
		catch, end;	
 		index = index+1;
	end;
end;
    
command = sprintf('%s = pop_delset( %s, [%s] );', inputname(1), int2str(set_in));
return;
