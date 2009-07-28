% std_chantopo() - plot ERP/spectral/ERSP topoplot at a specific
%                  latency/frequency. 
% Usage:
%          >> std_chantopo( data, 'key', 'val', ...)
% Inputs:
%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to plot mean ERPs from a STUDY 
%           for epochs of 800 frames in two conditions from three groups 
%           of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> std_chantopo(erp_ms,data);
%
%           By default, parametric statistics are computed across subjects 
%           in the three groups. (group,condition) ERP averages are plotted. 
%           See below and >> help statcond 
%           for more information about the statistical computations.
%
% Optional display parameters:
%  'datatype'    - ['erp'|'spec'] data type {default: 'erp'}
%  'channels'    - [cell array] channel names (for titles) {default: all}
%  'condnames'   - [cell array] names of conditions (for titles} 
%                  {default: none}
%  'groupnames'  - [cell array] names of subject groups (for titles)
%                  {default: none}
%  'subject'     - [string] plot subject name (for title)
%
% Statistics options:
%  'groupstats'  - [cell] One p-value array per group {default: {}}
%  'condstats'   - [cell] One p-value array per condition {default: {}}
%  'interstats'  - [cell] Interaction p-value arrays {default: {}}
%  'threshold'   - [NaN|real<<1] Significance threshold. NaN -> plot the 
%                  p-values themselves on a different figure. When possible, 
%                  significance regions are indicated below the data.
%                  {default: NaN}
%
% Curve plotting options (ERP and spectrum):
%  'plotgroups'  - ['together'|'apart'] 'together' -> plot mean results 
%                  for subject groups in the same figure panel in different 
%                  colors. 'apart' -> plot group results on different figure
%                  panels {default: 'apart'}
%  'plotconditions' - ['together'|'apart'] 'together' -> plot mean results 
%                  for data conditions on the same figure panel in different 
%                  colors. 'apart' -> plot conditions on different figure
%                  panel. Note: 'plotgroups' and 'plotconditions' arguments 
%                  cannot both be 'together' {default: 'apart'}
%  'legend'      - ['on'|'off'] turn plot legend on/off {default: 'off'}
%  'plotmode'    - ['normal'|'condensed'] statistics plotting mode:
%                  'condensed' -> plot statistics under the curves 
%                  (when possible); 'normal' -> plot them in separate 
%                  axes {default: 'normal'}
% 'plotsubjects' - ['on'|'off'] overplot traces for individual components
%                  or channels {default: 'off'}
% 'ylim'         - [min max] ordinate limits for ERP and spectrum plots
%                  {default: all available data}
%
% Scalp map plotting options:
%  'chanlocs'    - [struct] channel location structure
%
% Author: Arnaud Delorme, CERCO, CNRS, 2006-
%
% See also: pop_erspparams(), pop_erpparams(), pop_specparams(), statcond()

% $Log: not supported by cvs2svn $
% Revision 1.2  2008/03/30 12:04:11  arno
% fix minor problem (title...)
%
% Revision 1.1  2007/01/26 18:08:17  arno
% Initial revision
%
% Revision 1.24  2006/11/23 00:26:22  arno
% cosmetic change
%
% Revision 1.23  2006/11/22 20:22:38  arno
% filter if necessary
%
% Revision 1.22  2006/11/22 19:34:22  arno
% empty plot
%
% Revision 1.21  2006/11/16 00:07:31  arno
% fix title for topoplot
%
% Revision 1.20  2006/11/15 21:58:49  arno
% plotting titles
%
% Revision 1.19  2006/11/09 23:55:18  arno
% fix last change
%
% Revision 1.18  2006/11/09 23:27:11  arno
% figure titles
%
% Revision 1.17  2006/11/09 23:21:21  arno
% add component name
%
% Revision 1.16  2006/11/09 22:04:39  arno
% ERSP plotting
%
% Revision 1.15  2006/11/03 03:01:17  arno
% allow plotting specific time-freq point
%
% Revision 1.14  2006/11/02 22:14:15  arno
% g. -> opt.
%
% Revision 1.13  2006/11/02 22:13:04  arno
% Limit to ERSP
%
% Revision 1.12  2006/11/02 21:59:18  arno
% input option
%
% Revision 1.11  2006/11/02 21:54:51  arno
% same
%
% Revision 1.10  2006/11/02 21:53:06  arno
% condstats -> condstat
%
% Revision 1.9  2006/10/10 23:50:54  scott
% replaced ?? defaults with defaults from finputcheck()
%
% Revision 1.8  2006/10/09 23:51:45  scott
% some more help edits
%
% Revision 1.7  2006/10/04 23:55:34  toby
% Bug fix courtesy Bas de Kruif
%
% Revision 1.6  2006/10/03 21:46:11  scott
% edit help msg -- ?? remain... -sm
%
% Revision 1.5  2006/10/03 16:29:27  scott
% edit
%
% Revision 1.4  2006/10/03 16:24:12  scott
% help message eidts.  ARNO - SEE ??s   -sm
%
% Revision 1.3  2006/10/02 11:41:13  arno
% wrote documentation
%
% Copyright (C) 2006 Arnaud Delorme
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

