% pop_importdata() - import data from a Matlab variable or disk file by calling
%                    importdata().
% Usage:
%   >> EEGOUT = pop_importdata( EEG ); % pop-up a data entry window 
%   >> EEGOUT = pop_importdata( 'key', val,...); % no pop-up window
%
% Graphic interface (refer to a previous version of the GUI):
%   "Data file/array" - [Edit box] Data file or Matlab variable name to import
%                  to EEGLAB. Command line equivalent: 'data'
%   "Data file/array" - [list box] select data format from listbox. If you
%                  browse for a data file, the graphical interface might be
%                  able to detect the file format from the file extension and
%                  his list box accordingly. Note that you have to click on
%                  the option to make it active. Command line equivalent:
%                  'dataformat'
%   "Dataset name" - [Edit box] name for the new (EEGLAB) dataset. 
%                  Command line equivalent: 'setname'
%   "Time points per epoch" - [Edit box] Number of points per data epoch.
%                  Irrelevant for continuous data. Command line equivalent: 'pnts'


%   "Start time"   - [Edit box]

%   "Number of channels" - [Edit box] Number of data channels. 
%                  Command line equivalent: 'nbchan'
%   "Ref. channel indices or mode - [Edit box]




%   "Data sampling rate" - [Edit box] Command line equivalent: 'srate'
%   "Optional epoch start time" - [Edit box] Command line equivalent: 'xmin'
%   "Channel locations file or array" - [Edit box] see readlocs() help for
%                  data channel format. Command line equivalent: 'chanlocs'
%   "ICA weights array or text/binary file" - [edit box] Use this option to import
%                  ICA weights from other decompositions (for instance: same
%                  data, different conditions). To use the ICA weights from
%                  another loaded dataset (n) enter 'ALLEEG(n).icaweights'
%                  in this edit box. Command line equivalent: 'icaweights'
%   "ICA sphere array or text/binary file" - [edit box] Import an ICA sphering matrix. 
%                  For computational reasons, an ICA decomposition may be defined 
%                  by a sphere matrix and an unmixing (weight) matrix (above).
%                  To use the ICA weights from another loaded dataset (n)
%                  enter "ALLEEG(n).icasphere". If no sphering matrix, enter 
%                  'eye(EEG.nbchan)'. Command line equivalent: 'icasphere'.




%   "Subject code" - [Edit box]

%   "Task Condition" - [Edit box]

%   "Session number" - [Edit box]

%   "Subject group" - [Edit box]

%   "About this dataset" - [Edit box]




