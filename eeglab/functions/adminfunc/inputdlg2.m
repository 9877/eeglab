% inputdlg2() - inputdlg function clone with coloring and help for 
%               eeglab().
%
% Usage:
%   >> Answer = inputdlg2(Prompt,Title,LineNo,DefAns,funcname);
% 
% Inputs:
%   Same as inputdlg. Using the optional additionnal funcname parameter 
%   the function will create a help button. The help message will be
%   displayed using the pophelp() function.
%
% Output:
%   Same as inputdlg
%
% Note: The advantage of this function is that the color of the window
%       can be changed and that it display an help button. Edit 
%       supergui to change window options. Also the parameter LineNo
%       can only be one.
%
% Author: Arnaud Delorme, CNL / Salk Institute, La Jolla, 11 August 2002
%
% See also: supergui(), inputgui()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, CNL / Salk Institute, arno@salk.edu
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

function [result] = inputdlg2(Prompt,Title,LineNo,DefAns,funcname);

if nargin < 4
   help inputdlg2;
   return;
end;	
if nargin < 5
	funcname = '';
end;
	
if length(Prompt) ~= length(DefAns)
	error('inputdlg2: prompt and default answer cell array must have the smae size');
end;

geometry = {};
listgui = {};
for index = 1:length(Prompt)
	geometry = { geometry{:} [ 1 1 ]};
	listgui = { listgui{:} { 'Style', 'text', 'string', Prompt{index}}  ...
				   { 'Style', 'edit', 'string', DefAns{index} } };
end;

result = inputgui(geometry, listgui, funcname, Title);