function std_chantopo(data, varargin)

pgroup = [];
pcond  = [];
pinter = [];
if nargin < 2
    help std_chantopo;
    return;
end;

opt = finputcheck( varargin, { 'channels'    'cell'   []              {};
                               'ylim'        'real'   []              [];
                               'filter'      'real'   []              [];
                               'condnames'   'cell'   []              {};
                               'groupnames'  'cell'   []              {};
                               'compinds'    'cell'   []              {};
                               'threshold'   'real'   []              NaN;
                               'mcorrect'    'string'  { 'none' 'fdr' } 'none';
                               'topovals'    'string'   []            ''; % same as above
                               'naccu'       'integer' []             500;
                               'unitx'       'string' []              'ms'; % just for titles
                               'subject'     'string' []              '';   % just for titles
                               'chanlocs'    'struct' []              struct('labels', {});
                               'plotsubjects' 'string' { 'on' 'off' }  'off';
                               'groupstats'   'cell'   []              {};
                               'condstats'    'cell'   []              {};
                               'interstats'   'cell'   []              {};
                               'plottopo'     'string' { 'on' 'off' }   'off';
                               'legend'      'string' { 'on' 'off' }   'off';
                               'datatype'    'string' { 'ersp' 'itc' 'erp' 'spec' }    'erp';
                               'plotmode'    'string' { 'normal' 'condensed' }  'normal';
                               'statistics'  'string' { 'param' 'perm' }       'param';
                               'caxis'       'real'   []              [];
                               'statmode'    'string' { 'subjects' 'common' 'trials' } 'subjects'}, 'std_chanplot', 'ignore');
if isstr(opt), error(opt); end;
opt.singlesubject = 'off';
if strcmpi(opt.plottopo, 'on') & size(data{1},3) == 1, opt.singlesubject = 'on'; end;
if size(data{1},2) == 1,                               opt.singlesubject = 'on'; end;
if strcmpi(opt.singlesubject, 'on'), opt.groupstats = {}; opt.condstats = {}; end;
if ~isempty(opt.compinds), if length(opt.compinds{1}) > 1, opt.compinds = {}; end; end;
if strcmpi(opt.datatype, 'spec'), opt.unitx = 'Hz'; end;
onecol  = { 'b' 'b' 'b' 'b' 'b' 'b' 'b' 'b' 'b' 'b' };
manycol = { 'b' 'r' 'g' 'k' 'c' 'y' };

nc = size(data,1);
ng = size(data,2);
if nc >= ng, opt.transpose = 'on';
else         opt.transpose = 'off';
end;
if isempty(opt.condnames)
    for c=1:nc, opt.condnames{c} = sprintf('Cond. %d', c); end;
    if nc == 1, opt.condnames = { '' }; end;
end;
if isempty(opt.groupnames)
    for g=1:ng, opt.groupnames{g} = sprintf('Group. %d', g); end;
    if ng == 1, opt.groupnames = { '' }; end;
end;

% plotting paramters
% ------------------
if ng > 1 & ~isempty(opt.groupstats), addc = 1; else addc = 0; end;
if nc > 1 & ~isempty(opt.condstats ), addr = 1; else addr = 0; end;

