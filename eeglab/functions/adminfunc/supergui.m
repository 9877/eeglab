% supergui() - a comprehensive gui automatic builder. This function help
%              to create GUI very fast without bothering about the 
%              positions of the elements. After creating a geometry, 
%              elements just place themselves into the predefined 
%              locations. It is especially usefull for figure where you
%              intend to put text button and descriptions.
%
% Usage:
%   >> [handlers, width, height ] = ...
%             supergui( geometry, { arguments1 }, { arguments2 }... );
% 
% Inputs:
%   geometry   - array describing the geometry of the elements
%                in the figure. For instance, [2 3 2] means that the
%                figures will have 3 rows, with 2 elements in the first
%                and last row and 3 elements in the second row.
%                An other syntax is { [2 8] [1 2 3] } which means
%                that figures will have 2 rows, the first one with 2
%                elements of relative width 2 and 8 (20% and 80%). The
%                second row will have 3 elements of relative size 1, 2 
%                and 3.
%   {argument} - GUI matlab element arguments. Ex { 'style', 
%                'radiobutton', 'String', 'hello' }.
%
% Hint:
%    use 'print -mfile filemane' to save a matlab file of the figure.
%
% Output:
%    handlers  - all the handler of the elements (in the same form as the
%                geometry cell input.
%    height    - adviced widht for the figure (so the text look nice).   
%    height    - adviced height for the figure (so the text look nice).   
%
% Example:
%    figure;   
%    supergui( [1 1], { 'style', 'radiobutton', 'string', 'radio' }, ...
%        { 'style', 'pushbutton', 'string', 'push' });
%      
% Author: Arnaud Delorme, CNL / Salk Institute, La Jolla, 2001
%
% See also: eeglab()

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

% $Log: not supported by cvs2svn $
% Revision 1.14  2002/08/12 21:42:59  arno
% ignore pushbutton extent
%
% Revision 1.13  2002/08/12 16:00:57  arno
% same
%
% Revision 1.12  2002/08/12 16:00:13  arno
% do not adapt size for edit windows
%
% Revision 1.11  2002/08/12 15:57:04  arno
% size calculation
%
% Revision 1.10  2002/08/12 14:50:15  arno
% color
%
% Revision 1.9  2002/08/12 14:47:40  arno
% color
%
% Revision 1.8  2002/08/12 14:30:55  arno
% background
%
% Revision 1.7  2002/08/12 01:17:42  arno
% update colors
%
% Revision 1.6  2002/08/12 00:41:41  arno
% updating default colors
%
% Revision 1.5  2002/07/18 17:18:31  arno
% offscreen correction
%
% Revision 1.4  2002/07/18 17:13:05  arno
% same
%
% Revision 1.3  2002/07/18 17:11:19  arno
% correct out-of screen problem
%
% Revision 1.2  2002/07/18 17:07:40  arno
% no modif
%
% Revision 1.1  2002/04/05 17:39:45  jorn
% Initial revision
%

function [handlers, outheight, allhandlers] = supergui( geometry, varargin);

% handlers cell format
% allhandlers linear format

INSETX = 0.05; % x border absolute (5% of width)
INSETY = 0.15;  % y border relative (50% of heigth)  

if nargin < 2
	help supergui;
	return;
end;

% converting the geometry formats
% -------------------------------
if ~iscell( geometry )
	oldgeom = geometry;
	geometry = {};
	for row = 1:length(oldgeom)
		geometry = { geometry{:} ones(1, oldgeom(row)) };
	end;
end;		

% setting relative size in percent
% --------------------------------
for row = 1:length(geometry)
	tmprow = geometry{row};
	sumrow = sum(geometry{row});
	geometry{row} = 1.05*geometry{row}/sumrow;
	geometry{row} = geometry{row} - INSETX*(length(tmprow)-1)/length(tmprow);
end;
			
set(gcf, 'menubar', 'none', 'numbertitle', 'off');		
pos = get(gca,'position'); % plot relative to current axes
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]; % allow to use normalized position [0 100] for x and y
axis('off');

