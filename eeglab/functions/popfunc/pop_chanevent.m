% pop_chanevent() - import BCI2000 ascii file into eeglab
%
% Usage:
%   >> OUTEEG = pop_chanevent( INEEG ); % pop_up
%   >> OUTEEG = pop_chanevent( INEEG, chanindexes, 'key', 'val' ... );
%
% Inputs:
%   INEEG          - input dataset structure
%   chanindexes    - index of an event channel
%
% Optionnal inputs:
%   'edge'         - ['leading'|'trailing'|'both'] extract events when values
%                    if the event channel go up ('leading'), down ('trailing')
%                    or both ('both'). Default is 'both'.
%   'delchan'      - ['on'|'off'] delete channel from data { 'on' }.
%   'delevent'     - ['on'|'off'] delete old events if any { 'on' }.
%   'nbtype'       - [1|NaN] setting this to one will force the program to 
%                    consider all events as having the same type. Default is NaN.
%   'typename'     - [string] name of the type for the events. Only relevant
%                    'nbtype' is 1 or if there is only one event type in the
%                     event channel. Default is 'chanX', X being the index of
%                     the selected event channel.
%
% Outputs:
%   OUTEEG         - EEGLAB output data structure
%
% Author: Arnaud Delorme, CNL / Salk Institute, 29 July 2002
%
% See also: eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
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
% Revision 1.8  2002/12/06 02:32:25  arno
% adding type name
%
% Revision 1.7  2002/10/09 22:28:47  arno
% update text
%
% Revision 1.6  2002/10/09 22:25:31  arno
% debugging
%
% Revision 1.5  2002/10/02 23:02:09  arno
% debug delevent and 'both' options
%
% Revision 1.4  2002/08/22 21:13:36  arno
% debug
%
% Revision 1.3  2002/08/06 21:39:11  arno
% spelling
%
% Revision 1.2  2002/07/29 17:57:12  arno
% debugging
%
% Revision 1.1  2002/07/29 17:53:03  arno
% Initial revision
%

function [EEG, command] = pop_chanevent(EEG, chans, varargin); 
command = '';

if nargin < 1
    help pop_chanevent;
    return;
end;

if nargin < 2
	geometry = { [1.465 2.05] [1.5 1 1] [1.5 0.21 1] [1.5 0.21 1] [1.5 0.21 1] };
	strgui = { { 'style' 'text' 'string' 'Event channel(s)' 'tooltipstring' 'indexes of event channels' } ...
			   { 'style' 'edit' 'string' '' } ...
			   { 'style' 'text' 'string' 'Edge type to extract' 'tooltipstring' ...
				 [ 'extract events when values if the event channel go up' 10 ...
				   '(''leading''), down (''trailing'') or both (''both'').' 10 ...
				   'AFTER SCROLLING, CLICK TO SELECT ON UNIX' ] } ...
			   { 'style' 'listbox' 'string' 'both|leading|trailing' 'value' 1 } { 'style' 'text' 'string' '(click to select)'} ...
			   { 'style' 'text' 'string' 'Delete event channel(s)  (=set)' } ...
			   { 'style' 'checkbox' 'value' 1 } { } ...
			   { 'style' 'text' 'string' 'Delete old events if any (=set)' } ...
			   { 'style' 'checkbox' 'value' 1 } { } ...
			   { 'style' 'text' 'string' 'Only one event type (=set)' 'tooltipstring' ...
			    ['If set, all transitions are considered the same,' 10 ...
				 'if unset, each signal value is assigned a different type'] } ...
			   { 'style' 'checkbox' 'value' 0 } { } };
	result       = inputgui( geometry, strgui, 'pophelp(''pop_chanevent'');', 'Extract event from channel(s) - pop_chanevent()');
	
	if length(result) == 0 return; end;
	chans   = eval( [ '[' result{1} ']' ] );
	switch result{2},
		case 1, g.edge = 'both';
		case 2, g.edge = 'leading';
		case 3, g.edge = 'trailing';
	end;
	if result{3}, g.delchan = 'on'; else g.delchan  = 'off'; end;
	if result{4}, g.delevent= 'on'; else g.delevent = 'off'; end;
	if result{5}, g.nbtype  = 1;     else g.nbtype   = NaN; end;
    g.typename =  [ 'chan' int2str(chans) ];
else 
	listcheck = { 'edge'     'string'     { 'both' 'leading' 'trailing'}     'both';
				  'delchan'  'string'     { 'on' 'off' }                     'on';
				  'delevent' 'string'     { 'on' 'off' }                     'on';
                  'typename' 'string'     []                                 [ 'chan' int2str(chans) ];
				  'nbtype'   'integer'    [1 NaN]                             NaN };
	g = finputcheck( varargin, listcheck, 'pop_chanedit');
	if isstr(g), error(g); end;
end;
if length(chans) ~= 1
	error('One (single) channel must be selected');
end;

% process events
% --------------
fprintf('pop_chanevent: importing events from data channel %d ...\n', chans);
counte = 1; % event counter
events(10000).latency = 0;
if length(unique(EEG.data(index, :))) == 2, g.nbtype = 1; end;

counttrial = 1;
switch g.edge
 case 'both'    , tmpevent = find( diff(EEG.data(index, :)) ~= 0);
 case 'trailing', tmpevent = find( diff(EEG.data(index, :)) < 0);
 case 'leading' , tmpevent = find( diff(EEG.data(index, :)) > 0);
end;
tmpevent = tmpevent+1;
for tmpi = tmpevent
    if ~isnan(g.nbtype)
        events(counte).type    = g.typename;
    else
        events(counte).type    = EEG.data(index, tmpi);
    end;
    events(counte).latency = tmpi;
    counte = counte+1;
end;
events = events(1:counte-1);

% resort events
% --------------
if strcmp(g.delevent, 'on')
	EEG.event = events;
else
	for index = 1:length(events)
		EEG.event(end+1).type  = events(index).type;
		EEG.event(end).latency = events(index).latency;
	end;
	EEG = pop_editeventvals( EEG, 'sort', { 'latency', [0] } );
	EEG = eeg_checkset(EEG, 'eventconsistency');
end;

% delete channels
% ---------------
if strcmp(g.delchan, 'on')
	EEG = pop_select(EEG, 'nochannel', chans);
end;

command = sprintf('%s = pop_chanevent(%s, %s);', inputname(1), inputname(1), ...
				  vararg2str({ chans 'edge', g.edge 'nbtype' g.nbtype 'delchan' g.delchan 'delevent' g.delevent})); 
return;
