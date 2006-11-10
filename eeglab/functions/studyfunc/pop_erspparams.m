% pop_erspparams() - Set plotting and statistics parameters for 
%                    computing and plotting STUDY mean (and optionally 
%                    single-trial) ERSP and ITC measures and measure 
%                    statistics. Settings are stored within the STUDY 
%                    structure (STUDY.etc.erspparams) which is used
%                    whenever plotting is performed by the function
%                    std_specplot().
% Usage:    
%   >> STUDY = pop_erspparams(STUDY, 'key', 'val', ...);   
%
% Inputs:
%   STUDY        - EEGLAB STUDY set
%
% Statistics options:
%  'groupstats'   - ['on'|'off'] Compute statistics across subject 
%                  groups {default: 'off'}
%  'condstats'    - ['on'|'off'] Compute statistics across data 
%                  conditions {default: 'off'}
%  'statistics'  - ['param'|'perm'] Type of statistics to compute: 
%                  'param' for parametric (t-test/anova); 'perm' for 
%                  permutation-based {default: 'param'}
%  'statmode'    - ['subjects'|'trials'] 'subjects' {default}
%                  -> statistics are computed across condition mean 
%                  ERSPs|ITCs of the single subjects. 
%                  'trials' -> single-trial 'ERSP' transforms 
%                  for all subjects are pooled.  This requires that 
%                  they were saved to disk using std_ersp() option 
%                  'savetrials', 'on'. Note, however, that the 
%                  single-trial ERSPs may occupy several GB of disk 
%                  space, and that computation of statistics may 
%                  require a large amount of RAM.
%  'naccu'       - [integer] Number of surrogate data averages to use in
%                  permutation-based statistics. For instance, if p<0.01, 
%                  use naccu>200. For p<0.001, naccu>2000. If a 'threshold'
%                  (not NaN) is set below and 'naccu' is too low, it will
%                  be automatically increased. (This keyword is currently
%                  only modifiable from the command line, not from the gui). 
%  'threshold'   - [NaN|alpha] Significance threshold (0<alpha<<1). Value 
%                  NaN will plot p-values for each time and/or frequency
%                  on a different axis. If alpha is used, significant time
%                  and/or frequency regions will be indicated either on
%                  a separate axis or (whenever possible) along with the
%                  data {default: NaN}
%  'subbaseline' - ['on'|'off'] subtract the same baseline across conditions 
%                  for ERSP (not ITC). When datasets with different conditions
%                  are recorded simultaneously, a common baseline spectrum 
%                  should be used. Note that this also affects the 
%                  results of statistics {default: 'on'}
%  'maskdata'    - ['on'|'off'] when threshold is not NaN, and 'groupstats'
%                  or 'condstats' (above) are 'off', masks the data 
%                  for significance.
%
% ERSP/ITC image plotting options:
%   'timerange'  - [min max] ERSP/ITC plotting latency range in ms. 
%                  {default: the whole output latency range}.
%   'freqrange'  - [min max] ERSP/ITC plotting frequency range in ms. 
%                  {default: the whole output frequency range}
%   'ersplim'    - [mindB maxdB] ERSP plotting limits in dB 
%                  {default: from [ERSPmin,ERSPmax]}
%   'itclim'     - [minitc maxitc] ITC plotting limits (range: [0,1]) 
%                  {default: from [0,ITC data max]}
%
% See also: std_erspplot(), std_itcplot()
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
% Revision 1.7  2006/10/03 21:21:43  scott
% nothing
%
% Revision 1.6  2006/10/03 20:14:21  arno
% removing ??
%
% Revision 1.5  2006/10/03 20:07:02  arno
% more comments
%
% Revision 1.4  2006/10/03 13:57:06  scott
% worked on help msg. ARNO, SEE MANY ?? -sm
%
% Revision 1.3  2006/10/02 11:38:30  arno
% header documentation
%

function [ STUDY, com ] = pop_erspparams(STUDY, varargin);

