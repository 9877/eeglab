% pop_reref() - Convert an EEG dataset to average reference or to a
%               new common reference channel (or channels). Calls reref().
% Usage:
%       >> EEGOUT = pop_reref( EEG ); % pop up interactive window
%       >> EEGOUT = pop_reref( EEG, ref, 'key', 'val' ...);
%
% Graphic interface:
%   "Compute average reference" - [edit box] Checking this box (for 'yes') is 
%                 the same as giving an empty value for the commandline 'ref' 
%                 argument. Unchecked, the data are transformed to common reference.
%   "Re-reference data to channel number(s)" - [checkbox] Checking this option
%                 automatically unchecks the checkbox above, allowing reference 
%                 channel indices to be entered in the text edit box to its right
%                 (No commandline equivalent).
%   "Re-reference data to channel number(s)" - [edit box] Enter the index of 
%                 the electrode(s) for re-referencing here. Commandline
%                equivalent: 'ref'. 
%   "Include old reference channel" - [checkbox] When re-referencing the 
%                 data, checking this checkbox reconstitutes the data for the 
%                 previous reference channel. If the location for this channel 
%                 was not defined, it can be specified using the text box below.
%                 Commandline equivalent: 'method', 'withref'
%   "Include old reference channel" - [edit boxes] Use these edit boxes to specify 
%                 the previous reference channel location. Same as the 'refloc' 
%                 commandline option. Note: When the chanloc structure 
%                 contains one more channel than the data do, its last channel 
%                 is taken to be the (previous) reference, and its location 
%                 does not have to be specified again here. 
% Inputs:
%   EEG         - input dataset
%   ref         - reference: []            = convert to average reference
%                            [int vector]  = new reference electrode number(s)
% Optional inputs:
%   'method'    - ['standard'|'withref'] can either be 'withref' = recompute 
%                 the previous reference channel data, or 'standard' = do not
%                 recompute the previous reference channel. See >> help reref()
%   'refloc'    - [cell array] Previous common-reference channel label and polar 
%                 coordinates location. Ex: { 'Cz' 0 0 }. This information may 
%                 also be passed as the last channel in the 'EEG.chanlocs' data 
%                 struture). 
% Outputs:
%   EEGOUT      - re-referenced output dataset
%
% Notes:
%                 For other options, call reref() directly. See >> help reref
%
% Author: Arnaud Delorme, CNL / Salk Institute, 12 Nov 2002
%
% See also: reref(), eeglab()

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
% Revision 1.32  2007/02/16 18:59:24  scott
% clarified help msg  -sm
%
% Revision 1.31  2006/05/04 10:07:07  arno
% same
%
% Revision 1.29  2005/01/24 19:30:37  arno
% remove field for Keun re-refencing
% ,.
%
% Revision 1.28  2004/05/14 23:58:23  arno
% operator precedence
%
% Revision 1.27  2004/01/30 23:01:52  arno
% update channel position only if refloc is set
%
% Revision 1.26  2003/11/05 16:24:17  arno
% homogenous -> homogeneous
%
% Revision 1.25  2003/10/14 17:03:08  arno
% vararg2str for optional arguments
%
% Revision 1.24  2003/09/08 22:54:12  arno
% typo for refstate
%
% Revision 1.23  2003/07/31 17:10:05  arno
% conversion to 3-D for the last channel
%
% Revision 1.22  2003/07/31 17:03:31  arno
% empty last channel
%
% Revision 1.21  2003/07/30 18:03:59  arno
% allowing empty channel location
%
% Revision 1.20  2003/07/28 17:53:39  arno
% channel ref index
%
% Revision 1.19  2003/07/28 16:46:49  arno
% remove redundancy
%
% Revision 1.18  2003/07/28 16:42:03  arno
% text with scott
%
% Revision 1.17  2003/07/27 01:19:21  arno
% debuging GUI call
%
% Revision 1.16  2003/07/27 01:09:30  arno
% debuging
%
% Revision 1.15  2003/07/27 00:44:32  arno
% brand new function for rereferencing
%
% Revision 1.14  2003/07/25 23:49:54  arno
% change interface, warning messages ...
%
% Revision 1.13  2003/07/25 00:11:56  arno
% allowing multiple references
%
% Revision 1.12  2003/07/25 00:10:51  arno
% correct typo
%
% Revision 1.11  2003/07/02 01:06:00  arno
% remove debug msg
%
% Revision 1.10  2003/07/02 01:05:34  arno
% debug msg
%
% Revision 1.9  2003/06/11 00:06:16  arno
% header message
%
% Revision 1.8  2003/02/17 02:53:22  arno
% reformating text for new functionality in help2html
%
% Revision 1.7  2003/02/16 23:30:20  arno
% adding GUI info
%
% Revision 1.6  2002/11/13 23:13:51  arno
% gui mutual exclusion problem
%
% Revision 1.5  2002/11/13 23:04:40  arno
% removing extra electrode in average ref
%
% Revision 1.4  2002/11/13 20:29:44  arno
% debugging
%
% Revision 1.3  2002/11/13 19:22:23  arno
% averef field -> ref field
%
% Revision 1.2  2002/11/12 23:23:37  arno
% mode -> method keyword
%
% Revision 1.1  2002/11/12 19:08:34  arno
% Initial revision
%
% Revision 1.1  2002/04/05 17:32:13  arno
% Initial revision
%