counter = 1; % count the elements
outwidth = 0;
outheight = 0;
height = 1.05/(length(geometry)+1)*(1-INSETY);
posy = 1 - height - 1/length(geometry)*INSETY;
factmultx = 0;
factmulty = 0;
for row = 1:length(geometry)

	% init
    posx = -0.05;
	clear rowhandle;
	tmprow = geometry{row};
    
	for column = 1:length(tmprow)

		width  = tmprow(column);
		try
			currentelem = varargin{ counter };
		catch
			fprintf('Warning: not all boxes were filled\n');
			return;
		end;		
		if ~isempty(currentelem)
			rowhandle(column) = uicontrol( 'unit', 'normalized', 'position', ...
						                      [posx posy width height].*s+q, currentelem{:});
			
			% this simply compute a factor so that all uicontrol will be visible
			% ------------------------------------------------------------------
			style = get(rowhandle(column), 'style');
			if ~strcmp(style, 'edit') & ~strcmp(style, 'pushbutton')
				set( rowhandle(column), 'units', 'pixels');			
				curpos = get(rowhandle(column), 'position');
				curext = get(rowhandle(column), 'extent');
				factmultx = max(factmultx, curext(3)/curpos(3));
				factmulty = max(factmulty, curext(4)/curpos(4));
				set( rowhandle(column), 'units', 'normalized');			
			end;
			
        else 
			rowhandle(column) = 0;
		end;
		
		handlers{ row } = rowhandle;
		allhandlers(counter) = rowhandle(column);
		
		posx   = posx + width + INSETX;
		counter = counter+1;
	end;
	posy      = posy - height - 1/length(geometry)*INSETY; %compensate for inset 
end;

%scale and replace the figure in the screen
pos = get(gcf, 'position');
if factmulty > 1
	pos(2) = max(0,pos(2)+pos(4)-pos(4)*factmulty)
end;
pos(1) = pos(1)+pos(3)*(1-factmultx)/2;
pos(3) = pos(3)*factmultx;
pos(4) = pos(4)*factmulty;
set(gcf, 'position', pos);

% setting defaults colors
%------------------------
try, icadefs;
catch,
	GUIBACKCOLOR        =  [.8 .8 .8];     
	GUIPOPBUTTONCOLOR   = [.8 .8 .8];    
	GUITEXTCOLOR        = [0 0 0];
end;

hh = findobj(allhandlers, 'parent', gcf, 'style', 'text');
%set(hh, 'BackgroundColor', get(gcf, 'color'), 'horizontalalignment', 'left');
set(hh, 'Backgroundcolor', GUIBACKCOLOR);
set(hh, 'foregroundcolor', GUITEXTCOLOR);
set(gcf, 'color', get(hh(1), 'BackgroundColor'));
set(hh, 'horizontalalignment', 'left');

hh = findobj(allhandlers, 'style', 'edit');
set(hh, 'BackgroundColor', [1 1 1]); %, 'horizontalalignment', 'right');

hh =findobj(allhandlers, 'parent', gcf, 'style', 'pushbutton');
set(hh, 'backgroundcolor', GUIPOPBUTTONCOLOR);
set(hh, 'foregroundcolor', GUITEXTCOLOR);
hh =findobj(allhandlers, 'parent', gcf, 'style', 'checkbox');
set(hh, 'backgroundcolor', GUIPOPBUTTONCOLOR);
set(hh, 'foregroundcolor', GUITEXTCOLOR);
hh =findobj(allhandlers, 'parent', gcf, 'style', 'listbox');
set(hh, 'backgroundcolor', GUIPOPBUTTONCOLOR);
set(hh, 'foregroundcolor', GUITEXTCOLOR);
hh =findobj(allhandlers, 'parent', gcf, 'style', 'radio');
set(hh, 'foregroundcolor', GUITEXTCOLOR);
set(hh, 'backgroundcolor', GUIPOPBUTTONCOLOR);

return;
