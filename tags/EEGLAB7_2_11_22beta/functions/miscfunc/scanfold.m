% scanfold() - scan folder content
%
% Usage:    
%    >> [cellres textres] = scanfold(foldname);
%
% Inputs:
%   foldname  - name of the folder
%
% Outputs:
%   cellres   - cell array containing all the files
%   textres   - string array containing all the names preceeded by "-a"
% 
% Authors: Arnaud Delorme, SCCN, INC, UCSD, 2009

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, October 11, 2004, arno@sccn.ucsd.edu
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

function [ cellres, textres ] = scanfold(foldname)

foldcontent = dir(foldname);
textres = '';
cellres = {};
for i = 1:length(foldcontent)
    if exist(foldcontent(i).name) == 7
        if ~strcmpi(foldcontent(i).name, '..') & ~strcmpi(foldcontent(i).name, '.')
            disp(fullfile(foldname, foldcontent(i).name));
            [tmpcellres tmpres] = scanfold(fullfile(foldname, foldcontent(i).name));
            textres = [ textres tmpres ];
            cellres = { cellres{:} tmpcellres{:} };
        end;
    elseif length(foldcontent(i).name) > 2
        if strcmpi(foldcontent(i).name(end-1:end), '.m')
            textres = [ textres ' -a ' foldcontent(i).name ];
            cellres = { cellres{:} foldcontent(i).name };
        end;
    else 
        disp( [ 'Skipping ' fullfile(foldname, foldcontent(i).name) ]);
    end;
end;
return;