function [EEG, com] = pop_reref( EEG, ref, varargin);

com = '';
if nargin < 1
   help pop_reref;
   return;
end;   
if isempty(EEG.data)
    error('Pop_reref: cannot process empty data');
end;

% gui inputs
% ----------
if nargin < 2
    
    % find initial reference
    % ----------------------
    options = { 'refstate', EEG.ref };
    includeref = 0; % this is for the second gui
    if strcmpi(EEG.ref, 'common')
        if length(EEG.chanlocs) == EEG.nbchan+1
            disp('Extra channel detected: using channel as reference');
            includeref = 1;
            options = { 'refstate',  EEG.nbchan+1 };
        else
            geometry = { [1] [1.8 1] [1.8 1] [1.8 1] [1] [3 1 1 1] [3 1 1 1] };
            enable1 = fastif(strcmp(EEG.ref, 'averef'), 'on', 'off');
            enable2 = fastif(strcmp(EEG.ref, 'averef'), 'off', 'on');
            
            % build gui
            % ---------
            geometry = { [1] [1.7 1] [1] [1.7 0.7] [1.7 0.7] [1] [3 1 1 1] [3 1 1 1] [1]};
            vertgeom = [ 1   1       1   1       1       1   1         1          4];
            uilist = { { 'style' 'text' 'string' 'THIS SCREEN IS USED TO ENTER CURRENT REFERENCE AND WILL ONLY APPEAR ONCE' } ...
                       { 'style' 'checkbox' 'tag' 'ave' 'value' 0 'string' 'Data are in average reference' ...
                         'callback' ...
                         [ 'set(findobj(''parent'', gcbf, ''tag'', ''reref''), ''value'', ~get(gcbo, ''value''));' ...
                           'set(findobj(''parent'', gcbf, ''tag'', ''reref2''), ''value'', ~get(gcbo, ''value''), ''enable'', ''off'');' ...
                           'set(findobj(''parent'', gcbf, ''tag'', ''oldref''), ''enable'', fastif(get(gcbo, ''value''), ''off'', ''on''));' ...
                           'set(findobj(''parent'', gcbf, ''tag'', ''rerefstr''), ''enable'', fastif(get(gcbo, ''value''), ''off'', ''on''));' ] } ...
                       { } ...
                       { 'style' 'text' 'string' '                                                     OR' } ...
                       { 'style' 'checkbox' 'tag' 'reref' 'value' 1 'string' 'Data are referenced to one site (default)' ...
                         'callback' ...
                         [ 'set(findobj(''parent'', gcbf, ''tag'', ''ave''), ''value'', ~get(gcbo, ''value''));'  ...
                           'set(findobj(''parent'', gcbf, ''tag'', ''reref2''), ''value'', 0, ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));' ...
                           'set(findobj(''parent'', gcbf, ''tag'', ''rerefstr''), ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));' ] } ...
                       { } ...
                       { 'style' 'text' 'string' 'Reference channel number(s), if present in data (default: []):' } ...
                       { 'style' 'edit' 'tag' 'rerefstr' 'string' '' } ...
                       { } ...
                       { } ...
                       { 'style' 'text' 'tag' 'oldref' 'enable' 'off' 'string' 'Label' } ...
                       { 'style' 'text' 'tag' 'oldref' 'enable' 'off' 'string' 'Polar angle' } ...
                       { 'style' 'text' 'tag' 'oldref' 'enable' 'off' 'string' 'Radius' } ...
                       { 'style' 'checkbox' 'tag' 'reref2' 'enable' enable2 'string' 'Include current reference channel in data' 'callback' ...
                         'set(findobj(''parent'', gcbf, ''tag'', ''oldref''), ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));' } ...
                       { 'style' 'edit' 'tag' 'oldref' 'enable' 'off' 'string' '' } ...
                       { 'style' 'edit' 'tag' 'oldref' 'enable' 'off' 'string' '' } ...
                       { 'style' 'edit' 'tag' 'oldref' 'enable' 'off' 'string' '' } ...
                       { 'style' 'text' 'string' strvcat('Note: by including a reference channel in your data (above), its potential may be computed when', ...
                                                         'you re-reference the data. If you have polar coordinates of the reference channel, enter them above;', ...
                                                         'If the dataset has no channel locations, you may leave the label and location fields empty;', ...
                                                         [ 'If you have 3-D location coordinates only, then Cancel and create a new channel ' int2str(EEG.nbchan+1) ], ...
                                                         'in Edit > Channel locations. Then return to Tools > Re-reference.') } ...
                     };
            result = inputgui(geometry, uilist, 'pophelp(''pop_reref'')', 'Initial reference - pop_reref()', [], 'normal', vertgeom);
            if isempty(result), return; end;

            % decode inputs
            % -------------
            options = { }; % ersase
            if result{1}, options = { 'refstate', 'averef' };
            elseif result{2},
                tmpres3 = eval([ '[' result{3} ']' ] );
                if ~isempty( tmpres3 )
                    options = { 'refstate',  - tmpres3 };
                elseif result{4},
                    options = { 'refstate',  EEG.nbchan+1 };
                else
                    options = { 'refstate',  0 };
                end;
            end;
            if result{4},
                % options = { options{:} 'method' 'withref' }; do not include here, otherwise redundant with next gui
                includeref = 1;
                if ~isempty(result{5}),
                    options = { options{:} 'refloc' { result{5} eval(result{6}) eval(result{7}) } };
                else
                    if ~isempty(EEG.chanlocs)
                        error('To include current reference channel in data, a channel location must be provided');
                    end;
                end;
            else
                includeref = 0;
            end;
        end;
    end;
    
    if length(EEG.chanlocs) == EEG.nbchan+1
        includeref = 1;
    end;
    
    % compute new reference
    % ---------------------
    enable1 = fastif(strcmp(EEG.ref, 'averef'), 'on', 'off');
    enable2 = fastif(strcmp(EEG.ref, 'averef'), 'off', 'on');

    if isstr(EEG.ref)
        curref = EEG.ref;
    else
        if EEG.ref(1) < 0
            curref = [ int2str(-EEG.ref) ' (absent from data)' ];
        else
            curref = [ int2str(-EEG.ref) ' (present in data)' ];
        end;
    end;
    
    geometry = { [1] [1.8 1] [1.8 1] [1.8] [1] [1.8] [1] [1.8 1] };
    uilist = { { 'style' 'text' 'string' ['Current data reference state is: ' curref] } ...
               { 'style' 'checkbox' 'tag' 'ave' 'value' fastif(strcmp(EEG.ref, 'averef'), 0, 1) 'string' 'Compute average reference' ...
                         'callback' ...
                 [ 'set(findobj(''parent'', gcbf, ''tag'', ''reref''), ''value'', ~get(gcbo, ''value''));' ...
                   'set(findobj(''parent'', gcbf, ''tag'', ''rerefstr''), ''enable'', fastif(get(gcbo, ''value''), ''off'', ''on''));' ] } ...
               { } ...
               { 'style' 'checkbox' 'tag' 'reref' 'value' fastif(strcmp(EEG.ref, 'averef'), 1, 0) 'string' 'Re-reference data to channel number(s):' ...
                 'callback' [ 'set(findobj(''parent'', gcbf, ''tag'', ''ave''), ''value'', ~get(gcbo, ''value''));'  ...
                 'set(findobj(''parent'', gcbf, ''tag'', ''rerefstr''), ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));' ] } ...
               { 'style' 'edit' 'tag' 'rerefstr' 'string' '' 'enable' enable1 } ...
               { 'style' 'checkbox' 'tag' 'rerefstr' 'string' 'Retain reference channels in data (if more than one)' 'enable' enable1 } ...
               { 'style' 'text' 'string' [ 'Note: to include current reference in new reference, include channel ' int2str(EEG.nbchan+1) ' above' ] ...
                 'enable' fastif(includeref, 'on', 'off') } ...
               { 'style' 'checkbox' 'value' includeref 'enable' fastif(includeref, 'on', 'off') 'string' 'Add current reference channel to data' } ...
               { } ...
               { 'style' 'text' 'string' 'Exclude channel indices (EMG, EOG)' } ...
               { 'style' 'edit' 'tag' 'exclude' 'string' '' } };
    
    result = inputgui(geometry, uilist, 'pophelp(''pop_reref'')', 'pop_reref - average reference or re-reference data');
    if isempty(result), return; end;

    % decode inputs
    % -------------
    if ~isempty(result{3}), ref = eval([ '[' result{3} ']' ] );
    else                    ref = [];
    end;
    if result{1}, ref = []; 
    elseif result{4}
        options = { options{:} 'keepref' 'on' };
    end;
    if result{5},           options = { options{:} 'method' 'withref' }; end;
    if ~isempty(result{6}), options = { options{:} 'exclude' eval([ '[' result{6} ']' ] ) }; end;
