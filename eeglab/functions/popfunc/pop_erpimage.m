% pop_erpimage() - simple erpimage of EEG channels or an independent
%                  components with a pop-up window if only
%                  two (or three in specific condition) arguments.
%
% Usage:
%   >> pop_erpimage(EEG, typeplot); % pop_up window
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
%   channel    - channel or component to plot
%   title      - plot title
%   smooth     - smoothing parameter (in terms of trial). Default is 5.
%   decimate   - decimate parameter (i.e. number of lines to suppress
%                to speed display). Default is 0.
%   sortingtype  - Sorting event type(s) ([int vector]; []=all). See notes.
%                It is either a string or an integer.
%   sortingwin - Sorting event window [start, end] in seconds ([]=whole epoch)
%   sortingeventfield - Sorting field name. Default is none. 
%   renorm      - ['yes'|'no'|'a*x+b'] renormalize sorting variable.
%                Default is 'no'. Ex: '3*x+2'. 
%   options    - ERPIMAGE options. Default is none. Separate the options
%                using comma. Example 'erp', 'cbar'. See erpimage() help 
%                for further details. 
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
%   windows. 
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
            sortingwin, sortingeventfield, renorm, varargin)

varargout{1} = '';
if nargin < 1
   help pop_erpimage;
   return;
end;

if typeplot == 0 & isempty(EEG.icasphere)
   error('no ICA data for this set, first run ICA');
end;   
if EEG.trials == 1
   error('pop_erpimage can not be applied if there is only one trial');
end;   

if nargin < 2	
	typeplot = 1; %1=signal; 0=component
end;

