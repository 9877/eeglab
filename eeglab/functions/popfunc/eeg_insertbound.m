% eeg_insertbound() - insert boundary event in EEGLAB event structure.
%
% Usage:
%   >> [eventout indold] = eeg_insertbound( eventin, pnts, ...
%                                           latency, abslatency, duration);
%
% Inputs:
%   eventin    - EEGLAB event structure
%   pnts       - data points in EEG dataset
%   latency    - relative latency (in the event structure) of boundary 
%                event(s)
%   abslatency - absolute latency of regions in original dataset. Can
%                also be an array of [beg end] latency with one row
%                per region removed. Then 'lengths' is ignored.
%   duration   - length of removed regions
%
% Outputs:
%   eventout   - EEGLAB event output structure with added boundaries
%   indold     - old event indices (in returned array)
%
% Notes:
%   1) This function performs the following: add boundary events to the 
%   'event' structures; remove nested boundaries.
%   2) all latencies are given in data point unit.
% 
% Author: Arnaud Delorme, SCCN, INC, UCSD, April, 19, 2004
%
% See also: eeg_eegrej(), pop_mergeset()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2004 Arnaud Delorme, SCCN, INC, UCSD, arno@salk.edu
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
% Revision 1.21  2004/06/03 21:24:31  arno
% same
%
% Revision 1.20  2004/06/03 21:22:57  arno
% recomputing boundevent latency
%
% Revision 1.19  2004/06/02 18:21:18  arno
% debuging finding boundary length
%
% Revision 1.18  2004/06/02 17:30:06  arno
% returning index to old event
%
% Revision 1.17  2004/06/02 17:19:45  arno
% do not remove nested boundary events
%
% Revision 1.16  2004/06/01 21:46:18  arno
% NaN when concatenating datasets
%
% Revision 1.15  2004/05/15 00:59:05  arno
% allow empty event array
%
% Revision 1.14  2004/05/14 22:14:05  arno
% empty fields for boundary events
%
% Revision 1.13  2004/05/14 22:10:04  arno
% header
%
% Revision 1.12  2004/05/14 21:29:06  arno
% only event not urevents
%
% Revision 1.11  2004/05/06 21:53:28  arno
% same
%
% Revision 1.10  2004/05/06 21:52:43  arno
% debuging for mergeset
%
% Revision 1.9  2004/05/06 17:42:32  arno
% add checkevent input
% .,
%
% Revision 1.8  2004/05/05 01:54:40  arno
% removing debug message
%
% Revision 1.7  2004/05/05 01:50:17  arno
% same
%
% Revision 1.6  2004/05/05 01:49:25  arno
% debug regions input
%
% Revision 1.5  2004/05/05 01:43:11  arno
% don't know
%
% Revision 1.4  2004/05/04 23:19:52  arno
% typo
%
% Revision 1.3  2004/05/04 23:05:02  arno
% debug length
%
% Revision 1.2  2004/05/04 19:01:08  arno
% removing nested urevent boundarie
%
% Revision 1.1  2004/04/20 02:09:31  arno
% Initial revision
%
% Revision 1.1  2004/04/20 01:11:39  arno
% Initial revision
%

function [eventout,indold] = eeg_insertbound( eventin, pnts, boundevents, regions, lengths);
    
    if nargin < 2
        help eeg_insertbound;
        return;
    end;
    if size(regions,2) ~= 1 & exist('lengths') ~= 1
        lengths = regions(:,2)-regions(:,1)+1;
        regions = regions(:,1);
    end;
    if exist('lengths') ~= 1
        lengths = zeros(size(regions));
    end;
    
    eventout = eventin;
    indold   = 1:length(eventin);
	for tmpindex = 1:length(boundevents)
        if boundevents(tmpindex) >= 0.5 & boundevents(tmpindex) <= pnts
                            
            % find event succeding boundary to insert event 
            % at the correct location in the urevent structure
            % ------------------------------
            if ~isempty(eventin) & isfield(eventin, 'latency')
                alllats   = cell2mat( { eventout.latency } ) - regions(tmpindex)+0.5;
                tmpind    = find( alllats >= 0 );
                [tmp tmpind2 ] = min(alllats(tmpind));
                tmpind2        = tmpind(tmpind2);
            else
                tmpind2 = [];
            end;
            
            % insert event at tmpind2
            % -----------------------
            if ~isempty(tmpind2)
                eventout(end+1).type      = 'boundary';
                tmp = eventout(end);
                eventout(tmpind2+1:end) = eventout(tmpind2:end-1);
                eventout(tmpind2) = tmp;
                indold(tmpind2:end) = indold(tmpind2:end)+1;
            else
                tmpind2 = length(eventout)+1;
                eventout(tmpind2).type     = 'boundary';
            end;
            eventout(tmpind2).latency  = regions(tmpindex)-0.5;
            eventout(tmpind2).duration = lengths(tmpindex); % just to create field
            
            [ tmpnest addlength ] = findnested(eventout, tmpind2);
            % We use to remove nested event (tmpnest) but this
            % interfere with parent function eeg_eegre()
            
            if addlength == -1
                eventout(tmpind2) = rmfield(eventout, 'duration');
                disp('Warning: old boundary event type present in dataset');
                disp('         The new boundary events have to be compatible with the old ones');
                disp('         and will not contain the duration of the removed region');
            else
                eventout(tmpind2).duration = lengths(tmpindex)+addlength;                
                if eventout(tmpind2).duration == 0, eventout(tmpind2).duration=NaN; end;
            end;
        
        end; 
	end;

% look for nested events
% retrun indices of nested events and
% their total length
% -----------------------------------
function [ indnested, addlen ] = findnested(event, ind);
    indnested = [];
    addlen = 0;
    tmpind = ind+1;

    while tmpind < length(event) & ...
        event(tmpind).latency < event(ind).latency+event(ind).duration
        if strcmpi(event(tmpind).type, 'boundary')
            indnested = [ indnested tmpind ];
            if ~isempty( event(tmpind).duration )
                addlen    = addlen + event(tmpind).duration;
            else
                addlen = -1; % error
            end;
        end;
        tmpind = tmpind+1;
    end;
    
% remove urevent and recompute indices
% THIS FUNCTION IS DEPRECATED
% ------------------------------------
function [event, urevent] = removenested(event, urevent, nestind);
    
    if length(nestind) > 0
        fprintf('Debug msg: removing %d nested urevents\n', length(nestind));
        nestind = sort(nestind);
        urind = cell2mat({ event.urevent }); % this must not be done in the loop
                                             % since the indices are dyanmically updated
    end;
    
    for ind = 1:length(nestind)
        % find event urindices higher than the urevent to suppress
        % --------------------------------------------------------
        tmpind = find( urind > nestind(ind) );
        for indevent = tmpind
            event(indevent).urevent = event(indevent).urevent-1;
        end;    
    end;
    
    urevent(nestind) = [];
    