else
    options = varargin;
end;
optionscall = options;

% decode inputs
% -------------
withref = 0;
keepref = 0;
refstate = NaN;
for index = 1:length(options)
    if isstr(options{index}) & strcmpi(options{index}, 'withref');
        withref = 1;
    end;
    if isstr(options{index}) & strcmpi(options{index}, 'keepref');
        keepref = 1;
    end;
    if isstr(options{index}) & strcmpi(options{index}, 'refstate');
        refstate = options{index+1};
    end;
end;

% add refstate if absent
% ----------------------
if isnan(refstate)
    if isfield(EEG, 'ref')
        options  = { options{:} 'refstate' EEG.ref };
        refstate = EEG.ref;
    else
        options  = { options{:} 'refstate' 0 };
        refstate = 0;
    end;
end;

% warn user
% ---------
if nargin < 2
    if ~isstr(ref) & length(ref) > 1 & keepref == 0
        res = questdlg2(strvcat('Using multiple references and suppressing reference channels', ...
                                'reduces the dimensionality of the data. Do you want to continue ?'), 'warning', 'Cancel', 'Yes', 'yes');
        if strcmpi(res, 'Cancel'), return; end;
    end;
end;

% include channel location file
% -----------------------------
if ~isempty(EEG.chanlocs)
    optionscall = { optionscall{:} 'elocs' EEG.chanlocs }; 
