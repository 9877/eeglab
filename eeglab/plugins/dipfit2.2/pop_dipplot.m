% pop_dipplot() - plot dipoles.
%
% Usage:
%   >> pop_dipplot( EEG ); % pop up interactive window
%   >> pop_dipplot( EEG, type, comps, 'key1', 'val1', 'key2', 'val2', ...);
%
% Graphic interface:
%   "Components" - [edit box] enter component number to plot. By
%                all the localized components are plotted. Command
%                line equivalent: components.
%   "Use dipoles from" - [list box] use dipoles from BESA or from the
%                DIPFIT toolbox. Command line equivalent: type.
%   "Background image" - [list box] use BESA background image or average
%                MRI image. Dipplot command line equivalent: 'image'.
%   "Summary mode" - [Checkbox] when checked, plot the 3 views of the
%                head model and dipole locations.
%   "Normalized dipole length" - [Checkbox] normalize the length of
%               all dipoles. Dipplot command line equivalent: 'normlen'.
%   "Additionnal dipfit() options" - [checkbox] enter additionnal 
%               sequence of 'key', 'val' argument in this edit box.
%
% Inputs:
%   EEG   - Input dataset
%   type  - ['DIPFIT'|'BESA'] use either 'DIPFIT' dipoles or
%           'BESA' dipoles.
%   comps - [integer array] plot component indices. If empty
%           all the localized components are plotted.
%
% Optional inputs:
%   Same as dipplot().
%
% Author: Arnaud Delorme, CNL / Salk Institute, 26 Feb 2003
%
% See also: dipplot()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2003 Arnaud Delorme, Salk Institute, arno@salk.edu
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
% Revision 1.1  2003/02/26 17:07:14  arno
% Initial revision
%

function [com] = pop_dipplot( EEG, typedip, comps, varargin);

com ='';
if nargin < 1
    help pop_dipplot;
    return;
end;

if nargin < 2
	% popup window parameters
	% -----------------------
    if isfield(EEG, 'dipfit'), defaulttype = 2;
    elseif isfield(EEG, 'sources'), defaulttype = 1;
    else error('No dipole information in dataset'); 
    end;
    geometry = { [2 1] [2 1] [2 1] [2.05 0.23 .75] [2.05 0.23 .75] [2 1] };
    uilist = { { 'style' 'text' 'string' 'Components indices ([]=all)' } ...
               { 'style' 'edit' 'string' '' } ...
               { 'style' 'text' 'string' 'Use dipoles from (scroll, then click to select)' } ...
               { 'style' 'listbox' 'string' 'BESA|DIPFIT' 'value' defaulttype } ...
               { 'style' 'text' 'string' 'Background image' } ...
               { 'style' 'listbox' 'string' 'BESA Head|average MRI' } ...
               { 'style' 'text' 'string' 'Sumary mode' } ...
               { 'style' 'checkbox' 'string' '' } {} ...
               { 'style' 'text' 'string' 'Normalized dipole length' } ...
               { 'style' 'checkbox' 'string' '' } {} ...
               { 'style' 'text' 'string' 'Additionnal dipfit() options' } ...
               { 'style' 'edit' 'string' '' } };
               
	result = inputgui( geometry, uilist, 'pophelp(''pop_dipplot'')', 'Plot dipoles - pop_dipplot');
	if length(result) == 0 return; end;

	% decode parameters
	% -----------------
    options = {};
    if ~isempty(result{1}), comps = eval( [ '[' result{1} ']' ] ); else comps = []; end;
    if result{2} == 2, typedip = 'DIPFIT';
    else               typedip = 'BESA';
    end;
    options = { options{:} 'image' fastif(result{3} == 2, 'mri', 'besa') };
    if result{4} == 1, options = { options{:} 'summary' 'on' }; end;
    if result{5} == 1, options = { options{:} 'normlen' 'on' }; end;
    if ~isempty( result{6} ), options = { options{:} eval( [ '{' result{5} '}' ] ) }; end;
else 
    options = varargin;
end;

if strcmpi(typedip, 'besa')
    if ~isfield(EEG, 'sources'), error('No BESA dipole information in dataset');end;
    if ~isempty(comps)
        [tmp1 int] = intersect(cell2mat({EEG.sources.component}), comps);
        if isempty(int), error ('Localization not found for selected components'); end;
        dipplot(EEG.sources(int), options{:});
    else
        dipplot(EEG.sources, options{:});
    end;      
else 
    if ~isfield(EEG, 'dipfit'), error('No DIPFIT dipole information in dataset');end;
    if ~isempty(comps)
        dipplot(EEG.dipfit.model(comps), options{:});
    else
        dipplot(EEG.dipfit.model, options{:});
    end;
end;
    
com = sprintf('pop_dipplot( %s, ''%s'', %s);', inputname(1), typedip, vararg2str(options));
return;