% Optional inputs:
%   'setname'    - ['string'] Name of the new EEGLAB dataset
%   'data'       - ['varname'|'filename'] Data variable or file name to import.
%   'dataformat' - ['array|matlab|ascii|float32le|float32be'] Input data format.
%                  'array' is a Matlab array in the global workspace.
%                  'matlab' is a Matlab file (which must contain a single variable).
%                  'ascii' is an ascii file. 'float32le' and 'float32be' are 32-bits
%                  float data files (little endian or big endian byte ordering).
%                  Data must be organised as (channels, timepoints) i.e. 
%                  channels = rows and timepoints = columns or (channels, timepoints, 
%                  epochs). For convenience, the data file is transposed if the number
%                  of rows is larger than the number of columns.
%   'chanlocs'   - ['varname'|'filename'] Import a file containing electrode 
%                  locations (see >> help readlocs for file format).
%   'nbchan'     - Number of data channels. 
%   'xmin'       - Starting time in seconds.
%   'session'    - Session (day) on which the data was recorded. Just enter an
%                  integer here (1, 2, 3, ...) not the actual date.
%   'condition'  - Basic condition for the data.
%   'group'      - Basic subject group for the data.
%   'pnts'       - Number of data frames (time points) per data epoch (epoched data only).
%   'srate'      - Data sampling rate in Hz.
%   'icaweights' - ICA weight matrix. 
%   'icasphere'  - ICA sphering matrix (if [], eye(nchans)).
% 
% Outputs:
%   EEGOUT      - modified EEG dataset structure
%
% Note: This function calls pop_editset() to modify parameter values.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: pop_editset(), pop_select(), eeglab()

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
% Revision 1.26  2005/11/04 22:44:50  arno
% header
%
% Revision 1.25  2005/11/04 22:42:00  arno
% new fields etc...
%
% Revision 1.24  2004/03/26 23:21:57  arno
% window width
%
% Revision 1.23  2004/03/02 16:36:53  arno
% gui text
%
% Revision 1.22  2003/05/29 21:46:38  arno
% simply forwarding data if command line call
%
% Revision 1.21  2003/04/29 15:00:47  arno
% results -> result
%
% Revision 1.20  2003/04/21 00:43:56  arno
% warning for epoch start time > 10
%
% Revision 1.19  2003/03/04 20:24:13  arno
% header typo
%
% Revision 1.18  2003/02/25 00:52:56  scott
% header edit -sm
%
% Revision 1.17  2003/02/24 16:26:39  arno
% resolving ???
%
% Revision 1.16  2003/02/22 16:58:02  scott
% header edits, with ??? -sm
%
% Revision 1.15  2003/02/21 22:55:11  arno
% adding gui info
%
% Revision 1.14  2002/12/18 22:25:46  arno
% Automatic file format detection debug
%
% Revision 1.13  2002/12/05 02:26:41  arno
% adding an additionnal warning for clicking on the selected option
%
% Revision 1.12  2002/09/25 23:50:01  arno
% correcting float-le problem
%
% Revision 1.11  2002/09/04 18:30:31  luca
% same
%
% Revision 1.10  2002/09/04 18:30:11  luca
% same
%
% Revision 1.9  2002/09/04 18:28:23  luca
% 'debug command line big variable passed as text - arno
%
% Revision 1.8  2002/09/04 18:24:09  luca
% debug for command line - arno
%
% Revision 1.7  2002/07/31 18:02:26  arno
% adding more options
%
% Revision 1.6  2002/05/02 23:55:22  arno
% auto file type selection
%
% Revision 1.5  2002/04/20 23:53:14  scott
% editted screen items -sm
%
% Revision 1.4  2002/04/18 02:35:24  arno
% put default Matlab file read
%
% Revision 1.3  2002/04/11 22:22:52  arno
% removing comment
%
% Revision 1.2  2002/04/11 21:18:34  arno
% *** empty log message ***
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 01-25-02 reformated help & license -ad 
% 03-16-02 text interface editing -sm & ad 
% 03-16-02 remove EEG.xmax et EEG.xmin (for continuous) -ad & sm
% 04-02-02 debugging command line calls -ad & lf

function [EEGOUT, com] = pop_importdata( varargin);

