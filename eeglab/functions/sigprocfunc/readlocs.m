% readlocs() - read electrode location information from a file.
%             
% Usage:
%   >> [eloc, labels, theta, radius] = readlocs( filename );
%   >> [eloc, labels, theta, radius] = readlocs( filename, 'key', 'val', ... );
%
% Inputs:
%   filename   - Name of the file containing the electrode locations
%                Default is 2-D polar coordinates (see >> help topoplot )
%
% Optional inputs:
%   'filetype'  - ['loc'|'sph'|'sfp'|'xyz'|'polhemus'|'besa'|'chanedit'|'custom'] 
%                 Type of the file to read. By default the file type is determined 
%                 using the file extension (.loc, .sph, etc.):
%                  'loc' - an EEGLAB 2-D topography file (see below)
%                  'sph' - a Matlab spherical coordinates file (Note: spherical
%                        coordinates used by Matlab functions are different 
%                        from spherical coordinates used in BESA). (see below)
%                  'sfp' - EGI cartesian coordinates. (see below)
%                  'xyz' - MATLAB/EEGLAB cartesian coordinates. (see below)
%                        y is toward the right ear, and z is toward the vertex.
%                  'polhemus' or 'polhemusx' - Polhemus electrode location file 
%                        recorded with 'X' on sensor pointing to subject (see readelp() )
%                  'polhemusy' - Polhemus electrode location file 
%                        recorded with 'Y' on sensor pointing to subject (see readelp() )
%                  'besa' - BESA-'.elp' spherical coordinate file. Note that BESA and MATLAB
%                           spherical coordinates are different (see below).
%                  'chanedit' - EEGLAB files created by pop_chanedit().
%                  'custom' - Allows the user to specify a format using 'format' 
%   'format'    - [cell array] Definition of a 'custom' channel location file type 
%                        (or if no file type is defined). The input cell array contains:
%                           'channum'   channel number (integer)
%                           'labels'    channel name (no spaces)
%                           'theta'     channel angle in 2-D polar coords. (0 towards nose)
%                           'radius'    channel radius 2-D polar coords. (0.5 is disk limits)
%                           'X'         channel Matlab-cartesian coordinate X (to nose)
%                           'Y'         channel Matlab-cartesian coordinate Y (to left ear)
%                           'Z'         channel Matlab-cartesian coordinate Z (to vertex)
%                           '-X'        negative Matlab-cartesian coordinate X (to occiput)
%                           '-Y'        negative Matlab-cartesian coordinate X (right ear)
%                           '-Z'        negative Matlab-cartesian coordinate Z (to throat)
%                           'sph_theta' Matlab spherical theta ( = horiz/azimuthal angle) 
%                           'sph_phi'   Matlab spherical phi ( = elevation in deg.) 
%                           'sph_radius' channel radius (for intercompatibility) 
%                           'sph_phi_besa' BESA phi angle ( = angle out from vertical)
%                           'sph_theta_besa' BESA theta angle ( = horiz/azimuthal angle)  
%     Other channel information fields
%                           'type'      channel type: EEG, MEG, EMG, ECG, others ...
%                           'calib'     channel calibration value (near 1.0).
%                           'gain'      channel gain. 
%                           'custom1'   custom field 1.
%                           'custom2', 'custom3', 'custom4' other custom fields.
%   'skipline'  - [integer] number of header lines to skip ('custom' file types only).
%   'readchans' - [integer array] indices of electrodes to read. Default is all.
%   'center'    - [(1,3) array or 'auto'] of xyz coordinates for conversion to 
%                 spherical or polar, Specify the center of the sphere here, or 
%                'auto'. This uses the center of the sphere that best fits all 
%                 the electrode locations read. Default is [0 0 0].
%
% File formats:
%   The extension of the file determines its type if 'filetype' is unspecified
%   '.loc' or '.locs': 
%               polar coordinates. Notes: angle in degrees: right ear is 90, 
%               left ear -90; head disk radius is 0.5. 
%     Fields:   N    angle  radius    label
%     Sample:   1    -18    .352       Fp1   
%               2     18    .352       Fp2  
%               3    -90    .181       C3
%               4     90    .181       C4
%                 ...
%               Note: In previous releases, channel labels had to contain 
%               exactly four characters (spaces replaced by '.').
%               This format still works but dots are no longer required.
%   '.sph':
%               Matlab spherical coordinates. Notes: theta is the azimuthal/horizontal
%               angle: 0 is toward nose, 90 toward left ear. Following this, perform
%               the elevation (phi). Angles in degrees.
%     Fields:   N    theta    phi    label
%     Sample:   1      18     -2      Fp1
%               2     -18     -2      Fp2
%               3      90     44      C3
%               4     -90     44      C4
%                 ...
%   '.elp':     
%               Polhemus-.'elp' cartesian coordinates. By default, an .elp extension is read
%               as PolhemusX-elp in which 'X' on the Polhemus sensor is pointed toward the 
%               subject. Polhemus files are not in columnar format (see readelp()).
%   '.elp':
%               BESA-'.elp' spherical coordinates: Need to specify 'filetype','besa'.
%               The elevation angle (phi) is measured from the vertical axis. Positive 
%               rotation is toward right ear. Next, perform azimuthal/horizontal rotation 
%               (theta): 0 is toward right ear; 90 is toward nose, -90 toward occiput. 
%               Angles are in degrees.  If labels are absent or weights are given in 
%               a last column, readlocs() adjusts for this. Default labels are E1, E2, ...
%     Fields:   label      phi  theta   
%     Sample:   Fp1        -92   -72    
%               Fp2         92    72   
%               C3         -46    0  
%               C4          46    0 
%                 ...
%   '.sfp': 
%               EGI-xyz cartesian coordinates. Notes: For EGI, x is toward right ear, 
%               y is toward the nose, z is toward the vertex. EEGLAB converts EGI 
%               cartesian coordinates to Matlab/EEGLAB xyz coordinates. 
%     Fields:   label   x           y         z
%     Sample:   Fp1   -0.8355   -0.2192   -0.5039      
%               Fp2   -0.8355    0.2192    0.5039     
%               C3     0.3956         0   -0.9184     
%               C4     0.3956         0    0.9184    
%                 ...
%   '.xyz': 
x               Matlab/EEGLAB cartesian coordinates. Here. x is towards the nose, 
%               y is towards the left ear, and z towards the vertex.
%     Fields:   label   x           y         z
%     Sample:   Fp1    ????
%               Fp2   ????
%               C3   ????
%               C4  ????
%   '.txt':   
%               ASCII file saved by pop_chanedit(). Contains multiple MATLAB/EEGLAB formats.
%     Fields:   label   theta radius x   y   z sph_theta sph_phi custom ....
%     Sample:   Fp1 
%               Fp2
%               C3 
%               C4 
%
% Outputs:
%   eloc      - structure containing the channel names and locations.
%               It has three fields: 'labels', 'theta' and 'radius'.
%   labels    - cell array of strings giving the  names of the electrodes
%   theta     - vector of polar angles for the electrodes (in degrees).
%   radius    - vector of polar coordinate radius values for the electrodes
%
% Author: Arnaud Delorme, Salk Institute, 8 Dec 2002
%         (expanded from the ICA toolbox function)
% See also: readelp(), writelocs(), topo2sph(), sph2topo(), sph2cart()

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
% Revision 1.26  2002/12/28 01:32:41  scott
% worked on header information - axis details etcetc. -sm & ad
%
% Revision 1.25  2002/12/27 23:23:35  scott
% edit header msg - NEEDS MORE DETAILS -sm
%
% Revision 1.24  2002/12/27 22:57:23  arno
% debugging polhemus
%
% Revision 1.23  2002/12/27 17:47:32  arno
% compatible with more BESA formats
%
% Revision 1.22  2002/12/26 16:41:23  arno
% new release
%
% Revision 1.21  2002/12/24 02:51:22  arno
% new version of readlocs
% ,
%