STUDY = default_params(STUDY);
TMPSTUDY = STUDY;
com = '';
if isempty(varargin)
    
    enablegroup = fastif(length(STUDY.group)>1, 'on', 'off');
    enablecond  = fastif(length(STUDY.condition)>1, 'on', 'off');
    threshstr   = fastif(isnan(STUDY.etc.erspparams.threshold),'', num2str(STUDY.etc.erspparams.threshold));
    statval     = fastif(strcmpi(STUDY.etc.erspparams.statistics,'param'), 1, 2);
    statmode    = fastif(strcmpi(STUDY.etc.erspparams.statmode,'subjects'), 1, 2);
    subbaseline = fastif(strcmpi(STUDY.etc.erspparams.subbaseline,'on'), 1, 0);
    condstats    = fastif(strcmpi(STUDY.etc.erspparams.condstats, 'on'), 1, 0);
    groupstats   = fastif(strcmpi(STUDY.etc.erspparams.groupstats,'on'), 1, 0);
    maskdata    = fastif(strcmpi(STUDY.etc.erspparams.maskdata,'on'), 1, 0);
    cb_maskdata = [ 'tmpcond  = get(findobj(gcbf, ''tag'', ''condstats'') , ''value'');' ...
                    'tmpgroup = get(findobj(gcbf, ''tag'', ''groupstats''), ''value'');' ...
                    'tmpplot  = get(findobj(gcbf, ''tag'', ''maskdata'') , ''value'');' ...
                    'if tmpcond & tmpgroup & tmpplot,' ...
                    '    warndlg2(strvcat(''Cannot mask time/freq. image if both statistics for conditions'',' ...
                    '           ''and statistics for groups are used.''));' ...
                    '    set(gcbo, ''value'', 0);' ...
                    'end;' ...
                    'clear tmpcond tmpgroup tmpplot;' ];
    
    uilist = { ...
        {'style' 'text'       'string' 'Time range in ms [Low High]'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.timerange) 'tag' 'timerange' } ...
        {'style' 'text'       'string' 'Power limits in dB [Low High]'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.ersplim) 'tag' 'ersplim' } ...
        {'style' 'text'       'string' 'Freq. range in Hz [Low High]'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.freqrange) 'tag' 'freqrange' } ...
        {'style' 'text'       'string' 'ITC limit (0-1) [High]'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.itclim) 'tag' 'itclim' } ...
        {} {'style' 'checkbox'   'string' '' 'value' subbaseline 'tag' 'subbaseline' } ...
        {'style' 'text'       'string' 'Compute ERSP baseline accross conditions' } ...
        {} ...
        {'style' 'text'       'string' 'Statistics'} ...
        {'style' 'popupmenu'  'string' 'Parametric|Permutation-based' 'tag' 'statistics' 'value' statval 'listboxtop' statval } ...
        {'style' 'text'       'string' 'Threshold'} ...
        {'style' 'edit'       'string' threshstr 'tag' 'threshold' } ...
        {'style' 'text'       'string' 'Data for statistics'} ...
        {'style' 'popupmenu'  'string' 'Use means|Use trials' 'tag' 'statmode' 'value' statmode 'listboxtop' statmode } ...
        { } { } ...
        {} {'style' 'checkbox'   'string' '' 'value' condstats  'enable' enablecond  'tag' 'condstats' 'callback' cb_maskdata } ...
        {'style' 'text'       'string' 'Compute condition statistics' 'enable' enablecond} ...
        {} {'style' 'checkbox'   'string' '' 'value' groupstats 'enable' enablegroup 'tag' 'groupstats' 'callback' cb_maskdata } ...
        {'style' 'text'       'string' 'Compute group statistics' 'enable' enablegroup } ...
        {} {'style' 'checkbox'   'string' '' 'value' maskdata 'tag' 'maskdata' 'callback' cb_maskdata } ...
        {'style' 'text'       'string' 'Mask non-significant data' } };
    
    geometry = { [ 1 .5 1 .5]  [ 1 .5 1 .5] [0.1 0.1 1] [1] [ 0.7 .8 1 .5] [ 0.7 .8 1 .5] [0.1 0.1 1] [0.1 0.1 1] [0.1 0.1 1] };
    
    [out_param userdat tmp res] = inputgui( 'geometry' , geometry, 'uilist', uilist, ...
                                   'helpcom', 'pophelp(''std_erspparams'')', ...
                                   'title', 'Set ERSP|ITC plotting parameters -- pop_erspparams()');

    if isempty(res), return; end;
    
    % decode input
    % ------------
    if res.groupstats, res.groupstats = 'on'; else res.groupstats = 'off'; end;
    if res.condstats , res.condstats  = 'on'; else res.condstats  = 'off'; end;
    if res.maskdata , res.maskdata  = 'on'; else res.maskdata  = 'off'; end;
    if res.subbaseline, res.subbaseline = 'on'; else res.subbaseline = 'off'; end;
    res.timerange = str2num( res.timerange );
    res.freqrange = str2num( res.freqrange );
    res.ersplim   = str2num( res.ersplim );
    res.itclim    = str2num( res.itclim );
    res.threshold = str2num( res.threshold );
    if isempty(res.threshold),res.threshold = NaN; end;
    if res.statistics == 1, res.statistics  = 'param'; 
    else                    res.statistics  = 'perm'; 
    end;
    if res.statmode   == 1, res.statmode    = 'subjects'; 
    else                    res.statmode    = 'trials'; 
    end;
    
    % build command call
    % ------------------
    options = {};
    if ~strcmpi( res.groupstats, STUDY.etc.erspparams.groupstats), options = { options{:} 'groupstats' res.groupstats }; end;
    if ~strcmpi( res.condstats , STUDY.etc.erspparams.condstats ), options = { options{:} 'condstats'  res.condstats  }; end;
    if ~strcmpi( res.maskdata,  STUDY.etc.erspparams.maskdata ), options = { options{:} 'maskdata'  res.maskdata  }; end;
    if ~strcmpi( res.statmode,  STUDY.etc.erspparams.statmode ), options = { options{:} 'statmode'  res.statmode }; end;
    if ~strcmpi( res.statistics, STUDY.etc.erspparams.statistics ), options = { options{:} 'statistics' res.statistics }; end;
    if ~strcmpi( res.subbaseline , STUDY.etc.erspparams.subbaseline ), options = { options{:} 'subbaseline' res.subbaseline }; end;
    if ~isequal(res.ersplim  , STUDY.etc.erspparams.ersplim),   options = { options{:} 'ersplim'   res.ersplim   }; end;
    if ~isequal(res.itclim   , STUDY.etc.erspparams.itclim),    options = { options{:} 'itclim'    res.itclim    }; end;
    if ~isequal(res.timerange, STUDY.etc.erspparams.timerange), options = { options{:} 'timerange' res.timerange }; end;
    if ~isequal(res.freqrange, STUDY.etc.erspparams.freqrange), options = { options{:} 'freqrange' res.freqrange }; end;
    if isnan(res.threshold) & ~isnan(STUDY.etc.erspparams.threshold) | ...
            ~isnan(res.threshold) & isnan(STUDY.etc.erspparams.threshold) | ...
                ~isnan(res.threshold) & res.threshold ~= STUDY.etc.erspparams.threshold
                options = { options{:} 'threshold' res.threshold }; 
    end;
    if ~isempty(options)
        STUDY = pop_erspparams(STUDY, options{:});
        com = sprintf('STUDY = pop_erspparams(STUDY, %s);', vararg2str( options ));
    end;
