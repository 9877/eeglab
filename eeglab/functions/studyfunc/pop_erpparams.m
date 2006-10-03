% pop_erpparams() - Set plotting and statistics parameters for ERP plotting
%
% Usage:    
%   >> STUDY = pop_erpparams(STUDY, 'key', 'val');   
%
% Inputs:
%   STUDY        - EEGLAB STUDY set
%
% Statistics options:
%   'statgroup'  - ['on'|'off'] Compute (or not) statistics across groups.
%                  {default: 'off'}
%   'statcond'   - ['on'|'off'] Compute (or not) statistics across groups.
%                  {default: 'off'}
%   'statistics' - ['param'|'perm'] Type of statistics to use: 'param' for
%                  parametric and 'perm' for permutation-based statistics. 
%                  {default: 'param'}
%   'naccu'      - [integer] Number of surrogate averages to accumulate for
%                  permutation statistics. For example, to test whether 
%                  p<0.01, use >=200. For p<0.001, use 'naccu' >=2000. 
%                  If a threshold (not NaN) is set below, and 'naccu' is 
%                  too low, it will be automatically reset. (This option 
%                  is now available only from the command line).
%   'threshold'  - [NaN|0.0x] Significance threshold. NaN will plot the 
%                  p-value itself on a different axis. When possible, the
%                  significant time regions are indicated below the data.
% Plot options:
%   'timerange'  - [min max] ERP plotting latency range in ms. 
%                  {default: the whole epoch}.
%   'ylim'       - [min max] ERP limits in microvolts {default: from data}
%   'plotgroups' - ['together'|'apart'] 'together' -> plot subject groups 
%                  on the same axis in different colors, else ('apart') 
%                  on different axes.
%   'plotconditions' - ['together'|'apart'] 'together' -> plot conditions 
%                  on the same axis in different colors, else ('apart') 
%                  on different axes. Note: Keywords 'plotgroups' and 
%                  'plotconditions' may not both be set to 'together'. 
%
% See also: std_erpplot()
%
% Authors: Arnaud Delorme, CERCO, CNRS, 2006-

% Copyright (C) Arnaud Delorme, 2006
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
% Revision 1.5  2006/10/02 21:57:51  scott
% plotcond -> plotconditions
%
% Revision 1.4  2006/10/02 17:09:09  scott
% edited help message for clarity and grammar. NOTE: changed argument
% 'appart'  to English 'apart'. ALSO changed keyword 'plotgroup' to
% more grammatical 'plotgroups' throughout. (Note: did not change
% 'plotcond' to 'plotconds' since this abbreviation feels awkward).
% Similar changes may be needed in other functions. -sm
%
% Revision 1.3  2006/10/02 11:38:06  arno
% header documentation
%

function [ STUDY, com ] = pop_erpparams(STUDY, varargin);

