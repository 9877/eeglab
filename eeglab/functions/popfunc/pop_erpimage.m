% pop_erpimage() - plot an erpimage of a given EEG channel or independent
%                  component. Uses a pop-up window if only two (or three 
%                  in a specific condition) input arguments.
%
% Usage:
%   >> pop_erpimage(EEG, typeplot);          % pop_up window
%   >> pop_erpimage(EEG, typeplot, lastcom); % pop_up window
%   >> pop_erpimage(EEG, typeplot, channel); % do not pop-up
%   >> pop_erpimage(EEG, typeplot, channel, title, smooth, decimate, ...
%                 sortingtype, sortingwin, sortingeventfield, renorm, ...
%                 options...);
%
% Inputs:
%   EEG        - dataset structure
%   typeplot   - 1=channel, 0=component 
%   lastcom    - string containing last command (from LASTCOM) or from
%                the function output.
%
% Commandline options:
%   channel    - channel or component number to plot
%   title      - plot title
%   smooth     - smoothing parameter (in terms of trial). Default is 5.
%   decimate   - decimate parameter (i.e. number of lines to suppress
%                to speed display). Default is 0.
%   sortingtype  - Sorting event type(s) ([int vector]; []=all). See notes.
%                It is either a string or an integer.
%   sortingwin - Sorting event window [start, end] in seconds ([]=whole epoch)
%   sortingeventfield - Sorting field name. Default is none. 
%   options    - erpimage() options. Default is none. Separate the options
%                by commas. Example 'erp', 'cbar'. See erpimage() help 
%                and >> erpimage moreargs for further details. 
%
% Outputs from pop-up: 
%   string containing the command used to evaluate this plotting function
%   (saved by eeglab() as LASTCOM) put it into 'lastcom' for restoring
%   last input parameters as defaults in the pop-up window
%
% Outputs from command line:
%   same as erpimage(), no outputs are returned when a
%   window pops-up to ask for additional arguments
%   
% Notes:
%   1) A new figure is created only when the pop_up window is called, 
%   so you may call this command to draw topographic maps in a tiled 
%   window. 
%   2) To sort epochs, first define the event field to be used with
%   the argument 'sortingeventfield' (for instance 'latency'). Then 
%   because they may be several event with different latencies in a
%   given epoch, it is possible to consider only a subsets of events
%   using the 'sortingtype' argument and the 'sortingwin' argument. The 
%   'sortingtype' argument selects events with definite types. The 
%   'sortingwin' argument helps to define a specific time window in the 
%   epoch to select events. For instance the epoch time range may be -1 
%   to 2 seconds but one may want to select events only in the range 0 
%   to 1 second. (these three parameters are forwarded to the function
%   eeg_getepochevent() which contains more details).
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: eeglab(), erpimage(), eeg_getepochevent()

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
% Revision 1.47  2002/08/17 03:06:27  arno
% same
%
% Revision 1.46  2002/08/17 02:49:56  arno
% listdlg2
%
% Revision 1.45  2002/08/13 23:12:31  scott
% add erpaimge() to figure number
%
% Revision 1.44  2002/08/12 23:34:36  arno
% reordering fields
%
% Revision 1.43  2002/08/12 18:50:47  arno
% errordlg2
%
% Revision 1.42  2002/08/12 01:35:59  arno
% allamp debug
%
% Revision 1.41  2002/08/12 01:35:36  arno
% color
%
% Revision 1.40  2002/08/11 22:12:40  arno
% color
%
% Revision 1.39  2002/08/09 16:45:47  arno
% updating plotamp and phasesort
%
% Revision 1.38  2002/07/29 23:42:47  arno
% same
%
% Revision 1.37  2002/07/29 23:41:26  arno
% updating getdef
%
% Revision 1.36  2002/07/29 00:20:00  arno
% debugging
%
% Revision 1.35  2002/07/27 01:21:56  arno
% debugging last command
%
% Revision 1.34  2002/07/27 00:45:17  arno
% adding messages, changing output command
%
% Revision 1.33  2002/07/24 19:29:10  arno
% removing renorm
%
% Revision 1.32  2002/07/24 19:27:16  arno
% adding back renorm into text output
%
% Revision 1.31  2002/07/24 19:23:56  arno
% ebugging output message
%
% Revision 1.30  2002/07/24 19:22:05  arno
% end debugging
%
% Revision 1.29  2002/07/24 19:20:58  arno
% same
%
% Revision 1.28  2002/07/24 19:19:34  arno
% debugging
%
% Revision 1.27  2002/07/23 21:32:58  arno
% debugging not same size
%
% Revision 1.26  2002/05/01 23:43:05  arno
% additional test
%
% Revision 1.25  2002/04/29 20:22:22  arno
% typo
%
% Revision 1.24  2002/04/26 21:41:27  arno
% phase/coher consistency chack
%
% Revision 1.23  2002/04/25 18:18:24  arno
% debugging spec
%
% Revision 1.22  2002/04/25 18:13:11  arno
% updating command output
%
% Revision 1.21  2002/04/25 17:55:05  arno
% improving commandline message
% ,
%
% Revision 1.20  2002/04/25 17:52:03  arno
% modifying renorm
%
% Revision 1.19  2002/04/25 16:05:57  scott
% adding blank line above history entry -sm
%
% Revision 1.18  2002/04/25 16:03:12  scott
% trying to output com into history as well as popcom -sm
%
% Revision 1.17  2002/04/24 20:36:22  arno
% implementing buttons
%
% Revision 1.16  2002/04/24 19:50:28  arno
% updating parameters
%
% Revision 1.15  2002/04/24 15:22:28  scott
% [same] -sm
%
% Revision 1.14  2002/04/24 15:21:48  scott
% [same] -sm
%
% Revision 1.13  2002/04/24 15:20:47  scott
% [same] -sm
%
% Revision 1.12  2002/04/24 15:19:53  scott
% adding note re plotamps -sm
%
% Revision 1.11  2002/04/23 21:51:01  arno
% fixed vert
%
% Revision 1.10  2002/04/23 21:24:33  scott
% *** empty log message ***
%
% Revision 1.9  2002/04/23 21:20:15  scott
% edited help msg -sm
%
% Revision 1.8  2002/04/23 17:19:45  arno
% contextual help modif
%
% Revision 1.7  2002/04/23 02:01:32  arno
% New graphic interface
%
% Revision 1.6  2002/04/18 19:11:09  arno
% testing version control
%
% Revision 1.5  2002/04/18 15:56:33  scott
% editted msgs -sm
%
% Revision 1.4  2002/04/11 20:02:42  arno
% adding last command history
%
% Revision 1.3  2002/04/11 19:06:43  arno
% adding option to default parameters
%
% Revision 1.2  2002/04/05 23:05:50  arno
% Correct typo
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 01-25-02 reformated help & license -ad 
% 02-12-02 added new event format compatibility -ad 
% 02-15-02 text interface editing -sm & ad 
% 03-07-02 add the eeglab computeica options -ad
% 02-15-02 modified the function accoring to the new event/epoch structure -ad
% 03-18-02 added title -ad & sm
% 04-04-02 added outputs -ad & sm

