% std_toporead() - Command line function to read cluster component and scalp maps. 
%                  This function automatically invert the polarity of scalp
%                  maps so they best match the polarity of the mean scalp map.
% Usage:    
%              >> [STUDY clsstruct] = std_toporead(STUDY, ALLEEG, cls);  
% Inputs:
%   STUDY      - EEGLAB STUDY set comprising some or all of the EEG datasets in ALLEEG.
%   ALLEEG     - global EEGLAB vector of EEG structures for the dataset(s) included in 
%                the STUDY. 
%   cls        - specific cluster numbers to read.
%
% Outputs:
%   STUDY      - the input STUDY set structure modified with read cluster scalp
%                map means, to allow quick replotting (unless clusters means 
%                already exists in the STUDY).  
%   clsstruct  - structure of the modified clusters.
%
% See also  std_topoplot(), pop_clustedit()
%
% Authors:  Arnaud Delorme, SCCN, INC, UCSD, 2007

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, June 07, 2007, arno@sccn.ucsd.edu
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

function [STUDY, centroid] = std_toporead(STUDY,ALLEEG, clsind);

if isempty(clsind)
    for k = 2: length(STUDY.cluster) %don't include the ParentCluster
         if ~strncmpi('Notclust',STUDY.cluster(k).name,8) 
             % don't include 'Notclust' clusters
             clsind = [clsind k];
         end
    end
end

 Ncond = length(STUDY.condition);
if Ncond == 0
    Ncond = 1;
end 
centroid = cell(length(clsind),1);
fprintf('centroid (only done once)\n');

for clust = 1:length(clsind) %go over all requested clusters
    for cond = 1 %compute for all conditions
        if clsind(clust) > 0
             numitems = length(STUDY.cluster(clsind(clust)).comps);
        else numitems = length(STUDY.changrp(-clsind(clust)).chaninds);
        end;

        for k = 1:numitems % go through all components
            comp  = STUDY.cluster(clsind(clust)).comps(k);
            abset = STUDY.cluster(clsind(clust)).sets(cond,k);
            [grid yi xi] = std_readtopo(ALLEEG, abset, comp);
            if ~isfield(centroid{clust}, 'topotmp')
                centroid{clust}.topotmp = zeros([ size(grid(1:4:end),2) numitems ]);
            elseif isempty(centroid{clust}.topotmp)
                centroid{clust}.topotmp = zeros([ size(grid(1:4:end),2) numitems ]);
            end;
            centroid{clust}.topotmp(:,k) = grid(1:4:end); % for inversion
            centroid{clust}.topo{k} = grid;
            centroid{clust}.topox = xi;
            centroid{clust}.topoy = yi;
        end;
        fprintf('\n');
    end;
end

%update STUDY
tmpinds = find(isnan(centroid{clust}.topotmp(:,1)));
centroid{clust}.topotmp(tmpinds,:) = [];
for clust =  1:length(clsind) %go over all requested clusters
    for cond  = 1
        if clsind(1) > 0
            ncomp = length(STUDY.cluster(clsind(clust)).comps);
        end;
        [ tmp pol ] = std_comppol(centroid{clust}.topotmp);
        fprintf('%d/%d polarities inverted while reading ICA component scalp maps\n', length(find(pol == -1)), length(pol));
        nitems = length(centroid{clust}.topo);
        for k = 1:nitems
            if k == 1, allscalp = pol(k)*centroid{clust}.topo{k}/nitems;
            else       allscalp = pol(k)*centroid{clust}.topo{k}/nitems + allscalp;
            end;
        end;
        STUDY.cluster(clsind(clust)).topox   = centroid{clust}.topox;
        STUDY.cluster(clsind(clust)).topoy   = centroid{clust}.topoy;
        STUDY.cluster(clsind(clust)).topoall = centroid{clust}.topo;
        STUDY.cluster(clsind(clust)).topo    = allscalp;
        STUDY.cluster(clsind(clust)).topopol = pol;
    end
end
fprintf('\n');
