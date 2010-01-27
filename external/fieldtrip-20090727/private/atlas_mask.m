function [mask] = atlas_mask(atlas, mri, label, varargin)

% ATLAS_MASK creates a mask that can be used in visualizing a functional
% and/or anatomical MRI volume.
%
% Use as
%   atlas = atlas_init;
%   mask  = atlas_mask(atlas, mri, label, ...);
%
% Optinal input arguments should come in key-value pairs and can include
%   'inputcoord'   = 'mni' or 'tal' (default = []);
%
% Dependent on the input coordinates and the coordinates of the atlas, the
% input MRI is transformed betweem MNI and Talairach-Tournoux coordinates
% See http://www.mrc-cbu.cam.ac.uk/Imaging/Common/mnispace.shtml for more details.
%
% See also ATLAS_INIT, ATLAS_LOOKUP

% Copyright (C) 2005-2008, Robert Oostenveld
%
% $Log: not supported by cvs2svn $
% Revision 1.3  2008/07/31 20:34:05  roboos
% changed fprintf output (percent -> %)
%
% Revision 1.2  2008/07/31 12:57:12  ingnie
% changed inputcoords to inputcoord and atlas.coordinates to atlas.coord.
%
% Revision 1.1  2008/07/31 11:54:49  ingnie
% new implementation based on TTatlas_mask. Converts between mni and tal coordinates, and works both on volume and on source data.
%

% get the optional input arguments
inputcoord = keyval('inputcoord', varargin); if isempty(inputcoord),  error('specify inputcoord');   end

if ischar(label)
  label = {label};
end

sel = [];
for i=1:length(label)
  sel = [sel; strmatch(label{i}, atlas.descr.name, 'exact')];
end

fprintf('found %d matching anatomical labels\n', length(sel));

brick = atlas.descr.brick(sel);
value = atlas.descr.value(sel);

if isfield(mri, 'transform') && isfield(mri, 'dim')
  dim = mri.dim;
  % determine location of each anatomical voxel in its own voxel coordinates
  i = 1:dim(1);
  j = 1:dim(2);
  k = 1:dim(3);
  [I, J, K] = ndgrid(i, j, k);
  ijk = [I(:) J(:) K(:) ones(prod(dim),1)]';
  % determine location of each anatomical voxel in head coordinates
  xyz = mri.transform * ijk; % note that this is 4xN
elseif isfield(mri, 'pos')
  % the individual positions of every grid point are specified
  npos = size(mri.pos,1);
  dim  = [npos 1];
  xyz  = [mri.pos ones(npos,1)]';  % note that this is 4xN
else
  error('could not determine whether the input describes a volume or a source');
end

% convert between MNI head coordinates and TAL head coordinates
% coordinates should be expressed compatible with the atlas
if     strcmp(inputcoord, 'mni') && strcmp(atlas.coord, 'tal')
  xyz(1:3,:) = mni2tal(xyz(1:3,:));
elseif strcmp(inputcoord, 'mni') && strcmp(atlas.coord, 'mni')
  % nothing to do
elseif strcmp(inputcoord, 'tal') && strcmp(atlas.coord, 'tal')
  % nothing to do
elseif strcmp(inputcoord, 'tal') && strcmp(atlas.coord, 'mni')
  xyz(1:3,:) = tal2mni(xyz(1:3,:));
end

% determine location of each anatomical voxel in atlas voxel coordinates
ijk = inv(atlas.transform) * xyz;
ijk = round(ijk(1:3,:))';

inside_vol = ijk(:,1)>=1 & ijk(:,1)<=atlas.dim(1) & ...
  ijk(:,2)>=1 & ijk(:,2)<=atlas.dim(2) & ...
  ijk(:,3)>=1 & ijk(:,3)<=atlas.dim(3);
inside_vol = find(inside_vol);

% convert the selection inside the atlas volume into linear indices
ind = sub2ind(atlas.dim, ijk(inside_vol,1), ijk(inside_vol,2), ijk(inside_vol,3));

brick0_val = zeros(prod(dim),1);
brick1_val = zeros(prod(dim),1);
% search the two bricks for the value of each voxel
brick0_val(inside_vol) = atlas.brick0(ind);
brick1_val(inside_vol) = atlas.brick1(ind);

mask = zeros(prod(dim),1);
for i=1:length(sel)
  fprintf('constructing mask for %s\n', atlas.descr.name{sel(i)});
  if brick(i)==0
    mask = mask | (brick0_val==value(i));
  elseif brick(i)==1
    mask = mask | (brick1_val==value(i));
  end
end
mask = reshape(mask, dim);

fprintf('masked %.1f %% of total volume\n', 100*mean(mask(:)));

