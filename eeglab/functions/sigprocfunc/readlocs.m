% readlocs() - read polar electrode positions (expanded from the ICA toolbox function)
%             
% Usage:
%   >> [eloc, labels, theta, radius] = readlocs( filename, elpmaindir );
%
% Inputs:
%   filename   - name of the file containing the electrode locations
%                and convert in polar coordinates
% Optional:
%   elpmaindir - ['X'|'Y'] Direction pointing toward the subject in 
%                the Polhemus .elp file. Default is 'X'.  Used to 
%                convert locations from cartesian to polar coordinates.
%
% Note on suported formats:
%   The extension of the file determines its type
%   '.loc' or '.locs'   - polar format. Example:
%               1    -18    .352       Fp1
%               2     18    .352       Fp2
%               3    -90    .181       C3
%               4     90    .181       C4
%                 more lines ...
%   '.sph' - spherical coordinate file. Example:
%               1    -63.36    -72      Fp1
%               2     63.36    72       Fp2
%               3     32.58    0        C3
%               4     32.58    0        C4
%                 more lines ...
%   '.xyz' - cartesian coordinate file. Example:
%               1   -0.8355   -0.2192   -0.5039      Fp1
%               2   -0.8355    0.2192    0.5039      Fp2
%               3    0.3956         0   -0.9184      C3
%               4    0.3956         0    0.9184      C4
%                 more lines ...
%   '.txt' - read ascii files saved using pop_editchan()
%   '.elp' - Polhemus coordinate file (uses readelp())
%
% Outputs:
%   eloc      - structure containing the channel names and locations.
%               It has three fields 'labels', 'theta' and 'radius'.
%   labels    - names of the electrodes
%   theta     - vector of polar angles of the electrodes in degrees
%   radius    - vector of polar norms of the electrodes
%
% Note: the function cart2topo() is used to convert cartesian to polar
%       coordinates. By default the current function uses cart2topo()
%       options to recompute the best center and optimize the squeezing
%       parameter.
%
% Author: Arnaud Delorme & Scott Makeig CNL / Salk Institute, 28 Feb 2002
%
% See also: readelp(), topo2sph(), sph2topo(), cart2topo(), sph2cart()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, CNL / Salk Institute, 28 Feb 2002
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
% Revision 1.5  2002/05/01 03:27:40  arno
% removing sperical
%
% Revision 1.4  2002/05/01 02:11:56  arno
% new .txt format
%
% Revision 1.3  2002/05/01 01:15:31  arno
% removing topo optimization
%
% Revision 1.2  2002/04/18 15:17:25  scott
% editted help msg -sm
%
% Revision 1.1  2002/04/05 17:39:45  jorn
% Initial revision
%

function [eloc, labels, theta, radius] = readlocs( filename, elpmaindir ); 

if nargin < 1
	help readlocs;
	return;
end;

if isstr(filename)
	% open file
	% ---------
	array = load_file_or_array( filename, 0);

    periods = find(filename == '.');
    fileextension = filename(periods(end)+1:end);

	% scan file
	% ---------
    switch lower(fileextension),
        case { '' 'chanlocs'}, eloc = array; 
        case 'xyz', 
			for index = 1:size( array, 1)
			  eloc(index).X = array{index, 2};
			  eloc(index).Y = array{index, 3};
			  eloc(index).Z = array{index, 4};
			  eloc(index).labels  = array{index, 5};
			  [ eloc(index).theta eloc(index).radius] ...
			         = cart2topo( eloc(index).X, eloc(index).Y, eloc(index).Z);
			end;  
        case 'sph', 
			for index = 1:size( array, 1)
			  eloc(index).sph_theta    = array{index, 2};
			  eloc(index).sph_phi = array{index, 3};
			  eloc(index).sph_radius = 1;
			  eloc(index).labels  = array{index, 4};
			end;  
        case { 'loc' 'locs' }, 
			for index = 1:size( array, 1)
			  eloc(index).theta = array{index, 2};
			  eloc(index).radius  = array{index, 3};
			  eloc(index).labels  = array{index, 4};
			  eloc(index).labels( find(eloc(index).labels == '.' )) = ' ';
			end;
        case 'elp', 
            [eloc labels X Y Z]= readelp( filename );
            if exist('elpmaindir') ~= 1, elpmaindir = 'X'; end;
 			if strcmp(lower(elpmaindir), 'x')
                [theta radius] = cart2topo( -X', -Y', Z');  
            else
                [theta radius] = cart2topo( -Y', -X', Z','optim',1);  
            end;
			for index = 1:length( eloc )
			  tmp = eloc(index).X;
			  eloc(index).X = -eloc(index).Y;
			  eloc(index).Y = -tmp;			  
			  eloc(index).theta  = theta(index);
			  eloc(index).radius = radius(index);
			  eloc(index).labels = labels{index};
            end;
	     case 'txt', 
		    if isempty(array(end,1)), totlines = size( array, 1)-1; else totlines = size( array, 1); end;
			for index = 2:totlines
				if ~isempty(array{index,2}) eloc(index-1).labels  = array{index, 2}; end;
				if ~isempty(array{index,3}) eloc(index-1).theta = array{index, 3}; end;
				if ~isempty(array{index,4}) eloc(index-1).radius  = array{index, 4}; end;
				if ~isempty(array{index,5}) eloc(index-1).X = array{index, 5}; end;
				if ~isempty(array{index,6}) eloc(index-1).Y = array{index, 6}; end;
				if ~isempty(array{index,7}) eloc(index-1).Z = array{index, 7}; end;
				if ~isempty(array{index,8}) eloc(index-1).sph_theta = array{index, 8}; end;
				if ~isempty(array{index,9}) eloc(index-1).sph_phi   = array{index, 9}; end;
				if ~isempty(array{index,10}) eloc(index-1).sph_radius   = array{index, 10}; end;
			end;
        otherwise, error('Readlocs(): unrecognized file extension');
    end;
    for index = 1:length( eloc )
        if ~isstr(eloc(index).labels)
            eloc(index).labels = num2str( eloc(index).labels );
            if ~isempty(findstr( '0.', eloc(index).labels ))
                eloc(index).labels = eloc(index).labels(3:end);
            end;    
        else
            eloc(index).labels = deblank(num2str( eloc(index).labels ));
        end;
    end;    
else
    if isstruct(filename)
        eloc = filename;
    else
        disp('Readlocs: input variable must be a string or a structure');
    end;        
end;
theta = cell2mat({ eloc.theta });
radius  = cell2mat({ eloc.radius });
labels = { eloc.labels };

return;

% interpret the variable name
% ---------------------------
function array = load_file_or_array( varname, skipline );

    if exist( varname ) == 2
        array = loadtxt(varname);
    else % variable in the global workspace
         % --------------------------
         array = evalin('base', varname);
    end;     
return;
