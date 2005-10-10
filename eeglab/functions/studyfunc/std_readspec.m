% Usage:    
%   >> [spec, f] = cls_readspec(ALLEEG, abset, comp);  
%   This functions returns the spectrum of an ICA component. 
%   The information is loaded from a float file, which a pointer 
%   to is saved in the EEG dataset. The float file was created by the 
%   pre - clustering function cls_spec, in a specific frequency range. 
%
% cls_readspec() - Given the ALLEEG structure, a specific EEG dataset index, 
% and a specific component, the function returns the spectrum of that ICA component. 
% The spectrum of the dataset ICA components is assumed to be saved in a float 
% file, the EEG dataset include a pointer to this file. If such a float file doesn't exist,
% you can use the cls_spec() function to create it, or use the pre - clustering functions
% that call it: pop_preclust, eeg_preclust & eeg_createdata.  
% Along with the spectrum of the selected ICA component the function returns  
% the frequencies vector of the spectrum. 
%
%
% Inputs:
%   ALLEEG     - an EEGLAB data structure, which holds EEG sets (can also be one EEG set). 
%                      ALLEEG must contain the dataset of interest (the setind).
%   setind         -  [integer] an index of an EEG dataset in the ALLEEG
%                      structure, for which to get the component spectrum.
%   component - [integer] a component index in the selected EEG dataset for which 
%                      a spectrum will be returned. 
%
% Outputs:
%   spec          - the spectrum of the requested ICA component in the
%                    selected dataset. 
%   f             - a vector of the frequency points in which the spectra was computed. 
%
%  See also  cls_spec, pop_preclust, eeg_preclust, eeg_createdata           
%
% Authors:  Hilit Serby, SCCN, INC, UCSD, February, 2005

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

function [spec, f] = cls_readspec(ALLEEG, abset, comp);

spec = [];
if iscell(ALLEEG(abset).etc.icaspecmparams)
    d = ALLEEG(abset).etc.icaspecmparams{1};
else
    d = ALLEEG(abset).etc.icaspecmparams(1);
end
try
    f = floatread([ ALLEEG(abset).filepath ALLEEG(abset).etc.icaspec 'm'], [d 1],[],0);
    spec = floatread([ ALLEEG(abset).filepath ALLEEG(abset).etc.icaspec 'm'], [d 1],[],d*(comp));
catch
    try
        f = floatread([ ALLEEG(abset).filepath '/'  ALLEEG(abset).etc.icaspec 'm' ], [d 1], [], 0);
        spec = floatread([ ALLEEG(abset).filepath '/' ALLEEG(abset).etc.icaspec 'm' ], [d 1],[],d*(comp));
    catch
        try
            f = floatread([ ALLEEG(abset).filepath '\'  ALLEEG(abset).etc.icaspec 'm'], [d 1], [], 0 );
            spec = floatread([ ALLEEG(abset).filepath '\' ALLEEG(abset).etc.icaspec 'm'], [d 1],[],d*(comp));
        catch
            warndlg2(['cls_readspec: file '  ALLEEG(abset).etc.icaspec 'm was not found in path ' ALLEEG(abset).filepath], 'Abort - computing spectra centroid' ); 
            return;
        end
    end
end