% compute significance mask
% --------------------------
if ~isempty(opt.interstats), pinter = opt.interstats{3}; end;

if ~isnan(opt.threshold) & ( ~isempty(opt.groupstats) | ~isempty(opt.condstats) )    
    % applying threshold
    % ------------------
    if strcmpi(opt.mcorrect, 'fdr'), 
        disp('Applying FDR correction for multiple comparisons');
        for ind = 1:length(opt.condstats),  [ tmp pcondplot{ ind}] = fdr(opt.condstats{ind} , opt.threshold); end;
        for ind = 1:length(opt.groupstats), [ tmp pgroupplot{ind}] = fdr(opt.groupstats{ind}, opt.threshold); end;
        if ~isempty(pinter), [tmp pinterplot] = fdr(pinter, opt.threshold); end;
    else
        for ind = 1:length(opt.condstats),  pcondplot{ind}  = opt.condstats{ind}  < opt.threshold; end;
        for ind = 1:length(opt.groupstats), pgroupplot{ind} = opt.groupstats{ind} < opt.threshold; end;
        if ~isempty(pinter), pinterplot = pinter < opt.threshold; end;
    end;
    maxplot = 1;
else
    if strcmpi(opt.mcorrect, 'fdr'), 
        disp('Applying FDR correction for multiple comparisons');
        for ind = 1:length(opt.condstats), opt.condstats{ind} = fdr( opt.condstats{ind} ); end;
        for ind = 1:length(opt.groupstats), opt.groupstats{ind} = fdr( opt.groupstats{ind} ); end;
        if ~isempty(pinter), pinter = fdr(pinter); end;
    end;
    warning off;
    for ind = 1:length(opt.condstats),  pcondplot{ind}  = -log10(opt.condstats{ind}); end;
    for ind = 1:length(opt.groupstats), pgroupplot{ind} = -log10(opt.groupstats{ind}); end;
    if ~isempty(pinter), pinterplot = -log10(pinter); end;
    maxplot = 3;
    warning on;
end;

% plotting all conditions
% -----------------------
ngplot = ng;
ncplot = nc;

% adjust figure size
% ------------------
figure('color', 'w');
pos = get(gcf, 'position');
basewinsize = 200/max(nc,ng)*3;
pos(3) = 200*(ng+addc);
pos(4) = 200*(nc+addr);
if strcmpi(opt.transpose, 'on'), set(gcf, 'position', [ pos(1) pos(2) pos(4) pos(3)]);
else                             set(gcf, 'position', pos);
end;

% topoplot
% --------
tmpc = [inf -inf];
for c = 1:nc
    for g = 1:ng
        hdl(c,g) = mysubplot(nc+addr, ng+addc, g + (c-1)*(ng+addc), opt.transpose);
        if isempty(opt.condnames{c}) & isempty(opt.groupnames{g}) 
            fig_title = [ opt.topovals];
        elseif isempty(opt.condnames{c}) | isempty(opt.groupnames{g}) 
            fig_title = [ opt.condnames{c} opt.groupnames{g} ', ' opt.topovals];
        else fig_title = [ opt.condnames{c} ', ' opt.groupnames{g} ', ' opt.topovals];
        end;

        tmpplot = double(mean(data{c,g},3));
        topoplot( tmpplot, opt.chanlocs, 'style', 'map', 'shading', 'interp');
        title(fig_title); 
        if isempty(opt.caxis)
            tmpc = [ min(min(tmpplot), tmpc(1)) max(max(tmpplot), tmpc(2)) ];
        else 
            caxis(opt.caxis);
        end;

        % statistics accross groups
        % -------------------------
        if g == ng & ng > 1 & ~isempty(opt.groupstats)
            hdl(c,g+1) = mysubplot(nc+addr, ng+addc, g + 1 + (c-1)*(ng+addc), opt.transpose);
            topoplot( pgroupplot{c}, opt.chanlocs);
            if isnan(opt.threshold), title(sprintf('%s (p-value)', opt.condnames{c}));
            else                     title(sprintf('%s (p<%.4f)',  opt.condnames{c}, opt.threshold));
            end;
            caxis([-maxplot maxplot]);
        end;
    end;