else
    if strcmpi(varargin{1}, 'default')
        STUDY = default_params(STUDY);
    else
        for index = 1:2:length(varargin)
            STUDY.etc.erspparams = setfield(STUDY.etc.erspparams, varargin{index}, varargin{index+1});
        end;
    end;
end;

% scan clusters and channels to remove erspdata info if timerange etc. have changed
% ---------------------------------------------------------------------------------
if ~isequal(STUDY.etc.erspparams.timerange, TMPSTUDY.etc.erspparams.timerange) | ... 
    ~isequal(STUDY.etc.erspparams.freqrange, TMPSTUDY.etc.erspparams.freqrange) | ... 
    ~isequal(STUDY.etc.erspparams.statmode, TMPSTUDY.etc.erspparams.statmode) | ...
    ~isequal(STUDY.etc.erspparams.subbaseline, TMPSTUDY.etc.erspparams.subbaseline)
    if isfield(STUDY.cluster, 'erspdata')
        for index = 1:length(STUDY.cluster)
            STUDY.cluster(index).erspdata  = [];
            STUDY.cluster(index).erspbase  = [];
            STUDY.cluster(index).ersptimes = [];
            STUDY.cluster(index).erspfreqs = [];
            STUDY.cluster(index).itcdata  = [];
            STUDY.cluster(index).itctimes = [];
            STUDY.cluster(index).itcfreqs = [];
        end;
    end;
    if isfield(STUDY.changrp, 'erspdata')
        for index = 1:length(STUDY.changrp)
            STUDY.changrp(index).erspdata  = [];
            STUDY.changrp(index).erspbase  = [];
            STUDY.changrp(index).ersptimes = [];
            STUDY.changrp(index).erspfreqs = [];
            STUDY.changrp(index).itcdata  = [];
            STUDY.changrp(index).itctimes = [];
            STUDY.changrp(index).itcfreqs = [];
        end;
    end;
end;

function STUDY = default_params(STUDY)
    if ~isfield(STUDY.etc, 'erspparams'), STUDY.etc.erspparams = []; end;
    if ~isfield(STUDY.etc.erspparams, 'timerange'),    STUDY.etc.erspparams.timerange = []; end;
    if ~isfield(STUDY.etc.erspparams, 'freqrange'),    STUDY.etc.erspparams.freqrange = []; end;
    if ~isfield(STUDY.etc.erspparams, 'ersplim' ),     STUDY.etc.erspparams.ersplim   = []; end;
    if ~isfield(STUDY.etc.erspparams, 'itclim' ),      STUDY.etc.erspparams.itclim    = []; end;
    if ~isfield(STUDY.etc.erspparams, 'statistics'),   STUDY.etc.erspparams.statistics = 'param'; end;
    if ~isfield(STUDY.etc.erspparams, 'groupstats'),    STUDY.etc.erspparams.groupstats = 'off'; end;
    if ~isfield(STUDY.etc.erspparams, 'condstats' ),    STUDY.etc.erspparams.condstats  = 'off'; end;
    if ~isfield(STUDY.etc.erspparams, 'subbaseline' ), STUDY.etc.erspparams.subbaseline = 'on'; end;
    if ~isfield(STUDY.etc.erspparams, 'threshold' ),   STUDY.etc.erspparams.threshold = NaN; end;
    if ~isfield(STUDY.etc.erspparams, 'maskdata') ,    STUDY.etc.erspparams.maskdata  = 'on'; end;
    if ~isfield(STUDY.etc.erspparams, 'naccu')    ,    STUDY.etc.erspparams.naccu     = []; end;
    if ~isfield(STUDY.etc.erspparams, 'statmode') ,    STUDY.etc.erspparams.statmode  = 'subjects'; end;

