% pop_newset() - Edit dataset info. 
%
% Usage:
%   >> [ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENSET, ...
%                                            'key', val,...);
%
% Inputs and outputs:
%   ALLEEG     - array of dataset structures
%   EEG        - dataset structure
%   CURRENTSET - number of the current dataset
%
% Optional inputs:
%   'setname'     - Name of the dataset
%   'comments'    - 'string' string of comments
%   'overwrite'   - ['on'|'off'] overwrite parent dataset
%   'save'        - 'filename' save the dataset
%   'retrieve'    - dataset number, retrieve a dataset
%
% Note: 1) this function take into account the content of eeg_options
%       for dataset overwritting. If the dataset overwritting
%       feature is set, the 'overwrite' arguement is ignored.
%       2) this function calls eeg_store() which may modify the 
%       variable ALLEEG containing all the dataset information.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 23 Arpil 2002
%
% See also: eeg_store(), pop_editset(), eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 23 Arpil 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
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
% Revision 1.2  2002/04/26 02:51:26  arno
% adding com parameter
%
% Revision 1.1  2002/04/26 02:46:37  arno
% Initial revision
%

%   'aboutparent' - ['on'|'off'] insert reference to parent dataset in the comments

function [ALLEEG, EEG, CURRENTSET, com] = pop_newset( ALLEEG, EEG, CURRENTSET, varargin);

com = '';
if nargin < 3
   help pop_newset;
   return;
end;   

if nargin < 4                 % if several arguments, assign values 
    % popup window parameters	
    % -----------------------
    comcomment = ['tmpuserdat = get(gcbf, ''userdata'');' ...
				  'tmpuserdat{1} = pop_comments(tmpuserdat{1}, ''Edit dataset comments'');' ...
				  'set(gcbf, ''userdata'', tmpuserdat); clear tmpuserdat;'];
	comsave    = ['tmpuserdat = get(gcbf, ''userdata'');' ...
				  '[tmpfile tmppath] = uigetfile(''*.set'', ''Enter filename'');' ...
				  'if tmpfile ~= 0,' ...
			      '    tmpuserdat{2} = strcat(tmppath, tmpfile);' ...
				  '    set(gcbf, ''userdata'', tmpuserdat);' ...
				  '    set(findobj(''parent'', gcbf, ''tag'', ''saveedit''), ''string'', tmpuserdat{2});' ...
				  'end;' ...
				  'clear tmpuserdat tmpfile tmppath;'];
    comover   = [ 'tmpuserdat = get(gcbf, ''userdata'');' ...
				  'tmpuserdat{3} = get(gcbo, ''value'');' ...
				  'set(gcbf, ''userdata'', tmpuserdat); clear tmpuserdat;'];
	userdat = { EEG.comments, '', comover };
    geometry    = { [1 3 1] [1] [1.5 1.8 1 0.5 1.5]};
    uilist = { ...
         { 'Style', 'text', 'string', 'Dataset name:', 'horizontalalignment', 'right', 'fontweight', 'bold' }, ...
		 { 'Style', 'edit', 'string', EEG.setname } ...
		 { 'Style', 'pushbutton', 'string', 'Comments', 'tooltipstring', 'Modify comments of this new dataset', 'callback', comcomment }, ...
		 {} ...
         ...
         { 'Style', 'text', 'string', 'File to save dataset', 'tooltipstring', 'It is advised to save dataset as often as possible' }, ...
         { 'Style', 'edit', 'string', '', 'tag', 'saveedit' }, ...
         { 'Style', 'pushbutton', 'string', 'Browse', 'tooltipstring', 'It is advised to save dataset as often as possible', 'callback', comsave }, ...
         {} { 'Style', 'checkbox'  , 'string', 'Overwrite parent', 'tooltipstring', 'Overwritting parent dataset can help to save memory', 'callback', comover }, ...
		...
         %{ 'Style', 'pushbutton', 'string', 'Memory options', 'tooltipstring', 'Change these options if your computer is short in memory' }, ...
	};

	eeg_options;
	if ~option_keepdataset, uilist{9} = { uilist{9}{:} 'enable', 'off'}; end;
    [result userdat] = inputgui( geometry, uilist, 'pophelp(''pop_newset'');', ...
								  fastif(isempty(EEG.data), 'Import dataset info -- pop_newset()', 'Edit dataset info -- pop_newset()'), userdat);
    if length(result) == 0,
		args = { 'retrieve', CURRENTSET };
	else 
		args = { 'setname', result{1} };
		if ~isempty(result{2}) 
			args = { args{:} 'save', result{2} };
		end;
		if ~strcmp(EEG.comments, userdat{1})
			args = { args{:} 'comments', userdat{1} };
		end;
		if userdat{3} == 1
			args = { args{:} 'overwrite' 'on' };
		end;
	end;
else % no interactive inputs
    args = varargin;
end;

% assigning values
% ----------------
overWflag = 0;
for ind = 1:2:length(args)
    switch lower(args{ind})
	 case 'setname'   , EEG.setname = args{ind+1};
	 case 'comments'  , EEG.comments = args{ind+1};
	 case 'retrieve'  , EEG = eeg_retrieve(ALLEEG, args{ind+1}); overWflag = 1;
	 case 'save'      , EEG = pop_saveset(EEG, args{ind+1}, '');
	 case 'overwrite' , overWflag = 1;
	 otherwise, error(['pop_newset error: unrecognized key ''' args{ind} '''']); 
    end;
end;
if overWflag
	[ALLEEG, EEG] = eeg_store( ALLEEG, EEG, CURRENTSET);
else
	[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG);
end;
	
% generate the output command
% ---------------------------
com = sprintf( '[%s %s %s] = pop_newset(%s, %s, %s, %s)', inputname(1), inputname(2), inputname(3), inputname(1), inputname(2), inputname(3), vararg2str(args));
return;

function num = popask( text )
	 ButtonName=questdlg( text, ...
	        'Confirmation', 'Cancel', 'Yes','Yes');
	 switch lower(ButtonName),
	      case 'cancel', num = 0;
	      case 'yes',    num = 1;
	 end;
