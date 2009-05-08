% dipoledensity() - compute and optionally plot a measure of the 3-D spatial 
%                   (in)homogeneity of a specified (large) set of 1- or 2-dipole 
%                   component models, either as physical dipole density or as 
%                   dipole-position entropy across subjects. In either case, 
%                   take into account either all the dipoles, or only the nearest 
%                   dipole from each of the subjects. If no output arguments, 
%                   or if 'plot','on', paints a 3-D density|entropy brain image 
%                   on slices of the Montreal Neurological Institute (MNI) mean 
%                   MR brain image ('standard_BESA/avg152t1.mat'). Calls dipplot(), 
%                   mri3dplot(), and Fieldtrip function find_inside_vol(). 
% Usage:
%               >> [dens3d mri] = dipoledensity( dipplotargs, 'key',val, ... );
% Inputs: 
%    dipplotargs - dipplot() style arguments for specifying and plotting dipoles 
%                  The dipplot() function is used to convert dipole coordinates to 
%                  MNI brain coordinates. See >> help dipplot
%
% Optional 'key', val input pairs:
%
%    'subjind'  - [(1,ncomps) array] subject index for each dipole model. If two 
%                 dipoles are in one component model, give only one subject index. 
%    'method'   - ['alldistance'|'distance'|'entropy'|'relentropy'] method for 
%                            computing density: 
%                 'alldistance' - {default} take into account the gaussian-weighted 
%                            distances from each voxel to all the dipoles. See 
%                            'methodparam' (below) to specify a standard deviation 
%                            (in mm) for the gaussian weight kernel.
%                 'distance' - take into account only the distances to the nearest
%                              dipole for each subject. See 'methodparam' (below).
%                 'entropy' - taking into account only the nearest dipole to each 
%                             voxel for each subject. See 'methodparam' below. 
%                 'relentropy' - as in 'entropy,' but take into account all the 
%                             dipoles for each subject. 
% 'methodparam' - [number] for 'distance'|'alldistance' methods (see above), the
%                 standard deviation (in mm) of the 3-D gaussian smoothing kernel.
%                 For 'entropy'|'relentropy' methods, the number of closest dipoles 
%                 to include {defaults: 20 mm | 20 dipoles }
% 'subsample'   - [integer] subsampling of native MNI image {default: 2 -> 2x2x2}
% 'weight'      - [(1,ncomps) array] for 'distance'|'alldistance' methods, the 
%                 relative weight of each component dipole {default: ones()}
% 'nsessions'   - [integer] for 'alldistance' method, the number of sessions to 
%                 divide the output values by, so that the returned measure is 
%                 dipole density per session {default: 1}
% 'plot'        - ['on'|'off'] force plotting dipole density|entropy 
%                 {default: 'on' if no output arguments, else 'off'}
% 'dipplot'     - ['on'|'off'] plot the dipplot image (used for converting
%                 coordinates (default is 'off')
% 'plotargs'    - {cell array} plotting arguments for mri3dplot() function.
%
% Outputs:
%  dens3d       - [3-D num array] density in dipoles per cubic centimeter. If output
%                 is returned, no plot is produced unless 'plot','on' is specified. 
%  mri          - {MRI structure} used in mri3dplot().
%
% Example: 
%         >> [dens3d mri] = dipoledensity( dipplotargs, ... % save outputs, no plot
%                                   'method', 'alldistance', 'methodparam', 20);
%         >> mri3dplot(dens3d,mri);                         % plot outputs - see its
%                                                           % help msg for options
% See also:
%           EEGLAB: dipplot(), mri3dplot(), Fieldtrip: find_inside_vol() 
%
% Author: Arnaud Delorme & Scott Makeig, SCCN, INC, UCSD

% Copyright (C) Arnaud Delorme & Scott Makeig, SCCN/INC/UCSD, 2003-
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
% Revision 1.1  2009/05/07 22:47:16  arno
% adding mri3dplot and dipoledensity
%
% Revision 1.30  2008/09/08 22:40:58  nima
% _
%
% Revision 1.29  2008/09/08 21:32:11  nima
% normalization option added to deal with negative probabilities.
%
% Revision 1.28  2008/02/02 02:23:30  arno
% help msg
%
% Revision 1.27  2007/08/23 19:24:08  nima
% _
%
% Revision 1.26  2007/08/23 19:18:05  nima
% mni model file path moved to icadefs.m
%
% Revision 1.25  2007/01/02 17:47:45  scott
% added documentation
%
% Revision 1.24  2006/12/21 18:45:14  scott
% help msg
%
% Revision 1.23  2006/11/27 21:38:52  arno
% find fieldtrip folder
%
% Revision 1.22  2006/07/19 17:02:45  scott
% help message
%
% Revision 1.21  2006/04/01 23:09:05  scott
% help msg; generalize finding Fieldtrip private dir (name changes with version)
%
% Revision 1.20  2005/11/02 18:28:43  arno
% fix typo
%
% Revision 1.19  2005/10/26 22:03:38  arno
% typo
%
% Revision 1.18  2005/10/26 21:49:23  arno
% now getting coordinates directly from dipplot
%
% Revision 1.17  2005/10/26 21:34:43  arno
% *** empty log message ***
%
% Revision 1.16  2005/10/26 21:33:11  arno
% *** empty log message ***
%
% Revision 1.15  2005/10/26 18:42:08  arno
% distribution of distances
%
% Revision 1.14  2005/10/14 18:56:48  arno
% remove debug
%
% Revision 1.13  2005/10/03 21:08:16  arno
% debug nbdip
%
% Revision 1.12  2005/10/03 21:05:27  arno
% fix typo
%
% Revision 1.11  2005/09/30 18:12:19  arno
% linear weighting
%
% Revision 1.10  2005/09/30 18:11:19  arno
% weight for each dipole
%
% Revision 1.9  2005/09/30 16:19:42  arno
% nsessions
%
% Revision 1.8  2005/09/30 15:38:41  arno
% fixing kernel parameter size
%
% Revision 1.7  2005/09/30 15:27:13  arno
% text
%
% Revision 1.6  2005/09/28 21:38:03  arno
% fix call; returns unit in dipole/cm^3
%
% Revision 1.5  2005/09/28 17:41:33  arno
% temporary save
%
% Revision 1.4  2005/08/22 22:41:44  hilit
% change from relative to absolute subject indices (Julie's change)
%
% Revision 1.3  2005/08/17 18:04:34  nick
% playing around with the code
%
% Revision 1.2  2005/07/09 15:30:55  arno
% header
%
% Revision 1.1  2005/07/08 22:50:58  arno
% Initial revision
%

function [prob3d, mri] = dipoledensity(dipplotargs, varargin)

    % TO DO: return in dipplot() the real 3-D location of dipoles (in posxyz)
    %        FIX the dimension order here
    
prob3d = []; mri = [];
if nargin < 1
   help dipoledensity
   return
end

g = finputcheck(varargin, { 'subjind'     'integer'  []               [];
                            'method' 'string' { 'relentropy' 'entropy' 'distance' 'alldistance' } 'alldistance';
                            'methodparam' 'real'     []               20; 
                            'weight'      'real'     []               [];
                            'smooth'      'real'     []               0;
                            'nsessions'   'integer'  []               1;
                            'subsample'   'integer'  []               2;
                            'plotargs'    'cell'     []               {};
                            'plot'        'string'  { 'on' 'off' }    fastif(nargout == 0, 'on', 'off');
                            'dipplot'     'string'  { 'on' 'off' }   'off';
                            'normalization' 'string'  { 'on' 'off' } 'on';
                            'mri'         { 'struct' 'string' } [] ''});
if isstr(g), error(g); end;
if ~strcmpi(g.method, 'alldistance') & isempty(g.subjind)
    error('Subject indices are required for this method');
end;

% plotting
% --------
struct = dipplot(dipplotargs{:}, 'plot', g.dipplot);
if nargout == 0
    drawnow;
end;

% retrieve coordinates in MNI space
% ---------------------------------
if 0 % deprecated
     % find dipoles 
     % ------------
    hmesh = findobj(gcf, 'tag', 'mesh');
    if isempty(hmesh), error('Current figure must contain dipoles'); end;
    hh = [];
    disp('Finding dipoles...');
    dips = zeros(1,200);
    for index = 1:1000
        hh = [ hh(:); findobj(gcf, 'tag', ['dipole' int2str(index) ]) ];
        dips(index) = length(findobj(gcf, 'tag', ['dipole' int2str(index) ]));
    end;
    
    disp('Retrieving dipole positions ...');
    count = 1;
    for index = 1:length(hh)
        tmp = get(hh(index), 'userdata');
        if length(tmp) == 1
            allx(count) = tmp.eleccoord(1,1);
            ally(count) = tmp.eleccoord(1,2);
            allz(count) = tmp.eleccoord(1,3);
            alli(count) = index;
            count = count + 1;
        end;
    end;
end;    

% check weights
% -------------
if ~isempty(g.weight)
    if length(g.weight) ~= length(struct)
        error('There must be as many elements in the weight matrix as there are dipoles')
    end;
else
    g.weight = ones( 1, length(struct));
end;
if ~isempty(g.subjind)
    if length(g.subjind) ~= length(struct)
        error('There must be as many element in the subject matrix as there are dipoles')
    end;
else
    g.subjind = ones( 1, length(struct));
end;

% decoding dipole locations
% -------------------------
disp('Retrieving dipole positions ...');
count = 1;
for index = 1:length(struct)
    dips = size(struct(index).eleccoord,1);
    for dip = 1:dips
        allx(count) = struct(index).eleccoord(dip,1);
        ally(count) = struct(index).eleccoord(dip,2);
        allz(count) = struct(index).eleccoord(dip,3);
        alli(count) = index;
        allw(count) = g.weight(index)/dips;
        alls(count) = g.subjind(index);
        count = count + 1;
    end;
end;
g.weight  = allw;
g.subjind = alls;

% read MRI file
% -------------
if isempty(g.mri) % default MRI file
    folder = which('pop_dipfit_settings');
    folder = folder(1:end-21);
    delim  = folder(end);
    g.mri = [ folder 'standard_BESA' delim 'avg152t1.mat' ];
end
g.mri = load('-mat', g.mri); % read anatomic image structure
g.mri = g.mri.mri; % replace it by the image itself

mri = g.mri; % output the anatomic mri image 

% reserve array for density
% -------------------------
prob3d = zeros(ceil(g.mri.dim/g.subsample));

% compute voxel size
% ------------------
point1 = g.mri.transform * [ 1 1 1 1 ]';
point2 = g.mri.transform * [ 2 2 2 1 ]';
voxvol = sum((point1(1:3)-point2(1:3)).^2)*g.subsample^3; % in mm

% compute global subject entropy if necessary
% -------------------------------------------
vals   = unique(g.subjind); % the unique subject indices
if strcmpi(g.method, 'relentropy') | strcmpi(g.method, 'entropy') %%%%% entropy %%%%%%%
    newind = zeros(size(g.subjind));
    for index = 1:length(vals) % foreach subject in the cluster
        tmpind = find(g.subjind == vals(index)); % dipoles for the subject
        totcount(index) = length(tmpind); % store the number of subject dipoles
        newind(tmpind) = index; % put subject index into newind
    end;
    g.subjind = newind;
    gp = totcount/sum(totcount);
    globent = -sum(gp.*log(gp));
end;

% compute volume inside head mesh
% -------------------------------
dipfitdefs; % get the location of standard BEM volume file
tmp = load('-mat',DIPOLEDENSITY_STDBEM); % load MNI mesh

filename = [ '/home/arno/matlab/MNI_VoxelTsearch' int2str(g.subsample) '.mat' ];
if ~exist(filename)
    disp('Computing volume within head mesh...');
    [X Y Z]           = meshgrid(g.mri.xgrid(1:g.subsample:end)+g.subsample/2, ...
                                 g.mri.ygrid(1:g.subsample:end)+g.subsample/2, ...
                                 g.mri.zgrid(1:g.subsample:end)+g.subsample/2);
    [indX indY indZ ] = meshgrid(1:length(g.mri.xgrid(1:g.subsample:end)), ...
                                 1:length(g.mri.ygrid(1:g.subsample:end)), ...
                                 1:length(g.mri.zgrid(1:g.subsample:end)));
    allpoints = [ X(:)'    ; Y(:)'   ; Z(:)' ];
    allinds   = [ indX(:)' ; indY(:)'; indZ(:)' ];
    allpoints = g.mri.transform * [ allpoints ; ones(1, size(allpoints,2)) ];
    allpoints(4,:) = [];

    olddir = pwd;
    tmppath = which('electrodenormalize');
    tmppath = fullfile(fileparts(tmppath), 'private');
    cd(tmppath);
    [Inside Outside] = find_inside_vol(allpoints', tmp.vol); % from Fieldtrip 
    cd(olddir);
    disp('Done.');
    
    if 0 % old code using Delaunay %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        P = tmp.vol.bnd(1).pnt;
        T = delaunayn(P); % recompute triangularization (the original one is not compatible 
                          % with tsearchn) get coordinates of all points in the volume
        % search for points inside or ouside the volume (takes about 14 minutes!)
        IO = tsearchn(P, T, allpoints');
        Inside        = find(isnan(IO));
        Outside       = find(~isnan(IO));
        disp('Done.');
    end; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try, 
        save('-mat', filename, 'allpoints', 'allinds', 'Inside', 'Outside');
        disp('Saving file containing inside/outide voxel indices...');
    catch, end;
else
    disp('Loading file containing inside/outide voxel indices...');
    load('-mat',filename);
end;
InsidePoints  = allpoints(:, Inside);
InsideIndices = allinds(:, Inside);

% scan grid and compute entropy at each voxel
% -------------------------------------------
edges = [0.5:1:length(vals)+0.5];

if ~strcmpi(g.method, 'alldistance') 
    fprintf('Computing (of %d):', size(InsideIndices,2));
    % entropy calculation: have to scan voxels
    % ----------------------------------------
    for i = 1:size(InsideIndices,2)
        
        alldists = (InsidePoints(1,i) - allx).^2 ...
                 + (InsidePoints(2,i) - ally).^2 ...
                 + (InsidePoints(3,i) - allz).^2;
        [tmpsort indsort] = sort(alldists); % sort dipoles by distance
        tmpweights = g.weight(indsort);
       
        if strcmpi(g.method, 'relentropy') | strcmpi(g.method, 'entropy') %%%%% entropy %%%%%%%
            
            subjs  = g.subjind(indsort(1:g.methodparam)); % get subject indices of closest dipoles
            p      = histc(subjs, edges);
            if strcmpi(g.method, 'relentropy')
                p      = p(1:end-1)./totcount; 
                % this should be uniform if p conforms to global count for all subjects
            end;
            p      = p/sum(p);
            p(find(p == 0)) = [];
            prob3d(InsideIndices(1,i), InsideIndices(2,i), InsideIndices(3,i)) = -sum(p.*log(p));
        else
            % distance to each subject
            ordsubjs  = g.subjind(indsort);
            for index = 1:length(vals) % for each subject
                tmpind = find(ordsubjs == vals(index));
                if strcmpi(g.method,'distance')
                    use_dipoles(index) = tmpind(1); % find their nearest dipole 
                end
            end;
            prob3d(InsideIndices(1,i), InsideIndices(2,i), InsideIndices(3,i)) = ...
                   sum(tmpweights(use_dipoles).*exp(-tmpsort(use_dipoles)/ ...
                           (2*g.methodparam^2))); % 3-D gaussian smooth
        end;
        if mod(i,100) == 0, fprintf('%d ', i); end;
    end;
else % 'alldistance'
    % distance calculation: can scan dipoles instead of voxels (since linear)
    % --------------------------------------------------------
    %alldists = allx.^2 + ally.^2 + allz.^2;
    %figure; hist(alldists); return; % look at distribution of distances
    
    fprintf('Computing (of %d):', size(allx,2));
    tmpprob = zeros(1, size(InsidePoints,2));
    for i = 1:size(allx,2)
        alldists = (InsidePoints(1,:) - allx(i)).^2 + ...
                   (InsidePoints(2,:) - ally(i)).^2 + ...
                   (InsidePoints(3,:) - allz(i)).^2;
        
        tmpprob = tmpprob + g.weight(i)*exp(-alldists/(2*g.methodparam^2)); % 3-D gaussian smooth
        if any(isinf(tmpprob)), dfdsfa; end;
        if mod(i,50) == 0, fprintf('%d ', i); end;
    end;
    % copy values to 3-D mesh
    % -----------------------
    for i = 1:length(Inside)
        pnts = allinds(:,Inside(i));
        prob3d(pnts(1), pnts(2), pnts(3)) = tmpprob(i);
    end;
    
end;
fprintf('\n');

% normalize for points inside and outside the volume
% --------------------------------------------------
if strcmpi(g.method, 'alldistance') && strcmpi(g.normalization,'on')
    disp('Normalizing to dipole/mm^3');
    if any(prob3d(:)<0)
        fprintf('WARNING: Some probabilities are negative, this will likely cause problems when normalizing probabilities.\n');
        fprintf('It is highly recommended to turn normaliziation off by using ''normalization'' key to ''off''.\n');
    end;
    totval = sum(prob3d(:));  % total values in the head
    totdip = size(allx,2);   % number of dipoles
    voxvol;                  % volume o af a voxel in mm^3
    prob3d = prob3d/totval*totdip/voxvol*1000; % time 1000 to get cubic centimeters
    prob3d = prob3d/g.nsessions;
end;

% resample matrix
% ----------------
if g.subsample ~= 1
    prob3d = prob3d/g.subsample;
    newprob3d = zeros(g.mri.dim);
    X = ceil(g.mri.xgrid/g.subsample);
    Y = ceil(g.mri.ygrid/g.subsample);
    Z = ceil(g.mri.zgrid/g.subsample);
    for index = 1:size(newprob3d,3)
        newprob3d(:,:,index) = prob3d(X,Y,Z(index));
    end;    
    prob3d = newprob3d;
end;

% 3-D smoothing
% -------------
if g.smooth ~= 0
    disp('Smoothing...');
    prob3d = smooth3d(prob3d, g.smooth);
end;

% plotting
% --------
if strcmpi(g.plot, 'off')
    close gcf;
else
    mri3dplot( prob3d, g.mri, g.plotargs{:}); % plot the density using mri3dplot()
end;
return;