com = '';
EEGOUT = eeg_emptyset;
if nargin < 1                 % if several arguments, assign values 
   % popup window parameters	
   % -----------------------
    geometry    = { [1.4 0.7 .8 0.5] [2 3.02] [1] [2.5 1 1.5 1.5] [2.5 1 1.5 1.5] [2.5 1 1.5 1.5] [2.5 1 1.5 1.5] [2.5 1 1.5 1.5] ...
                    [1] [1.4 0.7 .8 0.5] [1] [1.4 0.7 .8 0.5] [1.4 0.7 .8 0.5] };
    editcomments = [ 'tmp = pop_comments(get(gcbf, ''userdata''), ''Edit comments of current dataset'');' ...
                     'if ~isempty(tmp), set(gcf, ''userdata'', tmp); end; clear tmp;' ];
    commandload = [ '[filename, filepath] = uigetfile(''*'', ''Select a text file'');' ...
                    'if filename ~=0,' ...
                    '   set(findobj(''parent'', gcbf, ''tag'', tagtest), ''string'', [ filepath filename ]);' ...
                    'end;' ...
                    'clear filename filepath tagtest;' ];
	commandsetfiletype = [ 'filename = get( findobj(''parent'', gcbf, ''tag'', ''globfile''), ''string'');' ...
					'tmpext = findstr(filename,''.'');' ...
					'tmpext = lower(filename(tmpext(end)+1:end));' ...
					'switch tmpext, ' ...
					'  case ''mat'', set(findobj(gcbf,''tag'', ''loclist''), ''value'',5);' ...
					'  case ''fdt'', set(findobj(gcbf,''tag'', ''loclist''), ''value'',3);' ...
					'  case ''txt'', set(findobj(gcbf,''tag'', ''loclist''), ''value'',2);' ...
					'end; clear tmpext filename;' ];
    commandselica = [ 'res = inputdlg2({ ''Enter dataset number'' }, ''Select ICA weights and sphere from other dataset'', 1, { ''1'' });' ...
                      'if ~isempty(res),' ...
                      '   set(findobj( ''parent'', gcbf, ''tag'', ''weightfile''), ''string'', sprintf(''ALLEEG(%s).icaweights'', res{1}));' ...
                      '   set(findobj( ''parent'', gcbf, ''tag'', ''sphfile'')   , ''string'', sprintf(''ALLEEG(%s).icasphere'' , res{1}));' ...
                      'end;' ];
    commandselchan = [ 'res = inputdlg2({ ''Enter dataset number'' }, ''Select channel information from other dataset'', 1, { ''1'' });' ...
                      'if ~isempty(res),' ...
                      '   set(findobj( ''parent'', gcbf, ''tag'', ''chanfile''), ' ...
                      '                ''string'', sprintf(''{ ALLEEG(%s).chanlocs ALLEEG(%s).chaninfo ALLEEG(%s).urchanlocs }'', res{1}, res{1}, res{1}));' ...
                      'end;' ];
    if isstr(EEGOUT.ref)
        curref = EEGOUT.ref;
    else
        if length(EEGOUT.ref) > 1
            curref = [ int2str(abs(EEGOUT.ref)) ];
        else
            curref = [ int2str(abs(EEGOUT.ref)) ];
        end;
    end;
                        
    uilist = { ...
         { 'Style', 'text', 'string', 'Data file/array (click on the selected option)', 'horizontalalignment', 'right', 'fontweight', 'bold' }, ...
         { 'Style', 'listbox', 'string', 'Matlab variable|ASCII text file|float32 le file|float32 be file|Matlab .mat file', ...
		   'fontweight', 'bold', 'tag','loclist' } ...
         { 'Style', 'edit', 'string', '', 'horizontalalignment', 'left', 'tag',  'globfile' }, ...
         { 'Style', 'pushbutton', 'string', 'Browse', 'callback', ...
		   [ 'tagtest = ''globfile'';' commandload commandsetfiletype ] }, ...
         ...
         { 'Style', 'text', 'string', 'Dataset name', 'horizontalalignment', 'right', ...
		   'fontweight', 'bold' }, { 'Style', 'edit', 'string', '' }, { } ...
         ...
         { 'Style', 'text', 'string', 'Data sampling rate (Hz)', 'horizontalalignment', 'right', 'fontweight', ...
		   'bold' }, { 'Style', 'edit', 'string', num2str(EEGOUT.srate) }, ...
         { 'Style', 'text', 'string', 'Subject code', 'horizontalalignment', 'right', ...
		    },   { 'Style', 'edit', 'string', '' }, ...
         { 'Style', 'text', 'string', 'Time points per epoch (0->continuous)', 'horizontalalignment', 'right', ...
		   },  { 'Style', 'edit', 'string', num2str(EEGOUT.pnts) }, ...
         { 'Style', 'text', 'string', 'Task condition', 'horizontalalignment', 'right', ...
		   },   { 'Style', 'edit', 'string', '' }, ...
         { 'Style', 'text', 'string', 'Start time (sec) (only for data epochs)', 'horizontalalignment', 'right', ...
		   }, { 'Style', 'edit', 'string', num2str(EEGOUT.xmin) }, ...
         { 'Style', 'text', 'string', 'Session number', 'horizontalalignment', 'right', ...
		   },   { 'Style', 'edit', 'string', '' }, ...
         { 'Style', 'text', 'string', 'Number of channels (0->set from data)', 'horizontalalignment', 'right', ...
		    },   { 'Style', 'edit', 'string', '0' }, ...
         { 'Style', 'text', 'string', 'Subject group', 'horizontalalignment', 'right', ...
		   },   { 'Style', 'edit', 'string', '' }, ...
         { 'Style', 'text', 'string', 'Ref. channel indices or mode (see help)', 'horizontalalignment', 'right', ...
		   }, { 'Style', 'edit', 'string', curref }, ...
         { 'Style', 'text', 'string', 'About this dataset', 'horizontalalignment', 'right', ...
		   },   { 'Style', 'pushbutton', 'string', 'Enter comments' 'callback' editcomments }, ...
         { } ...
         { 'Style', 'text', 'string', 'Channel location file or info', 'horizontalalignment', 'right', 'fontweight', ...
		   'bold' }, {'Style', 'pushbutton', 'string', 'From other dataset', 'callback', commandselchan }, ...
         { 'Style', 'edit', 'string', '', 'horizontalalignment', 'left', 'tag',  'chanfile' }, ...
         { 'Style', 'pushbutton', 'string', 'Browse', 'callback', [ 'tagtest = ''chanfile'';' commandload ] }, ...
         ...
         { 'Style', 'text', 'string', ...
           '      (note: autodetect file format using file extension; use menu "Edit > Channel locations" for more importing options)', ...
           'horizontalalignment', 'right' }, ...
         ...
         { 'Style', 'text', 'string', 'ICA weights array or text/binary file (if any):', 'horizontalalignment', 'right' }, ...
         { 'Style', 'pushbutton' 'string' 'from other dataset' 'callback' commandselica }, ...
         { 'Style', 'edit', 'string', '', 'horizontalalignment', 'left', 'tag',  'weightfile' }, ...
         { 'Style', 'pushbutton', 'string', 'Browse', 'callback', [ 'tagtest = ''weightfile'';' commandload ] }, ...
         ...
         { 'Style', 'text', 'string', 'ICA sphere array or text/binary file (if any):', 'horizontalalignment', 'right' },  ...
         { 'Style', 'pushbutton' 'string' 'from other dataset' 'callback' commandselica }, ...
         { 'Style', 'edit', 'string', '', 'horizontalalignment', 'left', 'tag',  'sphfile' } ...
         { 'Style', 'pushbutton', 'string', 'Browse', 'callback', [ 'tagtest = ''sphfile'';' commandload ] } };

    [ results newcomments ] = inputgui( geometry, uilist, 'pophelp(''pop_importdata'');', 'Import dataset info -- pop_importdata()');
    if length(results) == 0, return; end;
	args = {};

    % specific to importdata (not identical to pop_editset
    % ----------------------------------------------------
	switch results{1}
	   case 1, args = { args{:}, 'dataformat', 'array' };
	   case 2, args = { args{:}, 'dataformat', 'ascii' };
	   case 3, args = { args{:}, 'dataformat', 'float32le' };
	   case 4, args = { args{:}, 'dataformat', 'float32be' };
	   case 5, args = { args{:}, 'dataformat', 'matlab' };
	end;
	if ~isempty( results{2} ) ,  args = { args{:}, 'data',              results{2}  }; end;

    i = 3;
	if ~isempty( results{i  } ) , args = { args{:}, 'setname',           results{i  }  }; end;    
	if ~isempty( results{i+1} ) , args = { args{:}, 'srate',     str2num(results{i+1}) }; end;
	if ~isempty( results{i+2} ) , args = { args{:}, 'subject',           results{i+2}  }; end;
	if ~isempty( results{i+3} ) , args = { args{:}, 'pnts',      str2num(results{i+3}) }; end;
	if ~isempty( results{i+4} ) , args = { args{:}, 'condition',         results{i+4}  }; end;
    if ~isempty( results{i+5} ) , args = { args{:}, 'xmin',      str2num(results{i+5}) }; end;
    if ~isempty( results{i+6} ) , args = { args{:}, 'session',   str2num(results{i+6}) }; end;
	if ~isempty( results{i+7} ) , args = { args{:}, 'nbchan',    str2num(results{i+7}) }; end;
    if ~isempty( results{i+8} ) , args = { args{:}, 'group',             results{i+8}  }; end;
    if ~isempty( results{i+9} ) , args = { args{:}, 'ref',       str2num(results{i+9}) }; end;
	if ~isempty( newcomments ) , args = { args{:}, 'comments',  newcomments          }; end;
    
    if abs(str2num(results{i+5})) > 10,
        fprintf('WARNING: are you sure the epoch start time (%3.2f) is in seconds\n');
    end;
    
	if ~isempty( results{i+10} ) , args = { args{:}, 'chanlocs' ,  results{i+10} }; end;
	if ~isempty( results{i+11} ),  args = { args{:}, 'icaweights', results{i+11} }; end;
	if ~isempty( results{i+12} ) , args = { args{:}, 'icasphere',  results{i+12} }; end;

    % generate the output command
    % ---------------------------
    EEGOUT = pop_editset(EEGOUT, args{:});
    com    = sprintf( 'EEG = pop_importdata(%s);', vararg2str(args) );
    
    %com = '';
    %for i=1:2:length(args)
    %    if ~isempty( args{i+1} )
    %        if isstr( args{i+1} ) com = sprintf('%s, ''%s'', ''%s''', com, args{i}, char(args{i+1}) );
    %        else                  com = sprintf('%s, ''%s'', [%s]', com, args{i}, num2str(args{i+1}) );
    %        end;
    %    else
    %        com = sprintf('%s, ''%s'', []', com, args{i} );
    %    end;
    %end;
    %com = [ 'EEG = pop_importdata(' com(2:end) ');'];

else % no interactive inputs
    EEGOUT = pop_editset(EEGOUT, varargin{:});
end;

return;
