% pop_reref() - Convert an EEG dataset to average reference or to a
%               new common reference.
%
% Usage:
%       >> EEGOUT = pop_reref( EEG, ref, 'key', 'val' ...);
%
% Inputs:
%   EEG         - input dataset
%   ref         - reference: [] = average reference
%                            X  = new reference electrode number
%
% Optional inputs:
%   'method'    - ['standard'|'withref'] can be either 'standard' or 'withref' 
%                 to recompute the old reference potential
%   'refloc'    - old common reference location (can also be included as
%                 the last channel of the EEG.chanlocs struture
%
% Inputs:
%   EEGOUT      - output dataset
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
    % build gui
	% ---------
    geometry = { [1] [1.8 1] [1.8 1] [1] [3 1 1 1] [3 1 1 1] };
    uilist = { { 'style' 'text' 'string' ['Data reference state is: ' EEG.ref] } ...
               { 'style' 'checkbox' 'tag' 'ave' 'value' 1 'string' 'Compute average reference' 'callback' ...
                 [ 'set(findobj(''parent'', gcbf, ''tag'', ''reref''), ''value'', ~get(gcbo, ''value''));' ...
                   'set(findobj(''parent'', gcbf, ''tag'', ''rerefstr''), ''enable'', fastif(get(gcbo, ''value''), ''off'', ''on''));' ] } ...
               { } ...
               { 'style' 'checkbox' 'tag' 'reref' 'string' 'Re-reference data to channel number(s):' 'callback' ...
                 [ 'set(findobj(''parent'', gcbf, ''tag'', ''ave''), ''value'', ~get(gcbo, ''value''));'  ...
                 'set(findobj(''parent'', gcbf, ''tag'', ''rerefstr''), ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));' ] } ...
               { 'style' 'edit' 'tag' 'rerefstr' 'string' '' 'enable' 'off' } ...
               { } ...
               { } ...
               { 'style' 'text' 'tag' 'oldref' 'enable' 'off' 'string' 'Label' } ...
               { 'style' 'text' 'tag' 'oldref' 'enable' 'off' 'string' 'Theta' } ...
               { 'style' 'text' 'tag' 'oldref' 'enable' 'off' 'string' 'Radius' } ...
               { 'style' 'checkbox' 'string' 'Include old reference channel' 'callback' ...
                 'set(findobj(''parent'', gcbf, ''tag'', ''oldref''), ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));' } ...
               { 'style' 'edit' 'tag' 'oldref' 'enable' 'off' 'string' '' } ...
               { 'style' 'edit' 'tag' 'oldref' 'enable' 'off' 'string' '' } ...
               { 'style' 'edit' 'tag' 'oldref' 'enable' 'off' 'string' '' } ...
             };
    if strcmpi(EEG.ref, 'averef') | strcmpi(EEG.ref, 'averefwithref')
        geometry  = { geometry{1:end-2} };
        uilist    = { uilist{1:end-8} };
        uilist{2} = {}; 
    elseif length(EEG.chanlocs) == EEG.nbchan+1
        geometry = { geometry{1:end-2}  [1] };
        uilist   = { uilist{1:end-8} ...
                     { 'style' 'checkbox' 'string' 'Include old reference channel (use location from the electrode location structure)' } };
    end;
    
    result = inputgui(geometry, uilist, 'pophelp(''pop_reref'')', 'pop_reref - average reference or re-reference data');

    % decode inputs
    % -------------
    if isempty(result), return; end;
    if strcmpi(EEG.ref, 'averef') | strcmpi(EEG.ref, 'averefwithref')
        result = { 0 result{:} };
    end;
    if ~isempty(result{3}), ref = eval([ result{3} ] );
    else                    ref = [];
    end;
    if result{1}, ref = []; end;
    options = { };
    if length(result) > 3 & result{4}, options = { options{:} 'method' 'withref' }; end;
    if length(result) > 4 & ~isempty(result{5}), 
        options = { options{:} 'refloc' { result{5} eval(result{6}) eval(result{7}) } };
    end;
else 
    options = varargin;
end;
optionscall = options;

% warning the user
% -----------------
withref = 0;
for index = 1:length(options)
    if isstr(options{index}) & strcmpi(options{index}, 'withref');
        withref = 1;
    end;
end;
if nargin < 2
    if length(ref) > 1 | (~isempty(ref) & withref == 0 & strcmp(EEG.ref, 'common'))
        res = questdlg2(strvcat('Using multiple reference, or using a single reference', ...
                                'without including the old reference reduce the dimensionality', ...
                                'of the data and prevent from re-referencing later on.', ...
                                'Do you want to continue ?'), 'warning', 'Cancel', 'Yes', 'yes');
        if strcmpi(res, 'Cancel'), return; end;
    end;
end;

% include channel location file
% -----------------------------
if ~isempty(EEG.chanlocs)
    optionscall = { optionscall{:} 'elocs' EEG.chanlocs }; 
end;    
if isfield(EEG, 'reref')
    optionscall = { optionscall{:} 'refstate' EEG.ref }; 
end;

% include ICA or not
% ------------------
if ~isempty(EEG.icaweights)
	disp('pop_reref(): converting ICA weight matrix to average reference (see >> help reref)');
    optionscall = { optionscall{:} 'icaweight' EEG.icaweights*EEG.icasphere }; 
    [EEG.data EEG.chanlocs EEG.icaweights EEG.icasphere] = reref(EEG.data, ref, optionscall{:});
else 
    [EEG.data EEG.chanlocs ] = reref(EEG.data, ref, optionscall{:});
end;

% add a tag in the dataset and clear some fields
% ----------------------------------------------
if isempty(ref)
    if ~isempty(ref)     
        EEG.ref = 'common';
    else
        if withref
            EEG.ref = 'averefwithref';
        else 
            EEG.ref = 'averef';
        end;
    end;
end;
EEG.icaact  = [];
EEG.icawinv = [];
EEG = eeg_checkset(EEG);

% generate the output command
% ---------------------------
if isempty( options )
    com = sprintf('%s = pop_reref( %s, [%s]);', inputname(1), inputname(1), num2str(ref));
else 
    com = sprintf('%s = pop_reref( %s, [%s], %s);', inputname(1), inputname(1), num2str(ref), vararg2str(options));
end;    
return;
