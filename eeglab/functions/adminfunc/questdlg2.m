% questdlg2() - inputdlg function clone with coloring and help for 
%               eeglab().
%
% Usage:
%   >> Answer = questdlg2(Prompt,Title,LineNo,DefAns,funcname);
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
% Revision 1.2  2002/08/12 18:02:47  arno
% debug
%
% Revision 1.1  2002/08/12 18:01:34  arno
% Initial revision
%

function [result] = questdlg2(Prompt,Title,varargin);

result = varargin{end};
if nargin < 2
   help questdlg2;
   return;
end;
	
fig = figure;
set(gcf, 'name', Title);

geometry = {};
listui = {};
for index = 1:size(Prompt,1)
	geometry = { geometry{:} [1] };
	listui = {listui{:} { 'Style', 'text', 'string', Prompt(index,:) }};
end;

geometry = { geometry{:} ones(1,length(varargin)-1) };
for index = 1:length(varargin)-1 % ignoring default val
	listui = {listui{:} { 'Style', 'pushbutton', 'string', varargin{index}, 'callback', ['set(gcbf, ''userdata'', ''' varargin{index} ''');'] }  };
	if strcmp(varargin{index}, varargin{end})
		listui{end}{end+1} = 'fontweight';
		listui{end}{end+1} = 'bold';
	end;
end;

[tmp tmp2 allobj] = supergui( geometry, listui{:} );

waitfor( fig, 'userdata');
try,
	result = get(fig, 'userdata');
	close(fig);
end;