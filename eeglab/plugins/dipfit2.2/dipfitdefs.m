% dipfitdefs() - default settings and filenames for dipolefitting 
%                to source in the ICA/ERP package functions.
%                Insert local dir reference below. 
%
% Note: Edit this file to change local directories under Unix and Windows 
%
% Author: Robert Oostenveld, SMI/FCDC, Nijmegen 2003

% SMI, University Aalborg, Denmark http://www.smi.auc.dk/
% FC Donders Centre, University Nijmegen, the Netherlands http://www.fcdonders.kun.nl

% Copyright (C) 2003 Robert Oostenveld, SMI/FCDC roberto@miba.auc.dk
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
% Revision 1.19  2009/07/30 03:44:04  arno
% fix dipfitdefs for compilation
%
% Revision 1.18  2007/08/23 19:23:11  nima
% DIPOLEDENSITY_STDBEM variables added to locate mni mesh
%
% Revision 1.17  2007/08/16 19:46:25  arno
% fix template coordinate assignment
%
% Revision 1.16  2007/08/16 18:59:29  arno
% automatic recognition of models
%
% Revision 1.15  2007/08/16 18:20:22  arno
% defining new templates
%
% Revision 1.14  2007/08/16 17:53:27  arno
% change the strcuture for templates
%
% Revision 1.13  2007/01/26 18:13:38  arno
% add MEG model
%
% Revision 1.12  2006/11/13 20:02:13  arno
% change automatic BEM rotation again
%
% Revision 1.11  2006/11/12 18:08:15  arno
% change coregistration for BEM
%
% Revision 1.10  2006/11/06 21:47:19  arno
% fix coregistration for BEM model
%
% Revision 1.9  2006/11/06 21:30:39  arno
% same
%
% Revision 1.8  2006/11/06 21:21:38  arno
% adding coregistration matrix
%
% Revision 1.7  2006/03/12 03:05:10  arno
% avoid crash with studies
%
% Revision 1.6  2006/01/10 22:57:17  arno
% new default for sphere
%
% Revision 1.5  2005/04/08 23:05:37  arno
% remove defaultsymetryhttp://www.google.com/
%
% Revision 1.4  2005/04/08 01:44:54  arno
% changing default symetry constraint
%
% Revision 1.3  2005/03/11 18:14:09  arno
% case sensitive problem
%
% Revision 1.2  2005/03/10 18:55:49  arno
% add template files
%
% Revision 1.1  2005/03/10 18:10:27  arno
% Initial revision
%
% Revision 1.16  2003/10/29 16:41:57  arno
% default grid
%
% Revision 1.15  2003/10/29 03:42:55  arno
% same
%
% Revision 1.14  2003/10/29 03:41:30  arno
% meanradius
%
% Revision 1.13  2003/10/29 03:35:20  arno
% remove elc computation
%
% Revision 1.12  2003/09/02 13:01:47  roberto
% added default constraint for symmetry
%
% Revision 1.11  2003/08/01 13:49:49  roberto
% removed 1 and 3 sphere defaults, renamed vol4besa to defaultvolume and added origin
%
% Revision 1.9  2003/06/13 16:48:22  arno
% undo chanlocs checks
%
% Revision 1.8  2003/06/13 01:21:19  arno
% still debuging auto conversion
%
% Revision 1.7  2003/06/13 01:01:34  arno
% debug last
%
% Revision 1.6  2003/06/13 01:00:40  arno
% convert polar to carthesian electrode location strcuture
%
% Revision 1.5  2003/03/12 10:32:12  roberto
% added 4-sphere volume model similar to BESA
%
% Revision 1.4  2003/03/06 15:57:56  roberto
% *** empty log message ***
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file is not a function but a script and is included in the dipfit_XXX functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try,
    if ~isfield(EEG, 'chanlocs')
    error('No electrode locations defined');
    end

    if ~isfield(EEG, 'icawinv')
    error('No ICA components present');
    end
    nchan = length(EEG(1).chanlocs);
    ncomp = size(EEG(1).icawinv, 2);
catch, nchan = 0; end;

