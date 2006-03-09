% std_readerp() - Given the ALLEEG structure, a specific EEG dataset index, 
% and a specific component, the function returns the ERP of that ICA component. 
% The ERP of the dataset ICA components is assumed to be saved in a Matlab 
% file. If such a file doesn't exist,
% you can use the std_erp() function to create it, or use the pre - clustering functions
% that call it: pop_preclust, eeg_preclust & eeg_createdata.  
% Along with the ERP of the selected ICA component the function returns  
% the time vector of the ERP samples. 
%
% Usage:    
%   >> [erp, t] = std_readerp(ALLEEG, setind, component);  
%   This functions returns the ERP of an ICA component. 
%   The information is loaded from a float file, which a pointer 
%   to is saved in the EEG dataset. The float file was created
%   by the pre - clustering function std_erp. 
%
% Inputs:
%   ALLEEG     - an EEGLAB data structure, which holds EEG sets (can also be one EEG set). 
%                      ALLEEG must contain the dataset of interest (the setind).
%   setind     -  [integer] an index of an EEG dataset in the ALLEEG
%                      structure, for which to get the component ERP.
%   component  - [integer] a component index in the selected EEG dataset for which 
%                      an ERP will be returned. 
%
% Outputs:
%   erp            - the ERP of the requested ICA component in the
%                      selected dataset. This is the average of the ICA
%                      activation across all the epochs.
%   t              - a vector of the time points in which the ERP was computed. 
%
%  See also  std_erp(), pop_preclust(), std_preclust()          
%
% Authors: Arnaud Delorme, Hilit Serby, SCCN, INC, UCSD, February, 2005

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Hilit Serby, SCCN, INC, UCSD, October 11, 2004, hilit@sccn.ucsd.edu
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
% Revision 1.4  2006/03/08 20:31:25  arno
% rename func
%
% Revision 1.3  2006/03/07 22:21:26  arno
% use fullfile
%
% Revision 1.2  2006/03/07 22:09:25  arno
% fix error message
%

function [erp, t] = std_readerp(ALLEEG, abset, comp)
    
erp = [];
filename  = fullfile( ALLEEG(abset).filepath,[ ALLEEG(abset).filename(1:end-3) 'icaerp']);
erpstruct = load( '-mat', filename, [ 'comp' int2str(comp) ], 'times' );
erp       = getfield(erpstruct, [ 'comp' int2str(comp) ]);
t         = getfield(erpstruct, 'times');
