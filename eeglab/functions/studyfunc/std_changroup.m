% std_changroup() - Create channel groups for plotting.
%
% Usage:    
%                >> STUDY = std_changroup(STUDY, ALLEEG);   
% Inputs:
%   ALLEEG     - Top-level EEGLAB vector of loaded EEG structures for the dataset(s) 
%                in the STUDY. ALLEEG for a STUDY set is typically loaded using 
%                pop_loadstudy(), or in creating a new STUDY, using pop_createstudy().  
%   STUDY      - EEGLAB STUDY set comprising some or all of the EEG datasets in ALLEEG.
%
% Outputs:
%   STUDY      - The input STUDY set structure modified according to specified user 
%                edits, if any. The STUDY.changrp structure is created. It contains as
%                many elements as there are channels. For example, STUDY.changrp(1)
%                is the first channel. Fields of the changrp structure created at this
%                point are 
%                    STUDY.changrp.name      : name of the channel group
%                    STUDY.changrp.channels  : cell array containing channel labels
%                                              for the group.
%                    STUDY.changrp.setinds   : indices of datasets containing the
%                                              selected channels.
%                    STUDY.changrp.allinds   : indices of channels within the datasets 
%                                              above.
%
% Authors: Arnaud Delorme, CERCO, 2006

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, CERCO, arno@salk.edu
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
% Revision 1.11  2007/08/13 21:17:00  arno
% fix previous changes
%
% Revision 1.10  2007/08/13 21:13:53  arno
% fix typo
%
% Revision 1.9  2007/08/13 21:12:40  arno
% fix error message
%
% Revision 1.8  2007/08/13 18:28:31  arno
% header
%
% Revision 1.7  2007/08/13 17:42:52  arno
% update help message
%
% Revision 1.6  2007/07/30 21:56:02  arno
% debug for missing conditions
%
% Revision 1.5  2007/01/26 18:04:08  arno
% backup code at the end
%
% Revision 1.4  2006/12/08 19:41:51  arno
% same
%
% Revision 1.3  2006/12/08 19:40:49  arno
% error for duplicate channel label
%
% Revision 1.2  2006/11/15 22:55:46  arno
% last channel problem
%
% Revision 1.1  2006/09/12 18:45:16  arno
% Initial revision
%

function STUDY = std_changroup(STUDY, ALLEEG);

% union of all channel structures
% -------------------------------
alllocs = ALLEEG(STUDY.datasetinfo(1).index).chanlocs;
alllabs = { alllocs.labels };
for index = 2:length(STUDY.datasetinfo)
   tmplocs = ALLEEG(STUDY.datasetinfo(index).index).chanlocs;
   tmplocs = orderfields(tmplocs, alllocs); % make fields to have the same order so they can be merged
   alllocs = eeg_mergechan(alllocs, tmplocs);
end;

% create group for each electrode
% -------------------------------
for indc = 1:length(alllocs)
    STUDY.changrp(indc).name = [ alllocs(indc).labels ];
    STUDY.changrp(indc).channels = { alllocs(indc).labels };
    tmp = std_chanlookupnew( STUDY, ALLEEG, STUDY.changrp(indc));
    STUDY.changrp(indc).setinds = tmp.setinds;
    STUDY.changrp(indc).allinds = tmp.allinds;
    STUDY.changrp(indc).centroid = [];
end;


%STUDY.changrp(indc).name = [ 'full montage' ];
%STUDY.changrp(indc).channels = { alllocs.labels };
%tmp = std_chanlookup( STUDY, ALLEEG, STUDY.changrp(indc));
%STUDY.changrp(indc).chaninds = tmp.chaninds;
return; 
    
% find datasets and channel indices
% ---------------------------------
function changrp = std_chanlookupnew( STUDY, ALLEEG, changrp);

    nc = max(length(STUDY.condition),1);
    ng = max(length(STUDY.group),1);
    changrp.allinds = cell( nc, ng );
    changrp.setinds = cell( nc, ng );
    for index = 1:length(STUDY.datasetinfo)
        condind = strmatch( STUDY.datasetinfo(index).condition, STUDY.condition, 'exact');
        grpind  = strmatch( STUDY.datasetinfo(index).group    , STUDY.group    , 'exact');
        datind  = STUDY.datasetinfo(index).index;
        tmplocs = { ALLEEG(datind).chanlocs.labels };
        
        if ( isempty(condind) & ~isempty(STUDY.condition) ) | (isempty(grpind) & ~isempty(STUDY.group) ) 
            fprintf( [ 'Important warning: Dataset %d has a group and condition that is\nnot in the STUDY.condition ' ...
                             'and STUDY.group structure. This must be fixed.' ], STUDY.datasetinfo(index).index);
        else
            if isempty(STUDY.condition), condind = 1; end;
            if isempty(STUDY.group),     grpind  = 1; end;
                
            % scan all channel labels
            % -----------------------
            for indc = 1:length(changrp.channels) % usually just one channel
                ind = strmatch( changrp.channels(indc), tmplocs, 'exact');
                if length(ind) > 1, error([ 'Duplicate channel label ''' tmplocs{ind(1)} ''' for dataset ' int2str(datind) ]); end;
                if ~isempty(ind)
                    changrp.allinds{ condind, grpind } = [ changrp.allinds{ condind, grpind } ind ];
                    changrp.setinds{ condind, grpind } = [ changrp.setinds{ condind, grpind } datind ];
                end;
            end;
        end;
    end;
    
    return; 
    
% ---------------
% old channel look-up
% ---------------
function changrp = std_chanlookup( STUDY, ALLEEG, changrp);

    changrp.chaninds = [];
    changrp.chaninds = zeros(size(STUDY.setind));
    for ir = 1:size(STUDY.setind,1)
        for ic = 1:size(STUDY.setind,2)
            datind  = STUDY.setind(ir,ic);
            if ~isnan(datind)
                tmplocs = { ALLEEG(STUDY.datasetinfo(datind).index).chanlocs.labels };
                
                for indc = 1:length(changrp.channels)
                    ind = strmatch( changrp.channels(indc), tmplocs, 'exact');
                    if length(ind) > 1, error([ 'Duplicate channel label ''' tmplocs{ind(1)} ''' for dataset ' int2str(datind) ]); end;
                    if ~isempty(ind)
                        changrp.chaninds(ir,ic) = ind;
                    end;
                end;
            end;
        end;    
    end;
    
    return; 
    