% To DO: remove the cart2topo, use cart2sph and sph2topo instead
% use chancenter to recenter data
%

function [eloc, labels, theta, radius] = readlocs( filename, varargin ); 

if nargin < 1
	help readlocs;
	return;
end;

% to add a new channel format
% ---------------------------
% 1) add the format name at the end of the listtype variable list
% 2) enter the column type in a new list at the end of the listimportformat variable
% 3) enter the number of lines to skip at the end of the listskipline array
% Note: these infos are also used by writelocs() and pop_readlocs() but
% you do not have to edit these functions.

listtype = { ...
   		 'polhemus' ...
         'polhemusX' ...
         'polhemusY' ...
         'besa' ...
         'xyz' ...
         'loc' ...
         'sph' ...
         'chanedit' ...
         'custom' };
   
listimportformat = { ...
   	{ } ... % polhemus (specific non-columnar implementation)	
      { } ... % polhemus (specific non-columnar implementation)
      { } ... % polhemus (specific non-columnar implementation)
      { 'labels' 'sph_theta_besa' 'sph_phi_besa' } ... % BESA/EGI format
      { 'labels' '-Y' 'X' 'Z' } ... % xyz format
      { 'channum' 'theta' 'radius' 'labels' } ... % loc format
      { 'channum' 'sph_theta' 'sph_radius' 'labels' } ... % sph format
      { 'labels'  'theta' 'radius' 'X' 'Y' 'Z' 'sph_theta' 'sph_phi' 'sph_radius' } }; %chanedit format

