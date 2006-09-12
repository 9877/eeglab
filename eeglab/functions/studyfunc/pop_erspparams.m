% std_erspplot() - plotting and statistics option for ERSP and ITC.
%
% Usage:    
%   >> STUDY = std_erspplot(STUDY, 'key', 'val');   
%
% Inputs:
%   STUDY      - EEGLAB STUDY set comprising some or all of the EEG
%
% Optional inputs:
% To be documented...
%
% See also: std_erspplot()
%
% Authors: Arnaud Delorme, CERCO, CNRS, 2006-

% Copyright (C) Arnaud Delorme, arno@salk.edu
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

function [ STUDY com ] = pop_erspparams(STUDY, varargin);

STUDY = default_params(STUDY);
TMPSTUDY = STUDY;
com = '';
if isempty(varargin)
    
    enablegroup = fastif(length(STUDY.group)>1, 'on', 'off');
    enablecond  = fastif(length(STUDY.condition)>1, 'on', 'off');
    threshstr   = fastif(isnan(STUDY.etc.erspparams.threshold),'', num2str(STUDY.etc.erspparams.threshold));
    statval     = fastif(strcmpi(STUDY.etc.erspparams.statistics,'param'), 1, 2);
    statmode    = fastif(strcmpi(STUDY.etc.erspparams.statmode,'individual'), 1, 2);
    subbaseline = fastif(strcmpi(STUDY.etc.erspparams.subbaseline,'on'), 1, 0);
    statcond    = fastif(strcmpi(STUDY.etc.erspparams.statcond, 'on'), 1, 0);
    statgroup   = fastif(strcmpi(STUDY.etc.erspparams.statgroup,'on'), 1, 0);
    maskdata    = fastif(strcmpi(STUDY.etc.erspparams.maskdata,'on'), 1, 0);
    cb_maskdata = [ 'tmpcond  = get(findobj(gcbf, ''tag'', ''statcond'') , ''value'');' ...
                    'tmpgroup = get(findobj(gcbf, ''tag'', ''statgroup''), ''value'');' ...
                    'tmpplot  = get(findobj(gcbf, ''tag'', ''maskdata'') , ''value'');' ...
                    'if tmpcond & tmpgroup & tmpplot,' ...
                    '    warndlg2(strvcat(''Cannot mask time/freq. image if both statistics for conditions'',' ...
                    '           ''and statistics for groups are used.''));' ...
                    '    set(gcbo, ''value'', 0);' ...
                    'end;' ...
                    'clear tmpcond tmpgroup tmpplot;' ];
    
    uilist = { ...
        {'style' 'text'       'string' 'Time range (ms)'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.timerange) 'tag' 'timerange' } ...
        {'style' 'text'       'string' 'Power limit (dB)'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.ersplim) 'tag' 'ersplim' } ...
        {'style' 'text'       'string' 'Freq range (Hz)'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.freqrange) 'tag' 'freqrange' } ...
        {'style' 'text'       'string' 'ITC limit (0-1)'} ...
        {'style' 'edit'       'string' num2str(STUDY.etc.erspparams.itclim) 'tag' 'itclim' } ...
        {} {'style' 'checkbox'   'string' '' 'value' subbaseline 'tag' 'subbaseline' } ...
        {'style' 'text'       'string' 'Compute baseline accross conditions for ERSP' } ...
        {} ...
        {'style' 'text'       'string' 'Statistics'} ...
        {'style' 'popupmenu'  'string' 'Parametric|Permutations' 'tag' 'statistics' 'value' statval 'listboxtop' statval } ...
        {'style' 'text'       'string' 'Threshold'} ...
        {'style' 'edit'       'string' threshstr 'tag' 'threshold' } ...
        {'style' 'text'       'string' 'Data for statistics'} ...
        {'style' 'popupmenu'  'string' 'Use mean|Use trials' 'tag' 'statmode' 'value' statmode 'listboxtop' statmode } ...
        { } { } ...
        {} {'style' 'checkbox'   'string' '' 'value' statcond  'enable' enablecond  'tag' 'statcond' 'callback' cb_maskdata } ...
        {'style' 'text'       'string' 'Compute condition statistics' 'enable' enablecond} ...
        {} {'style' 'checkbox'   'string' '' 'value' statgroup 'enable' enablegroup 'tag' 'statgroup' 'callback' cb_maskdata } ...
        {'style' 'text'       'string' 'Compute group statistics' 'enable' enablegroup } ...
        {} {'style' 'checkbox'   'string' '' 'value' maskdata 'tag' 'maskdata' 'callback' cb_maskdata } ...
        {'style' 'text'       'string' 'Use statistics to mask data' } };
    
    geometry = { [ 1 1 1 1] [ 1 1 1 1] [0.1 0.1 1] [1] [1 1 1 1] [1 1 1 1] [0.1 0.1 1] [0.1 0.1 1] [0.1 0.1 1] };
    
    [out_param userdat tmp res] = inputgui( 'geometry' , geometry, 'uilist', uilist, ...
                                   'helpcom', 'pophelp(''std_erspparams'')', ...
                                   'title', 'Set parameters for plotting ERPs -- pop_erspparams()');

    if isempty(res), return; end;
    
    % decode inputs
    % -------------
    if res.statgroup, res.statgroup = 'on'; else res.statgroup = 'off'; end;
    if res.statcond , res.statcond  = 'on'; else res.statcond  = 'off'; end;
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
    if res.statmode   == 1, res.statmode    = 'individual'; 
    else                    res.statmode    = 'trials'; 
    end;
    
    % build command call
    % ------------------
    options = {};
    if ~strcmpi( res.statgroup, STUDY.etc.erspparams.statgroup), options = { options{:} 'statgroup' res.statgroup }; end;
    if ~strcmpi( res.statcond , STUDY.etc.erspparams.statcond ), options = { options{:} 'statcond'  res.statcond  }; end;
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

% scan clusters and channels to remove erpdata info if timerange has changed
% ----------------------------------------------------------
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
    if ~isfield(STUDY.etc.erspparams, 'statgroup'),    STUDY.etc.erspparams.statgroup = 'off'; end;
    if ~isfield(STUDY.etc.erspparams, 'statcond' ),    STUDY.etc.erspparams.statcond  = 'off'; end;
    if ~isfield(STUDY.etc.erspparams, 'subbaseline' ), STUDY.etc.erspparams.subbaseline = 'on'; end;
    if ~isfield(STUDY.etc.erspparams, 'threshold' ),   STUDY.etc.erspparams.threshold = NaN; end;
    if ~isfield(STUDY.etc.erspparams, 'maskdata') ,    STUDY.etc.erspparams.maskdata  = 'on'; end;
    if ~isfield(STUDY.etc.erspparams, 'statmode') ,    STUDY.etc.erspparams.statmode  = 'individual'; end;