end;    

% include ICA or not
% ------------------
if ~isempty(EEG.icaweights)
    optionscall = { optionscall{:} 'icaweight' EEG.icaweights*EEG.icasphere 'icachansind' EEG.icachansind }; 
    [EEG.data EEG.chanlocs EEG.icaweights EEG.icasphere EEG.icachansind] = reref(EEG.data, ref, optionscall{:});
else 
    [EEG.data EEG.chanlocs ] = reref(EEG.data, ref, optionscall{:});
end;

% add a tag in the dataset and clear some fields
% ----------------------------------------------
if isempty(ref)
    EEG.ref = 'averef';
else 
    if length(ref) == 1
        if withref == 1
            EEG.ref = EEG.nbchan+1;
        else
            EEG.ref = -ref;
        end;
    else
        if keepref
            EEG.ref = ref;
        else
            EEG.ref = -ref;
        end;
    end;
end;
EEG.icaact  = [];
EEG.icawinv = [];
EEG.nbchan  = size(EEG.data,1);

EEG = eeg_checkset(EEG);
if ~isempty(EEG.chanlocs)
    if ( length(options) > 1 & strcmpi(options{1}, 'refloc') ) | ...
          ( length(options) > 3 & strcmpi(options{3}, 'refloc') )
        EEG = eeg_checkset(EEG, 'chanlocs_homogeneous');
        if ~isfield(EEG.chanlocs, 'X') | isempty(EEG.chanlocs(end).X)
            tmp = convertlocs(EEG.chanlocs(end), 'topo2all');
            fieldtmp = setdiff( fieldnames(tmp), { 'sph_theta_besa' 'sph_phi_besa' });
            for index = 1:length(fieldtmp)
                tmpval = getfield(tmp, fieldtmp{index});
                EEG.chanlocs(end) = setfield(EEG.chanlocs(end), fieldtmp{index}, tmpval);
            end;
        end;
    end;
end;

% generate the output command
% ---------------------------
com = sprintf('%s = pop_reref( %s, %s);', inputname(1), inputname(1), vararg2str({ref, options{:}}));
return;