end;
        
% color scale
% -----------
if isempty(opt.caxis)
    for c = 1:nc
        for g = 1:ng
            axes(hdl(c,g));
            caxis(tmpc);
        end;
    end;
end;

for g = 1:ng
    % statistics accross conditions
    % -----------------------------
    if ~isempty(opt.condstats) & nc > 1
        hdl(nc+1,g) = mysubplot(nc+addr, ng+addc, g + c*(ng+addc), opt.transpose);
        topoplot( pcondplot{g}, opt.chanlocs);
        if all(pcondplot{g} == 0)
            fprintf('Debug note: the text [-1 1] is returned in topoplot() when the input contains only 0s; could not find where though -Arno, 2007\n');
        end;
        if isnan(opt.threshold), title(sprintf('%s (p-value)', opt.groupnames{g}));
        else                     title(sprintf('%s (p<%.4f)',  opt.groupnames{g}, opt.threshold));
        end;
        caxis([-maxplot maxplot]);
    end;
end;

% statistics accross group and conditions
% ---------------------------------------
if ~isempty(opt.condstats) & ~isempty(opt.groupstats) & ng > 1 & nc > 1
    hdl(nc+1,ng+1) = mysubplot(nc+addr, ng+addc, g + 1 + c*(ng+addr), opt.transpose);
    topoplot( pinterplot, opt.chanlocs);
    if isnan(opt.threshold), title('Interaction (p-value)');
    else                     title(sprintf('Interaction (p<%.4f)', opt.threshold));
    end;
    caxis([-maxplot maxplot]);
end;    

% color bars
% ----------
axes(hdl(nc,ng)); 
cbar_standard(opt.datatype, ng);
if nc ~= size(hdl,1) | ng ~= size(hdl,2)
    axes(hdl(end,end));
    cbar_signif(ng, maxplot);
end;

% remove axis labels
% ------------------
for c = 1:size(hdl,1)
    for g = 1:size(hdl,2)
        if g ~= 1 & size(hdl,2) ~=1, ylabel(''); end;
        if c ~= size(hdl,1) & size(hdl,1) ~= 1, xlabel(''); end;
    end;
end;

% colorbar for ERSP and scalp plot
% --------------------------------
function cbar_standard(datatype, ng);
    pos = get(gca, 'position');
    tmpc = caxis;
    fact = fastif(ng == 1, 40, 20);
    tmp = axes('position', [ pos(1)+pos(3)+pos(3)/fact pos(2) pos(3)/fact pos(4) ]);  
    set(gca, 'unit', 'normalized');
    if strcmpi(datatype, 'itc')
         cbar(tmp, 0, tmpc, 10); ylim([0.5 1]);
    else cbar(tmp, 0, tmpc, 5);
    end;

% colorbar for significance
% -------------------------
function cbar_signif(ng, maxplot);
    pos = get(gca, 'position');
    tmpc = caxis;
    fact = fastif(ng == 1, 40, 20);
    tmp = axes('position', [ pos(1)+pos(3)+pos(3)/fact pos(2) pos(3)/fact pos(4) ]);  
    map = colormap;
    n = size(map,1);
    cols = [ceil(n/2):n]';
    image([0 1],linspace(0,maxplot,length(cols)),[cols cols]);
    %cbar(tmp, 0, tmpc, 5);
    tick = linspace(0, maxplot, maxplot+1);
    set(gca, 'ytickmode', 'manual', 'YAxisLocation', 'right', 'xtick', [], ...
        'ytick', tick, 'yticklabel', round(10.^-tick*1000)/1000);
    xlabel('');

% mysubplot (allow to transpose if necessary)
% -------------------------------------------
function hdl = mysubplot(nr,nc,ind,transp);

    r = ceil(ind/nc);
    c = ind -(r-1)*nc;
    if strcmpi(transp, 'on'), hdl = subplot(nc,nr,(c-1)*nr+r);
    else                      hdl = subplot(nr,nc,(r-1)*nc+c);
    end;