function varargout = pop_erpimage( EEG, typeplot, channel, titleplot, smooth, decimate, sortingtype, ...
            sortingwin, sortingeventfield, varargin)
 
varargout{1} = '';
if nargin < 1
   help pop_erpimage;
   return;
end;

if typeplot == 0 & isempty(EEG.icasphere)
   error('no ICA data for this set, first run ICA');
end;   
if EEG.trials == 1
   error('erpimage of one trial cannot be plotted');
end;   

if nargin < 2	
	typeplot = 1; %1=signal; 0=component
end;
	lastcom = [];
if nargin < 3
	popup = 1;
else
	popup = isstr(channel) | isempty(channel);
	if isstr(channel)
		lastcom = channel;
	end;
end;

if popup
	% get contextual help
	% -------------------
	[txt2 vars2] = gethelpvar('erpimage.m');
	[txt vars] = gethelpvar('erpimopt.m');
	txt  = { txt{:} txt2{:}};
	vars = { vars{:} vars2{:}};
	commandphase = [ 'if ~isempty(get(findobj(''parent'', gcbf, ''tag'', ''phase''),''string'')),' ...
					 '   if ~isempty(get(findobj(''parent'', gcbf, ''tag'', ''coher''),''string'')), ' ...
					 '      set(findobj(''parent'', gcbf, ''tag'', ''coher''), ''string'', get(findobj(''parent'', gcbf, ''tag'', ''phase''),''string''));' ...
					 'end; end;' ];
	commandcoher = [ 'if ~isempty(get(findobj(''parent'', gcbf, ''tag'', ''coher''),''string'')),' ...
					 '   if ~isempty(get(findobj(''parent'', gcbf, ''tag'', ''phase''),''string'')), ' ...
					 '      set(findobj(''parent'', gcbf, ''tag'', ''phase''), ''string'', get(findobj(''parent'', gcbf, ''tag'', ''coher''),''string''));' ...
					 'end; end;' ];
	
	commandfield = ['if isempty(EEG.event)' ...
				   '   errordlg2(''No events'');' ...
				   'else' ...
				   '   tmpfieldnames = fieldnames(EEG.event);' ...
				   '   [tmps,tmpv] = listdlg2(''PromptString'', ''Select fields'', ''SelectionMode'',''single'',''ListString'', tmpfieldnames);' ...
				   '   if tmpv' ...
				   '       set(findobj(''parent'', gcbf, ''tag'', ''field''), ''string'', tmpfieldnames{tmps});' ...
				   '   end;' ...
				   'end;' ...
				   'clear tmps tmpv tmpfieldnames;' ];
	commandtype = ['if ~isfield(EEG.event, ''type'')' ...
				   '   errordlg2(''No type field'');' ...
				   'else' ...
				   '   if isstr(EEG.event(1).type)' ...
				   '       tmpfieldnames = unique({EEG.event.type});' ...
				   '   else' ...
				   '       tmpfieldnames = num2str(unique(cell2mat({EEG.event.type}))'');' ...
				   '   end;' ...
		           '   [tmps,tmpv, tmpstr] = listdlg2(''PromptString'',''Select fields'', ''ListString'', tmpfieldnames);' ...
				   '   if tmpv' ...
				   '       set(findobj(''parent'', gcbf, ''tag'', ''type''), ''string'', tmpstr);' ...
				   '   end;' ...
				   'end;' ...
				   'clear tmps tmpv tmpstr tmpfieldnames;' ];
	
	geometry = { [1 1 0.1 0.8 2.1] [1 1 1 1 1] [1 1 1 1 1] [1 1 1 1 1] [1] [1] [1 1 1 0.8 0.8 1.2] [1 1 1 0.8 0.8 1.2] [1] [1] ...
				 [1.1 1.4 1.2 1 .5] [1.1 1.4 1.2 1 .5] [1] [1] [1 1 1 1 1] [1 1 1 1 1] [1] [1] [1 1 1 2.2] [1 1 1 2.2]};
    uilist = { { 'Style', 'text', 'string', fastif(typeplot, 'Channel', 'Component'), 'fontweight', 'bold'  } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom,3,[],'1') } { } ...
			   { 'Style', 'text', 'string', 'Figure title', 'fontweight', 'bold'  } ...
			   { 'Style', 'edit', 'string', ''  } ...
			   ...
			   { 'Style', 'text', 'string', 'Smoothing', 'fontweight', 'bold', 'tooltipstring', context('avewidth',vars,txt) } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 5, [], int2str(min(max(EEG.trials-5,0), 10))) } ...
			   { 'Style', 'checkbox', 'string', 'Plot scalp map', 'tooltipstring', 'plot a 2-d head map (vector) at upper left', ...
				 'value', getkeyval(lastcom, 'topo', 'present', 1)  } { } { } ...
			   { 'Style', 'text', 'string', 'Downsampling', 'fontweight', 'bold', 'tooltipstring', context('decimate',vars,txt) } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 6, [], '1') } ...
			   { 'Style', 'checkbox', 'string', 'Plot ERP', 'tooltipstring', context('erp',vars,txt), 'value', getkeyval(lastcom, '''erp''', 'present', 1) } ...
			   { 'Style', 'text', 'string', 'ERP limits (uV)'  } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'limits', [3:4])  } ...
			   { 'Style', 'text', 'string', 'Time limits (ms)', 'fontweight', 'bold', 'tooltipstring',  'Select time subset in ms' } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'limits', [1:2], num2str(1000*[EEG.xmin EEG.xmax])) } ...
			   { 'Style', 'checkbox', 'string', 'Plot colorbar','tooltipstring', context('caxis',vars,txt), 'value', getkeyval(lastcom, 'cbar', 'present', 1)  } ...
			   { 'Style', 'text', 'string', 'Color limits','tooltipstring', context('caxis',vars,txt)  } ...
			   { 'Style', 'edit', 'string',  getkeyval(lastcom, 'caxis') } ...
			   {} ...
			   { 'Style', 'text', 'string', 'Sort/align trials by epoch event values', 'fontweight', 'bold'} ...
			   { 'Style', 'pushbutton', 'string', 'Sorting field', 'callback', commandfield, ...
				 'tooltipstring', 'Epoch-sorting event field name (Ex: latency, []=no sorting):' } ...
			   { 'Style', 'pushbutton', 'string', 'Event type(s)', 'callback', commandtype, 'tooltipstring', ['Event type(s) subset ([]=all):' 10 ...
                '(See ''/Edit/Edit event values'' for event types)']  } ...
			   { 'Style', 'text', 'string', 'Time window', 'tooltipstring', [ 'Sorting event window [start, end] in milliseconds ([]=whole epoch):' 10 ...
												  'events are only selected within this time window (can be usefull if several' 10 ...
												  'events of the same type are in the same epoch, or for selecting trials with given response time)']} ...
			   { 'Style', 'text', 'string', 'Rescale', 'tooltipstring', 'Rescale sorting variable to plot window (yes|no|a*x+b)(Ex:3*x+2):' } ...
			   { 'Style', 'text', 'string', 'Align', 'tooltipstring',  context('align',vars,txt) } ...
			   { 'Style', 'checkbox', 'string', 'Don''t sort var.', 'tooltipstring', context('nosort',vars,txt), 'value', getkeyval(lastcom, 'nosort', 'present', 0)  } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 9), 'tag', 'field' } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 7), 'tag', 'type' } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 8) } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'renorm',[], 'no') } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'align') } ...
			   { 'Style', 'checkbox', 'string', 'Don''t plot var.', 'tooltipstring', context('noplot',vars,txt), 'value', getkeyval(lastcom, 'noplot', 'present', 0) } ...
			   {} ...
			   { 'Style', 'text', 'string', 'Sort trials by phase', 'fontweight', 'bold'} ...
			   { 'Style', 'text', 'string', 'Freq. range (Hz)', 'tooltipstring', ['sort by phase at max power frequency' 10 ...
               'in the data within the range [minfrq,maxfrq]' 10 '(overrides frequency specified in ''coher'' flag)']  } ...
			   { 'Style', 'text', 'string', '% trials to ignore', 'tooltipstring', ['percent of trials to reject for low' ...
			    'amplitude. Else,' 10 'if prct is in the range [-100,0] -> percent to reject for high amplitude'] } ...
			   { 'Style', 'text', 'string', 'Center time (ms)', 'tooltipstring', 'Ending time fo the 3 cycle window'  } ...
			   { 'Style', 'text', 'string', 'Window cycles', 'tooltipstring', '3 cycles wavelet window'  } {}...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'phasesort', [3:4]), 'tag', 'phase', 'callback', commandphase } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'phasesort', [2]) } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'phasesort', [1]) } ...
			   { 'Style', 'text', 'string', '         3'  } {}...
			   {} ...
			   { 'Style', 'text', 'string', 'Inter-trial coherence options', 'fontweight', 'bold'} ...
			   { 'Style', 'text', 'string', 'Coher freq.', 'tooltipstring', [ '[freq] -> plot erp plus amp & coher at freq (Hz)' 10 ...
               '[minfreq maxfreq] -> find max in frequency range' 10 '(or at phase freq above, if specified)']} ...
			   { 'Style', 'text', 'string', 'Signif. level', 'tooltipstring', 'add coher. signif. level line at alpha (alpha range: (0,0.1])' } ...
			   { 'Style', 'text', 'string', 'Power limits (dB)'  } ...
			   { 'Style', 'text', 'string', 'Coher limits (<=1)'  } ...
			   { 'Style', 'checkbox', 'string', 'Image amps', 'tooltipstring',  context('plotamp',vars,txt), 'value', getkeyval(lastcom, 'plotamps', 'present', 0) } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'coher', [1:2]), 'tag', 'coher', 'callback', commandcoher } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'coher', [3])  } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'limits',[5:6])  } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'limits',[7:8])  } {'style', 'text', 'string', '   (Requires signif.)' } ... 
			   {} ...
			   { 'Style', 'text', 'string', 'Other options', 'fontweight', 'bold'} ...
			   { 'Style', 'text', 'string', 'Plot spectrum','tooltipstring',  context('spec',vars,txt)} ...
			   { 'Style', 'text', 'string', 'Baseline amp.', 'tooltipstring', 'Use it to fix baseline amplitude' } ...
			   { 'Style', 'text', 'string', 'Mark times (ms)','tooltipstring',  context('vert',vars,txt)} ...
			   { 'Style', 'text', 'string', 'Other options (see help)' } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'spec') } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'limits',9) } ...
			   { 'Style', 'edit', 'string', getkeyval(lastcom, 'vert') } ...
			   { 'Style', 'edit', 'string', '' } ...
			};
		
    result = inputgui( geometry, uilist, 'pophelp(''pop_erpimage'');', ...
							 fastif( typeplot, 'Channel ERP image -- pop_erpimage()', 'Component ERP image -- pop_erpimage()'));
	if size(result, 1) == 0 return; end;

	% first rows
	% ---------
	limits(1:8)  = NaN;
	channel   	 = eval( result{1} );
	titleplot    = result{2};
	options = '';
    if isempty(titleplot)
        titleplot = [ fastif( typeplot, 'Channel ', 'Component ') int2str(channel) ' ERP image'];
    end;
	smooth       = eval( result{3} );
    if result{4}
		if ~isempty(EEG.chanlocs)
			if typeplot == 0, options = [options ',''topo'', { EEG.icawinv(:,' int2str(channel) ') EEG.chanlocs } '];
			else              options = [options ',''topo'', { ' int2str(channel) ' EEG.chanlocs } '];
			end;	
		end;
	end;
	
	decimate     = eval( result{5} );
	if result{6}
		options = [options ',''erp'''];
	end;
	if ~isempty(result{7})
		limits(3:4) = eval( [ '[' result{5} ']' ]); 
	end;
	if ~isempty(result{8}) % time limits
		if ~strcmp(result{8}, num2str(1000*[EEG.xmin EEG.xmax]))
			limits(1:2) = eval( [ '[' result{8} ']' ]);
		end;
	end;
	if result{9}
		options = [options ',''cbar'''];
	end;
	if ~isempty(result{10})
		options = [options ',''caxis'', ' result{8} ];
	end;
	
	% event rows
	% ----------
	if result{11}
		options = [options ',''nosort'''];
	end;
	try, sortingeventfield = eval( result{12} ); catch, sortingeventfield = result{12}; end;
	sortingtype  = parsetxt(result{13});
	sortingwin   = eval( [ '[' result{14} ']' ] );
	if ~isempty(result{13}) & ~strcmp(result{15}, 'no')
		options = [options ',''renorm'', ''' result{15} '''' ];
	end;
	if ~isempty(result{16})
		options = [options ',''align'', ' result{16} ];
	end;
	if result{17}
		options = [options ',''noplot'''];
	end;

	% phase rows
	% ----------
	tmpphase = [];
	if ~isempty(result{18})
		tmpphase = eval( [ '[ 0 0 ' result{18} ']' ]);
	end;
	if ~isempty(result{19})
		tmpphase(2) = eval( result{19} );
	end;
	if ~isempty(result{20})
		tmpphase(1) = eval( result{20} );
	end;
	if ~isempty(tmpphase)
		options = [ options ',''phasesort'',[' num2str(tmpphase) ']' ];
	end;
	
	% coher row
	% ----------
	tmpcoher = [];
	if result{21}
		options = [options ',''plotamps'''];
	end;
	if ~isempty(result{22})
		tmpcoher = eval( [ '[' result{22} ']' ]);
	end;
	if ~isempty(result{23})
		if length(tmpcoher) == 1
			tmpcoher(2) = tmpcoher(1);
		end;
		tmpcoher(3) = eval( result{23} );
	end;
	if ~isempty(tmpcoher)
		options = [ options ',''coher'',[' num2str(tmpcoher) ']' ];
	end;
	if ~isempty(result{24})
		limits(5:6) = eval( [ '[' result{24} ']' ]);
	end;
	if ~isempty(result{25})
		limits(7:8) = eval( [ '[' result{25} ']' ]);
	end;

	% options row
	% ------------
	if ~isempty(result{26})
		options = [options ',''spec'', [' result{26} ']' ];
	end;
	if ~isempty(result{27})
		limits(9) = eval( result{27} ); %bamp
	end;
	if ~isempty(result{28})
		options = [options ',''vert'', [' result{28} ']' ];
	end;
	if ~all(isnan(limits))
		options = [ options ',''limits'',[' num2str(limits) ']' ];
	end;
	if ~isempty(result{29})
		options = [ options ',' result{29} ];
	end;
	figure;
