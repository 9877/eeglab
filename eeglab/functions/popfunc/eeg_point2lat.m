% eeg_point2lat() - convert latency to point
%
% Usage:
%       >> [newlat outbound] = eeg_point2lat( lat_array, epoch_array,...
%                                 srate, timelimits, timeunit);
%
% Inputs:
%   lat_array   - latency array in point assuming concatenated
%                 data epochs (see eeglab() event structure)
%   epoch_array - epoch number corresponding to each latency
%   srate       - sampling rate in Hz
%   timelimits  - [min max] timelimits in timeunit
%   timeunit    - time unit in second. Default is 1 second.
%
% Outputs:
%   newlat      - converted latency values in timeunit for each epoch
%   outbound    - indices of out of boundary latencies
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2 Mai 2002
%
% See also: eeg_point2lat()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2 Mai 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
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

function newlat = eeg_point2lat( lat_array, epoch_array, srate, timewin, timeunit);

if nargin <4
    help eeg_point2lat;
    return;
end;    
if nargin <5
	timeunit = 1;
end;

if length(lat_array) ~= length(epoch_array)
    disp('eeg_point2lat: latency and epochs must have the same length'); return;
end;
if length(timewin) ~= 2
    disp('eeg_point2lat: timelimits must have length 2'); return;
end;
if iscell(epoch_array)
	epoch_array = cell2mat(epoch_array);
end;
if iscell(lat_array)
	lat_array = cell2mat(lat_array);
end

timewin = timewin*timeunit;

pnts = (timewin(2)-timewin(1))*srate+1;
newlat  = ((lat_array - (epoch_array-1)*pnts-1)/srate+timewin(1))/timeunit;
