% std_prepare_neighbors() - prepare Fieldtrip channel neighbor structure.
%                           Only prepare the structure if necessary based
%                           on statistical options in STUDY.etc.statistics.
%                           Use the 'force' option to force preparing the
%                           matrix.
%
% Usage:
%   >> [STUDY neighbors] = std_prepare_neighbors( STUDY, ALLEEG, 'key', val)
%
% Inputs:
%   STUDY        - an EEGLAB STUDY set of loaded EEG structures
%   ALLEEG       - ALLEEG vector of one or more loaded EEG dataset structures
%
% Optional inputs:
%   'force'        - ['on'|'off'] force generating the structure irrespective
%                    of the statistics options selected. Default is 'off'.
%   'method'       - [string] method for preparing. See ft_prepare_neighbors
%   'neighbordist' - [float] max distance. See ft_prepare_neighbors
%
% Note: other ft_prepare_neighbors fields such as template, layout may
%       also be used as optional keywords.
%
% Outputs:
%   STUDY       - an EEGLAB STUDY set of loaded EEG structures
%   neighbors   - Fieldtrip channel neighbour structure
%
% Author: Arnaud Delorme, SCCN, UCSD, 2012-
%
% See also: statcondfieldtrip()

% Copyright (C) Arnaud Delorme
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

function [STUDY neighbors] = std_prepare_neighbors(STUDY, ALLEEG, varargin);

neighbors = [];
if nargin < 2
    return;
end;

[opt addopts] = finputcheck( varargin, {  'force'  'string'  { 'on','off' }   'off' }, 'std_stat', 'ignore');

if strcmpi(STUDY.etc.statistics.fieldtrip.mcorrect, 'cluster') && strcmpi(STUDY.etc.statistics.mode, 'fieldtrip') && ...
        ~isempty(STUDY.etc.statistics.fieldtrip.channelneighbor) && isempty(addopts)

    disp('Using stored channel neighbour structure');
    neighbors = STUDY.etc.statistics.fieldtrip.channelneighbor;

elseif strcmpi(STUDY.etc.statistics.fieldtrip.mcorrect, 'cluster') || strcmpi(opt.force, 'on')

    EEG = eeg_emptyset;
    EEG.chanlocs = eeg_mergelocs(ALLEEG.chanlocs);
    if isempty(EEG.chanlocs)
        disp('std_prepare_neighbors: cannot prepare channel neighbour structure because of empty channel structures');
        return;
    end;
    EEG.nbchan   = length(EEG.chanlocs);
    EEG.data     = zeros(EEG.nbchan,100,1);
    EEG = eeg_checkset(EEG);
    tmpcfg = eeglab2fieldtrip(EEG, 'preprocessing', 'none');
    
    % call the function that find channel neighbors
    % ---------------------------------------------
    addparams = eval( [ '{' STUDY.etc.statistics.fieldtrip.channelneighborparam '}' ]);
    for index = 1:2:length(addparams)
        tmpcfg = setfield(tmpcfg, addparams{index}, addparams{index+1});
    end;
    for index = 1:2:length(addopts)
        tmpcfg = setfield(tmpcfg, addopts{index}, addopts{index+1});
    end;
    warning off;
    cfg.neighbors = ft_prepare_neighbours(tmpcfg, tmpcfg);
    warning on;
    neighbors = cfg.neighbors;
    STUDY.etc.statistics.fieldtrip.channelneighbor = neighbors;
    
end;