listcolformat = { 'labels' 'channum' 'theta' 'radius' 'sph_theta' 'sph_phi' ...
      'sph_radius' 'sph_theta_besa' 'sph_phi_besa' 'gain' 'calib' ...
      'X' 'Y' 'Z' '-X' '-Y' '-Z' 'custom1' 'custom2' 'custom3' 'custom4' 'not def' };

listskipline = [ ...
   0 ... % polhemus, not applicable
   0 ... % polhemus, not applicable
   0 ... % polhemus, not applicable
   -1 ...  % besa
   0 ...
   0 ...
   0 ...
   2 ]; % skip the 2 lines header for the chanedit format

% ------------------------------------------------------
% special mode for getting the infos
% ----------------------------------
if isstr(filename) & strcmp(filename, 'getinfos')
   eloc = listtype;
   labels = listimportformat;
   theta = listcolformat;
   radius = listskipline;
   return;
end;

g = finputcheck( varargin, ...
   { 'filetype'	'string'	 listtype '';
     'skipline'   'integer' [0 Inf] 			[];
     'elecind'    'integer' [1 Inf]				[];
     'format'		'cell'	 []					{} }, 'readlocs');
if isstr(g), error(g); end;  

if isstr(filename)
   
   % format auto detection
	% ---------------------
   periods = find(filename == '.');
   fileextension = filename(periods(end)+1:end);
   if isempty(g.filetype)
       switch lower(fileextension),
        case {'loc' 'locs' }, g.filetype = 'loc';
        case 'xyz', g.filetype = 'xyz';
        case 'sph', g.filetype = 'sph';
        case 'txt', g.filetype = 'chanedit';
        case 'elp', g.filetype = 'polhemus';
        case 'eps', g.filetype = 'besa';
        otherwise, g.filetype =  ''; 
       end;
       fprintf('Readlocs: ''%s'' format detected from file extension\n', g.filetype); 
   end;
   
   % assign format from filetype
   % ---------------------------
   if ~isempty(g.filetype) & ~strcmpi(g.filetype, 'custom') 
      indexformat = strmatch(lower(g.filetype), listtype, 'exact');
      g.format = listimportformat{indexformat};
      if isempty(g.skipline)
         g.skipline = listskipline(indexformat);
      end;
      if isempty(g.filetype) 
         error( ['Readlocs error: filetype can not be detected from' ...
               'file extension and custom format not specified']);
      end;
   end;
   
   % import file
   % -----------
   if strcmp(lower(g.filetype(1:end-1)), 'polhemus') | ...
           strcmp(lower(g.filetype), 'polhemus')
       [eloc labels X Y Z]= readelp( filename );
       if strcmp(lower(g.filetype), 'polhemusy')
           tmp = X; X = Y; Y = TMP;
       end;
       for index = 1:length( eloc )
           eloc(index).X = X(index);
           eloc(index).Y = Y(index);	
           eloc(index).Z = Z(index);	
       end;
   else      
       % importing file
       % --------------
       array = load_file_or_array( filename, max(g.skipline,0));
       if size(array,2) < length(g.format)
           fprintf('Readlocs warning: # of columns in file inferior to # format entries');
       elseif size(array,2) > length(g.format)
           fprintf('Readlocs warning: # of columns in file superior to # format entries');
       end;
       
       % removing lines BESA
       % -------------------
       if g.skipline == -1
           if isempty(array{1,2})
               disp('BESA header detected, skipping 3 lines');
               array = load_file_or_array( filename, -2);
           end;
       end;
       
       % removing comments and empty lines
       % ---------------------------------
       indexbeg = 1;
       while isempty(array{indexbeg,1}) | ...
               (isstr(array{indexbeg,1}) & array{indexbeg,1}(1) == '#' )
           indexbeg = indexbeg+1;
       end;
       array = array(indexbeg:end,:);
       
       % converting file
       % ---------------
       for indexcol = 1:min(size(array,2), length(g.format))
           [str mult] = checkformat(g.format{indexcol});
           for indexrow = 1:size( array, 1)
               if mult ~= 1
                   eval ( [ 'eloc(indexrow).'  str '= -array{indexrow, indexcol};' ]);
               else
                   eval ( [ 'eloc(indexrow).'  str '= array{indexrow, indexcol};' ]);
               end;
           end;
       end;
   end;
   
   % handling BESA coordinates
   % -------------------------
   if isfield(eloc, 'sph_theta_besa')
       if isnumeric(eloc(1).labels)
           disp('Alternate BESA format detected ( Theta | Phi )');
           for index = 1:length(eloc)
               eloc(index).sph_phi_besa   = eloc(index).sph_theta_besa;
               eloc(index).sph_theta_besa = eloc(index).labels;
           end;
           eloc = rmfield(eloc, 'labels');
       end;
       eloc = convertlocs(eloc, 'sphbesa2all');
       fprintf('Readlocs: BESA spherical coords. converted, now deleting BESA fields\n');   
       fprintf('          to avoid confusion (these field can be exported though)\n');   
       eloc = rmfield(eloc, 'sph_phi_besa');
       eloc = rmfield(eloc, 'sph_theta_besa');

       % converting XYZ coordinates to polar
       % -----------------------------------
   elseif isfield(eloc, 'X')
       eloc = convertlocs(eloc, 'cart2all');  
   elseif isfield(eloc, 'sph_theta')
       eloc = convertlocs(eloc, 'sph2all');  
   else 
       eloc = convertlocs(eloc, 'topo2all');  
   end;
   
   % inserting labels if no labels
   % -----------------------------
   if ~isfield(eloc, 'labels')
       fprintf('Readlocs: Automatically inserting electrode labels\n');
       for index = 1:length(eloc)
           eloc(index).labels = [ 'E' int2str(index) ];
       end;
   end;
   
   % resorting electrodes if number not-sorted
   % -----------------------------------------
   if isfield(eloc, 'channum')
       if ~isnumeric(eloc(1).channum)
           error('Channel numbers must be numeric');
       end;
       allchannum = cell2mat( { eloc.channum } );
       if any( sort(allchannum) ~= allchannum )
           fprintf('Readlocs: Resorting channel number based on ''channum'' column indices\n');
           [tmp newindices] = sort(allchannum);
           eloc = eloc(newindices);
       end;
       eloc = rmfield(eloc, 'channum');      
   end;