if nargin < 3 | (nargin == 3 & isstr(channel))

	% decode last command
	% -------------------
	if nargin == 3 & isstr(channel)
		lastcom = channel;
		indstr = findstr( lastcom, 'pop_erpimage');
		if ~isempty( indstr )
			indstr = findstr( lastcom, ',');
			chan_default   = lastcom(indstr(2)+1:indstr(3)-1);
			title_default  = ''; %lastcom(indstr(3)+2:indstr(4)-2);
			smooth_default = lastcom(indstr(4)+1:indstr(5)-1);
			decim_default  = lastcom(indstr(5)+1:indstr(6)-1);
			sorttyp_default = lastcom(indstr(6)+2:indstr(7)-2);
			sortwin_default = lastcom(indstr(7)+2:indstr(8)-2);
			sortfld_default = lastcom(indstr(8)+2:indstr(9)-2);
			renorm_default  = lastcom(indstr(9)+2:indstr(10)-2);
			eloc_default    = 'no';
			options_default = lastcom(indstr(10)+1:end-2);
			if ~isempty(findstr(options_default, '''topo'', { '))
				indexoption = findstr(options_default, '''topo'', { ');
				indexendoption = findstr(options_default, ' } ');
				if indexendoption(1) < indexoption, indexendoption = indexendoption(2); end;
				options_default = [ options_default(1:indexoption-1) options_default(indexendoption+4:end)];
				eloc_default    = 'yes';
			else
				eloc_default    = 'no';
			end;	
		end;
	else
		chan_default = '1';
		title_default = '';
		smooth_default = int2str(min(max(EEG.trials-5,0), 10));
		decim_default = '1';
		sorttyp_default = '';
		sortwin_default = '';
		sortfld_default = '';
		renorm_default = 'no';
		title_default = '';
		eloc_default  = 'yes';
		options_default = ['''erp'', ''cbar'''];
	end;

	% which set to save
	% -----------------
    promptstr = { fastif( typeplot, 'Channel:', 'Component:') ...
      			'Epoch smoothing-window width (in epochs) (Ex: 10):' ...
      			'Epoch downsampling factor (1=none) (Ex: 2.5):' ...
                ['Epoch-sorting event field name (Ex: latency, []=no sorting):' ], ...
                ['Event type(s) subset ([]=all):' 10 ...
                '(See ''/Edit/Edit event values'' for event types)'], ...
                'Sorting event window [start, end] in seconds ([]=whole epoch):', ...
                ['Rescale sorting variable to plot window (yes|no|a*x+b)(Ex:3*x+2):'], ...
                'Plot title ([]=default,[space]=none):', ...
				 fastif(typeplot, 'Plot channel location', 'Plot component scalp map (yes|no):') ...
				'Other erpimage options (see >> help erpimage):' };
    inistr       = { ...
		chan_default, ...
		smooth_default, ...
		decim_default, ...
		sorttyp_default, ...
		sortwin_default, ...
		sortfld_default, ...
		renorm_default, ...
		title_default, ...
		eloc_default, ...
		options_default };
    
    help erpimage
    result       = inputdlg( promptstr, fastif( typeplot, 'Channel ERP image -- pop_erpimage()', ...
												'Component ERP image -- pop_erpimage()'), 1,  inistr);
	if size(result, 1) == 0 return; end;
	channel   	 = eval( result{1} );
	smooth       = eval( result{2} );
	decimate     = eval( result{3} );
	try, sortingeventfield = eval( result{4} ); catch, sortingeventfield = result{4}; end;
	sortingtype  = parsetxt(result{5});
	sortingwin   = eval( [ '[' result{6} ']' ] );
	renorm = result{7};
	titleplot    = result{8};
    if isempty(titleplot)
        titleplot = [ fastif( typeplot, 'Channel ', 'Component ') int2str(channel) ' ERP image'];
    end;
    if typeplot == 0
        switch lower(result{9})
            case 'yes', options = [',''topo'', { EEG.icawinv(:,' int2str(channel) ') EEG.chanlocs } '];
            otherwise, options = '';
        end;	
	else 
        switch lower(result{9})
            case 'yes', options = [',''topo'', { ' int2str(channel) ' EEG.chanlocs } '];
            otherwise, options = '';
        end;	
	end;
	if ~isempty(deblank(result{10}))
		options      = [ options ',' result{10} ];
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
	if nargin < 9
		renorm = 'no';
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

% find sorting latencies
% ---------------------
typetxt = '';
if ~isempty(sortingeventfield)
    events = eeg_getepochevent( EEG, sortingtype, sortingwin, sortingeventfield);

    % generate text for the command
    % -----------------------------
    for index = 1:length(sortingtype)
        if isstr(sortingtype{index})
            typetxt = [typetxt ' ''' sortingtype{index} '''' ];
        else
            typetxt = [typetxt ' ' num2str(sortingtype{index}) ];
        end;
    end;    
	% renormalize latencies if necessary
	% ----------------------------------
	switch lower(renorm)
	    case 'yes',
	         disp('Pop_erpimage warning: *** sorting variable renormalized ***');
	         events = (events-min(events)) / (max(events) - min(events)) * ...
	                        0.5 * (EEG.xmax*1000 - EEG.xmin*1000) + EEG.xmin*1000 + 0.4*(EEG.xmax*1000 - EEG.xmin*1000);
	    case 'no',;
	    otherwise,
	        locx = findstr('x', lower(renorm))
	        if length(locx) ~= 1, error('Pop_erpimage error: unrecognize renormalazing formula'); end;
	        eval( [ 'events =' renorm(1:locx-1) 'events' renorm(locx+1:end) ';'] );
	end;
else
    events = ones(1, EEG.trials)*EEG.xmax*1000;
    sortingeventfield = '';
end;           

if typeplot == 1
	tmpsig = EEG.data(channel, :);
else
    % test if ICA was computed or if one has to compute on line
    % ---------------------------------------------------------
    eeg_options; % changed from eeglaboptions 3/30/02 -sm
	if option_computeica  
    	tmpsig = EEG.icaact(channel, :);
	else
        tmpsig = EEG.icaweights(channel,:)*EEG.icasphere*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts);
    end;
end;

% outputs
% -------
outstr = '';
if nargin >= 4 | (nargin == 3 & isstr(channel))
    for io = 1:nargout, outstr = [outstr 'varargout{' int2str(io) '},' ]; end;
    if ~isempty(outstr), outstr = [ '[' outstr(1:end-1) '] =' ]; end;
end;

% plot the datas and generate output command
% --------------------------------------------
if length( options ) < 2
    options = '';
end;
    options
varargout{1} = sprintf('figure; pop_erpimage(%s,%d,%d,''%s'',%d,%d,{%s},[%s],''%s'',''%s''%s);', inputname(1), typeplot, channel, titleplot, smooth, decimate, typetxt, int2str(sortingwin), sortingeventfield, renorm, options);
com = sprintf('%s erpimage( tmpsig, events, [EEG.xmin*1000:1000*(EEG.xmax-EEG.xmin)/(EEG.pnts-1):EEG.xmax*1000], titleplot, smooth, decimate %s);', outstr, options);
eval(com)

return;