% create one-sphere model
% defaultvolume.r = meanradius;
% defaultvolume.c = 0.33http://www.google.com/;
% defaultvolume.o = [0 0 0];

% create three-sphere model
% defaultvolume.r = meanradius * [0.0 0.92 0.88];
% defaultvolume.c = [0.33 0.0042 0.33];
% defaultvolume.o = [0 0 0];

% create four-sphere model that is identical to the default of besa
defaultvolume.r = [85-6-7-1 85-6-7 85-6 85];  % in mm
defaultvolume.c = [0.33 1.00 0.0042 0.33];    % brain/csf/skull/skin
defaultvolume.o = [0 0 0];

% default file locations 
% ----------------------
if ~iseeglabdeployed
    folder = which('pop_dipfit_settings');
    folder = folder(1:end-21);
else
    folder = eeglabexefolder;
end;
try,
    delim  = folder(end);
    template_models(1).name     = 'Spherical Four-Shell (BESA)';
    template_models(1).hdmfile  = fullfile(folder, 'standard_BESA', 'standard_BESA.mat');
    template_models(1).mrifile  = fullfile(folder, 'standard_BESA', 'avg152t1.mat');
    template_models(1).chanfile = fullfile(folder, 'standard_BESA', 'standard-10-5-cap385.elp');
    template_models(1).coordformat = 'spherical';
    template_models(1).coord_transform(1).transform = [ ];
    template_models(1).coord_transform(1).keywords  = { 'standard-10-5-cap385' };
    template_models(1).coord_transform(2).transform = [ 0 0 0 0 0 0 8 11 10 ];
    template_models(1).coord_transform(2).keywords  = { 'gsn' 'sfp' '12' };
    template_models(1).coord_transform(3).transform = [ 0 0 0 0 0.02 0 85 85 85 ];
    template_models(1).coord_transform(3).keywords  = { 'egi' 'elp' };

    template_models(2).name     = 'Boundary Element Model (MNI)';
    template_models(2).hdmfile  = fullfile(folder, 'standard_BEM', 'standard_vol.mat' );
    template_models(2).mrifile  = fullfile(folder, 'standard_BEM', 'standard_mri.mat' );
    template_models(2).chanfile = fullfile(folder, 'standard_BEM', 'elec', 'standard_1005.elc' );
    template_models(2).coordformat = 'MNI';
    template_models(2).coord_transform(1).transform = [ 0 0 0 0 0 -pi/2  1 1 1];
    template_models(2).coord_transform(1).keywords  = { 'standard_1005' };
    template_models(2).coord_transform(2).transform = [ 0 -15 4 0.05 0 -1.571 10.2 12 12.2 ];
    template_models(2).coord_transform(2).keywords  = { 'gsn' 'sfp' '12' };
    template_models(2).coord_transform(3).transform = [ 0 -15 0 0.08 0 -1.571 102 93 100 ];
    template_models(2).coord_transform(3).keywords  = { 'egi' 'elp' };
catch,
    disp('Warning: problem when setting paths for dipole localization');
end;

template_models(3).name        = 'CTF MEG';
template_models(3).coordformat = 'CTF';
template_models(4).name        = 'Custom model files';
template_models(4).coordformat = 'MNI'; % custom model

% constrain electrode to sphere
% -----------------------------
meanradius = defaultvolume.r(4);

% defaults for GUI pop_dipfit_settings dialog
defaultelectrodes = sprintf('1:%d', nchan);

% these settings determine the symmetry constraint that can be toggled on
% for the second dipole
%defaultconstraint = 'y';      % symmetry along x-axis
% PROBLEM: change with respect to the model used. Now just assume perpendicular to nose

% defaults for GUI pop_dipfit_batch dialogs
rejectstr    = '40';	% in percent
xgridstr     = sprintf('linspace(-%d,%d,11)', floor(meanradius), floor(meanradius));
ygridstr     = sprintf('linspace(-%d,%d,11)', floor(meanradius), floor(meanradius));
zgridstr     = sprintf('linspace(0,%d,6)', floor(meanradius));

% Set DipoleDensity path
DIPOLEDENSITY_STDBEM = fullfile(folder, 'standard_BEM', 'standard_vol.mat');