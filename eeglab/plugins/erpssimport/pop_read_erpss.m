% pop_read_erpss() - import an uncompressed ERPSS-format EEG file 
%                    (.RAW or .RDF)
% Usage:
%   >> OUTEEG = pop_read_erpss( filename, srate );
%
% Inputs:
%   filename       - file name
%
% Outputs:
%   OUTEEG         - EEGLAB data structure
%
% Author: Arnaud Delorme, CNL / Salk Institute, 23 January 2003
%
% See also: eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
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
% Revision 1.1  2003/01/24 01:29:57  arno
% Initial revision
%

function [EEG, command] = pop_read_erpss(filename); 
command = '';

if nargin < 1
	% ask user
	[filename, filepath] = uigetfile('*.*', 'Choose a ERPSS file -- pop_read_erpss'); 
    drawnow;
	if filename == 0 return; end;
	filename = [filepath '/' filename];
end;

% read ERPSS format
EEG = eeg_emptyset;
fprintf('pop_read_erpss: importing ERPSS file...\n');
[EEG.data,events] = read_erpss('KBSTERN1.RDF');
EEG.nbchan = size(EEG.data,1);
EEG.srate = 1000;
EEG.setname = 'ERPSS data';
disp('Sampling rate set to 1000 Hz.');
EEG.event = struct( 'type', { events.event_code }, 'latency', {events.sample_offset});
EEG = eeg_checkset(EEG);

command = sprintf('EEG = pop_read_erpss(''%s'');',filename); 
return;