else
	options = '';
	if nargin < 4
		smooth = 5;
	end;
	if nargin < 5
		decimate = 0;
	end;
	if nargin < 6
		sortingtype = [];
	end;
	if nargin < 7
		sortingwin = [];
	end;
	if nargin < 8
		sortingeventfield = [];
	end;
	for i=1:length( varargin )
		if isstr( varargin{ i } )
			options = [ options ', ''' varargin{i} '''' ];
		else  
		  if ~iscell( varargin{ i } )
		      options = [ options ', [' num2str(varargin{i}) ']' ];
		  else
		      options = [ options ', { [' num2str(varargin{ i }{1}') ']'' EEG.chanlocs }' ];
		  end;    
		end;
	end;	
end;
try, icadefs; set(gcf, 'color', BACKCOLOR,'Name',' erpimage()'); catch, end;

% find sorting latencies
% ---------------------
typetxt = '';
if ~isempty(sortingeventfield)
    %events = eeg_getepochevent( EEG, sortingtype, sortingwin, sortingeventfield);
	events = sprintf('eeg_getepochevent( EEG, %s)', vararg2str({sortingtype, sortingwin, sortingeventfield}));
	
    % generate text for the command
    % -----------------------------
    for index = 1:length(sortingtype)
        if isstr(sortingtype{index})
            typetxt = [typetxt ' ''' sortingtype{index} '''' ];
        else
            typetxt = [typetxt ' ' num2str(sortingtype{index}) ];
        end;
    end;    
% $$$ 	% renormalize latencies if necessary
% $$$ 	% ----------------------------------
% $$$ 	switch lower(renorm)
% $$$ 	    case 'yes',
% $$$ 	         disp('Pop_erpimage warning: *** sorting variable renormalized ***');
% $$$ 	         events = (events-min(events)) / (max(events) - min(events)) * ...
% $$$ 	                        0.5 * (EEG.xmax*1000 - EEG.xmin*1000) + EEG.xmin*1000 + 0.4*(EEG.xmax*1000 - EEG.xmin*1000);
% $$$ 	    case 'no',;
% $$$ 	    otherwise,
% $$$ 	        locx = findstr('x', lower(renorm))
% $$$ 	        if length(locx) ~= 1, error('Pop_erpimage error: unrecognize renormalazing formula'); end;
% $$$ 	        eval( [ 'events =' renorm(1:locx-1) 'events' renorm(locx+1:end) ';'] );
% $$$ 	end;
else
	events = 'ones(1, EEG.trials)*EEG.xmax*1000';
    %events = ones(1, EEG.trials)*EEG.xmax*1000;
    sortingeventfield = '';
end;           

if typeplot == 1
	tmpsig = ['EEG.data(' int2str(channel) ', :)'];
else
    % test if ICA was computed or if one has to compute on line
    % ---------------------------------------------------------
    eeg_options; % changed from eeglaboptions 3/30/02 -sm
	if option_computeica  
		tmpsig = ['EEG.icaact(' int2str(channel) ', :)'];
	else
		tmpsig = ['EEG.icaact(' int2str(channel) ', :)'];
        tmpsig = ['EEG.icaweights(' int2str(channel) ',:)*EEG.icasphere*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts)'];
    end;
end;

% outputs
% -------
outstr = '';
if ~popup
    for io = 1:nargout, outstr = [outstr 'varargout{' int2str(io) '},' ]; end;
    if ~isempty(outstr), outstr = [ '[' outstr(1:end-1) '] =' ]; end;
end;

% plot the datas and generate output command
% --------------------------------------------
if length( options ) < 2
    options = '';
end;

% varargout{1} = sprintf('figure; pop_erpimage(%s,%d,%d,''%s'',%d,%d,{%s},[%s],''%s'',''%s''%s);', inputname(1), typeplot, channel, titleplot, smooth, decimate, typetxt, int2str(sortingwin), sortingeventfield, renorm, options);
popcom = sprintf('figure; pop_erpimage(%s,%d,%d,''%s'',%d,%d,{%s},[%s],''%s'' %s);', inputname(1), typeplot, channel, titleplot, smooth, decimate, typetxt, int2str(sortingwin), sortingeventfield, options);

com = sprintf('%s erpimage( %s, %s, linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts), ''%s'', %d, %d %s);', outstr, tmpsig, events, titleplot, smooth, decimate, options);
disp('Command executed by pop_erpimage:');
disp(' '); disp(com); disp(' ');
eval(com)

if popup
	varargout{1} = popcom; % [10 '% Call: ' com];
end;

return;

% get contextual help
% -------------------
function txt = context(var, allvars, alltext);
	loc = strmatch( var, allvars);
	if ~isempty(loc)
		txt= alltext{loc(1)};
	else
		disp([ 'warning: variable ''' var ''' not found']);
		txt = '';
	end;