STUDY = default_params(STUDY);
TMPSTUDY = STUDY;
com = '';
if isempty(varargin)
    
    enablegroup = fastif(length(STUDY.group)>1, 'on', 'off');
    enablecond  = fastif(length(STUDY.condition)>1, 'on', 'off');
    threshstr   = fastif(isnan(STUDY.etc.erpparams.threshold),'', num2str(STUDY.etc.erpparams.threshold));
    plotconditions    = fastif(strcmpi(STUDY.etc.erpparams.plotconditions, 'together'), 1, 0);
    plotgroups  = fastif(strcmpi(STUDY.etc.erpparams.plotgroups,'together'), 1, 0);
    statval     = fastif(strcmpi(STUDY.etc.erpparams.statistics,'param'), 1, 2);
    statcond    = fastif(strcmpi(STUDY.etc.erpparams.statcond, 'on'), 1, 0);
    statgroup   = fastif(strcmpi(STUDY.etc.erpparams.statgroup,'on'), 1, 0);
    
    uilist = { ...
        {'style' 'text'       'string' 'Time range (ms)'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erpparams.timerange) 'tag' 'timerange' } ...
        {'style' 'text'       'string' 'Plot limit (uV)'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erpparams.ylim) 'tag' 'ylim' } ...
        {} {'style' 'checkbox'   'string' '' 'value' plotconditions 'enable' enablecond  'tag' 'plotconditions' } ...
        {'style' 'text'       'string' 'Plot conditions on the same panel' 'enable' enablecond } ...
        {} {'style' 'checkbox'   'string' '' 'value' plotgroups 'enable' enablegroup 'tag' 'plotgroups' } ...
        {'style' 'text'       'string' 'Plot groups on the same panel' 'enable' enablegroup } ...
        {} ...
        {'style' 'text'       'string' 'Statistics'} ...
        {'style' 'popupmenu'  'string' 'Parametric|Permutations' 'tag' 'statistics' 'value' statval 'listboxtop' statval } ...
        {'style' 'text'       'string' 'Threshold'} ...
        {'style' 'edit'       'string' threshstr 'tag' 'threshold' } ...
        {} {'style' 'checkbox'   'string' '' 'value' statcond  'enable' enablecond  'tag' 'statcond' } ...
        {'style' 'text'       'string' 'Compute condition statistics' 'enable' enablecond} ...
        {} {'style' 'checkbox'   'string' '' 'value' statgroup 'enable' enablegroup 'tag' 'statgroup' } ...
        {'style' 'text'       'string' 'Compute group statistics' 'enable' enablegroup } };
    
    geometry = { [ 1 1 1 1] [0.1 0.1 1] [0.1 0.1 1] [1] [1 1 1 1] [0.1 0.1 1] [0.1 0.1 1] };
    
    [out_param userdat tmp res] = inputgui( 'geometry' , geometry, 'uilist', uilist, ...
                                   'helpcom', 'pophelp(''std_erpparams'')', ...
                                   'title', 'Set parameters for plotting ERPs -- pop_erpparams()');

    if isempty(res), return; end;
    
    % decode inputs
    % -------------
    if res.plotgroups & res.plotconditions, warndlg2('Both conditions and group cannot be plotted on the same panel'); return; end;
    if res.statgroup, res.statgroup = 'on'; else res.statgroup = 'off'; end;
    if res.statcond , res.statcond  = 'on'; else res.statcond  = 'off'; end;
    if res.plotgroups, res.plotgroups = 'together'; else res.plotgroups = 'apart'; end;
    if res.plotconditions , res.plotconditions  = 'together'; else res.plotconditions  = 'apart'; end;
    res.timerange = str2num( res.timerange );
    res.ylim      = str2num( res.ylim );
    res.threshold = str2num( res.threshold );
    if isempty(res.threshold),res.threshold = NaN; end;
    if res.statistics == 1, res.statistics  = 'param'; 
    else                    res.statistics  = 'perm'; 
    end;
    
    % build command call
    % ------------------
    options = {};
    if ~strcmpi( res.plotgroups, STUDY.etc.erpparams.plotgroups), options = { options{:} 'plotgroups' res.plotgroups }; end;
    if ~strcmpi( res.plotconditions , STUDY.etc.erpparams.plotconditions ), options = { options{:} 'plotconditions'  res.plotconditions  }; end;
    if ~strcmpi( res.statgroup, STUDY.etc.erpparams.statgroup), options = { options{:} 'statgroup' res.statgroup }; end;
    if ~strcmpi( res.statcond , STUDY.etc.erpparams.statcond ), options = { options{:} 'statcond'  res.statcond  }; end;
    if ~strcmpi( res.statistics, STUDY.etc.erpparams.statistics ), options = { options{:} 'statistics' res.statistics }; end;
    if ~isequal(res.ylim     , STUDY.etc.erpparams.ylim),      options = { options{:} 'ylim' res.ylim      }; end;
    if ~isequal(res.timerange, STUDY.etc.erpparams.timerange), options = { options{:} 'timerange' res.timerange }; end;
    if isnan(res.threshold) & ~isnan(STUDY.etc.erpparams.threshold) | ...
            ~isnan(res.threshold) & isnan(STUDY.etc.erpparams.threshold) | ...
                ~isnan(res.threshold) & res.threshold ~= STUDY.etc.erpparams.threshold
                options = { options{:} 'threshold' res.threshold }; 
    end;
    if ~isempty(options)
        STUDY = pop_erpparams(STUDY, options{:});
        com = sprintf('STUDY = pop_erpparams(STUDY, %s);', vararg2str( options ));
    end;
else
    if strcmpi(varargin{1}, 'default')
        STUDY = default_params(STUDY);
    else
        for index = 1:2:length(varargin)
            STUDY.etc.erpparams = setfield(STUDY.etc.erpparams, varargin{index}, varargin{index+1});
        end;
    end;
end;

% scan clusters and channels to remove erpdata info if timerange has changed
% ----------------------------------------------------------
if ~isequal(STUDY.etc.erpparams.timerange, TMPSTUDY.etc.erpparams.timerange)
    if isfield(STUDY.cluster, 'erpdata')
        for index = 1:length(STUDY.cluster)
            STUDY.cluster(index).erpdata  = [];
            STUDY.cluster(index).erptimes = [];
        end;
    end;
    if isfield(STUDY.changrp, 'erpdata')
        for index = 1:length(STUDY.changrp)
            STUDY.changrp(index).erpdata  = [];
            STUDY.changrp(index).erptimes = [];
        end;
    end;
end;

function STUDY = default_params(STUDY)
    if ~isfield(STUDY.etc, 'erpparams'), STUDY.etc.erpparams = []; end;
    if ~isfield(STUDY.etc.erpparams, 'timerange'),  STUDY.etc.erpparams.timerange = []; end;
    if ~isfield(STUDY.etc.erpparams, 'ylim'     ),  STUDY.etc.erpparams.ylim      = []; end;
    if ~isfield(STUDY.etc.erpparams, 'statistics'), STUDY.etc.erpparams.statistics = 'param'; end;
    if ~isfield(STUDY.etc.erpparams, 'statgroup'),  STUDY.etc.erpparams.statgroup = 'off'; end;
    if ~isfield(STUDY.etc.erpparams, 'statcond' ),  STUDY.etc.erpparams.statcond  = 'off'; end;
    if ~isfield(STUDY.etc.erpparams, 'threshold' ), STUDY.etc.erpparams.threshold = NaN; end;
    if ~isfield(STUDY.etc.erpparams, 'plotgroups') , STUDY.etc.erpparams.plotgroups = 'apart'; end;
    if ~isfield(STUDY.etc.erpparams, 'naccu') ,     STUDY.etc.erpparams.naccu     = []; end;
    if ~isfield(STUDY.etc.erpparams, 'plotconditions') ,  STUDY.etc.erpparams.plotconditions  = 'apart'; end;

