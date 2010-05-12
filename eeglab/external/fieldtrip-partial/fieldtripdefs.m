function fieldtripdefs

% FIELDTRIPDEFS is called at the begin of all FieldTrip functions and
% contains some defaults and path settings
%
% Note that this should be a function and not a script, otherwise the
% hastoolbox function appears not be found in fieldtrip/private.

% Copyright (C) 2009, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: fieldtripdefs.m 948 2010-04-21 18:02:21Z roboos $

% set the global defaults, the checkconfig function will copy these into the local configurations
global ft_default
if ~isfield(ft_default, 'trackconfig'), ft_default.trackconfig = 'off';    end % cleanup, report, off
if ~isfield(ft_default, 'checkconfig'), ft_default.checkconfig = 'loose';  end % pedantic, loose, silent
if ~isfield(ft_default, 'checksize'),   ft_default.checksize   = 1e5;      end % number in bytes, can be inf

% this is for Matlab version specific backward compatibility support
% the version specific path should only be added once in every session
persistent versionpath
persistent signalpath

% don't use path caching with the persistent variable, this makes it slower
% but ensures that during the transition the subdirectories are added smoothly
clear hastoolbox

if isempty(which('hastoolbox'))
  % the fieldtrip/public directory contains the hastoolbox function
  % which is required for the remainder of this script
  addpath(fullfile(fileparts(which('fieldtripdefs')), 'public'));
end

try
  % this directory contains the backward compatibility wrappers for the ft_xxx function name change
  hastoolbox('compat', 1, 1);
end

try
  % this contains layouts and cortical meshes
  hastoolbox('template', 1, 1);
end

try
  % this is used in statistics
  hastoolbox('statfun', 1, 1);
end

try
  % this is used in definetrial
  hastoolbox('trialfun', 1, 1);
end

try
  % this contains the low-level reading functions
  hastoolbox('fileio', 1, 1);
  hastoolbox('fileio/compat', 1, 1);
end

try
  % this is for filtering time-series data
  hastoolbox('preproc', 1, 1);
  hastoolbox('preproc/compat', 1, 1);
end

try
  % this contains forward models for the EEG and MEG volume conduction problem
  hastoolbox('forward', 1, 1);
  hastoolbox('forward/compat', 1, 1);
end

try
  % numerous functions depend on this module
  hastoolbox('forwinv', 1, 1);
end

try
  % numerous functions depend on this module
  hastoolbox('inverse', 1, 1);
end

try
  % this contains intermediate-level plotting functions, e.g. multiplots and 3-d objects
  hastoolbox('plotting', 1, 1);
end

try
  % this contains specific code and examples for realtime processing
  hastoolbox('realtime', 1, 1);
end

if isempty(versionpath)
  % fieldtrip/compat contains version specific subdirectories to facilitate in backward compatibility support
  switch version('-release')
    case '13'
      % Version 6.5.1.199709 Release 13 (Service Pack 1)
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', 'R13');
    case '14'
      % Version 7.0.4.352 (R14) Service Pack 2
      % Version 7.1.0.183 (R14) Service Pack 3
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', 'R14');
    case '2006a'
      % Version 7.2.0.283 (R2006a)
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2006a');
    case '2006b'
      % Version 7.3
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2006b');
    case '2007a'
      % Version 7.4
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2007a');
    case '2007b'
      % Version 7.5
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2007b');
    case '2008a'
      % Version 7.6
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2008a');
    case '2008b'
      % Version 7.7
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2008b');
    case '2009a'
      % Version 7.8
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2009a');
    case '2009b'
      % Version 7.9
      versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', '2009b');
    otherwise
      % unknown release number, do nothing
      versionpath = 'unknown';
  end % switch
  if ~strcmp(versionpath, 'unknown') && isdir(versionpath) && isempty(strfind(path, versionpath))
    % only add the directory if it exists and was not added to the path before
    addpath(versionpath);
  end
end % if isempty(versionpath)

% test whether compat directories have been added corresponding to another matlab version
p = path;
r = version('-release');
v = {
  'R13'
  'R14'
  '2006a'
  '2006b'
  '2007a'
  '2007b'
  '2008a'
  '2008b'
  '2009a'
  '2009b'
  };
for i=1:length(v)
  versionpath = fullfile(fileparts(which('fieldtripdefs')), 'compat', v{i});
  if ~isempty(strfind(p, versionpath)) && ~strcmp(r, v{i})
    warning('The directory %s was found on your path, whereas you are running Matlab version %s.', versionpath, r)
    pause(0.5); % ensure that the user has time to read it
    warning('You should NOT add all subdirectories of fieldtrip to your path using addpath(genpath(...)).');
    pause(0.2); % ensure that the user has time to read it
    warning('You should ONLY add the fieldtrip main directory to your path and then call ''fieldtripdefs''.');
    pause(1.7); % ensure that the user has time to read it
    fprintf('Trying to remove incompatible directory from path...\n');
    pause(2.3); % ensure that the user has time to read it
    t = strfind(p, versionpath);
    p(t:t+length(versionpath)) = []; % don't use rmpath, because it may be broken due to the incorrect "fieldtrip/compat/release" version
    path(p);
  end
end