else
    if isstruct(filename)
        eloc = filename;
    else
        disp('Readlocs: input variable must be a string or a structure');
    end;        
end;
if ~isempty(g.elecind)
	eloc = eloc(g.elecind);
end;
theta = cell2mat({ eloc.theta });
radius  = cell2mat({ eloc.radius });
if isnumeric(eloc(1).labels)
    for index = 1:length(eloc)
        eloc(index).labels = int2str(eloc(index).labels);
    end;
end;
labels = { eloc.labels };

return;

% interpret the variable name
% ---------------------------
function array = load_file_or_array( varname, skipline );
	 if isempty(skipline),
       skipline = 0;
    end;
    if exist( varname ) == 2
        array = loadtxt(varname,'verbose','off','skipline',skipline);
    else % variable in the global workspace
         % --------------------------
         try, array = evalin('base', varname);
	     catch, error('readlocs: cannot find file or variable, check syntax');
		 end;
    end;     
return;

% check field format
% ------------------
function [str, mult] = checkformat(str)
	mult = 1;
	if strcmpi(str, 'labels'), str = lower(str); return; end;
	if strcmpi(str, 'channum'), str = lower(str); return; end;
	if strcmpi(str, 'theta'), str = lower(str); return; end;
	if strcmpi(str, 'radius'), str = lower(str); return; end;
	if strcmpi(str, 'sph_theta'), str = lower(str); return; end;
	if strcmpi(str, 'sph_phi'), str = lower(str); return; end;
	if strcmpi(str, 'sph_radius'), str = lower(str); return; end;
	if strcmpi(str, 'sph_theta_besa'), str = lower(str); return; end;
	if strcmpi(str, 'sph_phi_besa'), str = lower(str); return; end;
	if strcmpi(str, 'gain'), str = lower(str); return; end;
	if strcmpi(str, 'calib'), str = lower(str); return; end;
	if strcmpi(str, 'X'), str = upper(str); return; end;
	if strcmpi(str, 'Y'), str = upper(str); return; end;
	if strcmpi(str, 'Z'), str = upper(str); return; end;
	if strcmpi(str, '-X'), str = upper(str(2:end)); mult = -1; return; end;
	if strcmpi(str, '-Y'), str = upper(str(2:end)); mult = -1; return; end;
	if strcmpi(str, '-Z'), str = upper(str(2:end)); mult = -1; return; end;
	if strcmpi(str, 'custum1'), return; end;
	if strcmpi(str, 'custum2'), return; end;
	if strcmpi(str, 'custum3'), return; end;
	if strcmpi(str, 'custum4'), return; end;
   error(['Readlocs: undefined field ''' str '''']);
   
