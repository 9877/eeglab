function [vol] = prepare_bemmodel(cfg, mri)

% PREPARE_BEMMODEL constructs triangulations of the boundaries between
% multiple segmented tissue types in an anatomical MRI and subsequently
% computes the BEM system matrix.
%
% Use as
%  [vol] = prepare_bemmodel(cfg, mri), or
%  [vol] = prepare_bemmodel(cfg, vol)
%
% The configuration can contain
%   cfg.tissue         = [1 2 3], segmentation value of each tissue type
%   cfg.numvertices    = [Nskin Nskull Nbrain]
%   cfg.conductivity   = [Cskin Cskull Cbrain]
%   cfg.hdmfile        = string, file containing the volume conduction model (can be empty)
%   cfg.isolatedsource = compartment number, or 0
%   cfg.method         = 'dipoli', 'brainstorm' or 'bemcp'
%
% Although the example configuration uses 3 compartments, you can use
% an arbitrary number of compartments.
%
% This function implements
%   Oostendorp TF, van Oosterom A.
%   Source parameter estimation in inhomogeneous volume conductors of arbitrary shape
%   IEEE Trans Biomed Eng. 1989 Mar;36(3):382-91.

% Copyright (C) 2005-2009, Robert Oostenveld
%
% $Log: not supported by cvs2svn $
% Revision 1.16  2009/03/30 15:06:14  roboos
% added the patch from Alexandre to support openmeeg
%
% Revision 1.15  2009/03/24 12:47:11  roboos
% Christophe-> try to spare some memory
%
% Revision 1.14  2009/02/25 09:27:08  roboos
% ensure that the vertices and triangles are double precision, otherwise the bemcp mex files will crash (thanks to Alexandre Gramfort)
%
% Revision 1.13  2009/02/11 11:03:42  roboos
% changed naming of the functions of Chris in accordance with SPM8
%
% Revision 1.12  2009/02/02 13:15:04  roboos
% added bemcp method, removed the incomplete implementation of brainstorm
%
% Revision 1.11  2008/12/24 10:47:13  roboos
% moved the dipoli code to seperate helper function

fieldtripdefs

if ~isfield(cfg, 'tissue'),         cfg.tissue = [8 12 14];                  end
if ~isfield(cfg, 'numvertices'),    cfg.numvertices = [1 2 3] * 500;         end
if ~isfield(cfg, 'conductivity'),   cfg.conductivity = [1 1/80 1] * 0.33;    end
if ~isfield(cfg, 'hdmfile'),        cfg.hdmfile = [];                        end
if ~isfield(cfg, 'isolatedsource'), cfg.isolatedsource = [];                 end
if ~isfield(cfg, 'method'),         cfg.method = 'dipoli';                   end

% there are two types of input possible
hasmri = isfield(mri, 'transform');
hasvol = isfield(mri, 'bnd');

if hasvol && ~hasmri
  % rename the second input argument
  vol = mri;
  clear mri;
elseif hasmri && ~hasvol
  % start with an empty volume conductor
  vol = [];
else
  error('invalid input arguments');
end

if ~isfield(vol, 'cond')
  % assign the conductivity of each compartment
  vol.cond = cfg.conductivity;
end

% determine the number of compartments
Ncompartment = length(vol.cond);

if hasmri
  fprintf('using the segmented MRI\n');
  [mrix, mriy, mriz] = ndgrid(1:size(mri.seg,1), 1:size(mri.seg,2), 1:size(mri.seg,3));
  % construct the triangulations of the boundaries from the segmented MRI
  for i=1:Ncompartment
    fprintf('triangulating the boundary of compartment %d\n', i);
    seg = imfill((mri.seg==cfg.tissue(i)), 'holes');
    ori(1) = mean(mrix(seg(:)));
    ori(2) = mean(mriy(seg(:)));
    ori(3) = mean(mriz(seg(:)));
    [pnt, tri] = triangulate_seg(seg, cfg.numvertices(i), ori);
    % apply the coordinate transformation from voxel to head coordinates
    pnt(:,4) = 1;
    pnt = (mri.transform * (pnt'))';
    pnt = pnt(:,1:3);
    vol.bnd(i).pnt = pnt;
    vol.bnd(i).tri = tri;
  end
else
  fprintf('using the pre-specified triangulated boundaries\n');
end

% ensure that the vertices and triangles are double precision, otherwise the bemcp mex files will crash
for i=1:length(vol.bnd)
  vol.bnd(i).pnt = double(vol.bnd(i).pnt);
  vol.bnd(i).tri = double(vol.bnd(i).tri);
end

vol.source = find_innermost_boundary(vol.bnd);
vol.skin   = find_outermost_boundary(vol.bnd);
fprintf('determining source compartment (%d)\n', vol.source);
fprintf('determining skin compartment (%d)\n',   vol.skin);

if isempty(cfg.isolatedsource) && Ncompartment>1 && strcmp(cfg.method, 'dipoli')
  % the isolated source compartment is by default the most inner one
  cfg.isolatedsource = true;
elseif isempty(cfg.isolatedsource) && Ncompartment==1
  % the isolated source interface should be contained within at least one other interface
  cfg.isolatedsource = false;
elseif ~isempty(cfg.isolatedsource) && ~islogical(cfg.isolatedsource)
  error('cfg.isolatedsource should be true or false');
end

if cfg.isolatedsource
  fprintf('using compartment %d for the isolated source approach\n', vol.source);
else
  fprintf('not using the isolated source approach\n');
end

if strcmp(cfg.method, 'dipoli')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % this uses an implementation that was contributed by Thom Oostendorp
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % determine whether the command-line DIPOLI executable is available
  hastoolbox('dipoli', 1);
  % use the dipoli wrapper function
  vol = dipoli(vol, cfg.isolatedsource);

elseif strcmp(cfg.method, 'brainstorm')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % this uses an implementation from the BrainStorm toolbox
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  hastoolbox('brainstorm', 1);

  error('not yet implemented');

elseif strcmp(cfg.method, 'bemcp')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % this uses an implementation that was contributed by Christophe Philips
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  hastoolbox('bemcp', 1);

  vol.type = 'bemcp';

  % do some sanity checks
  if length(vol.bnd)~=3
    error('this only works for three surfaces');
  end
  if vol.skin~=3
    error('the skin should be the third surface');
  end
  if vol.source~=1
    error('the source compartment should correspond to the first surface');
  end

  % Build Triangle 4th point
  vol = triangle4pt(vol);

  % 2. BEM model estimation, only for the scalp surface

  defl =[ 0 0 1/size(vol.bnd(vol.skin).pnt,1)];
  % ensure deflation for skin surface, i.e. average reference over skin

  % NOTE:
  % Calculation proceeds by estimating each submatrix C_ij and combine them.
  % There are 2 options:
  % - calculating the matrices once, as it takes some time, keep them in
  %   memory and use them the 2-3 times they're needed.
  % - calculating the matrices every time they're needed, i.e. 2-3 times
  % The former option is faster but requires more memory space as up to *8*
  % square matrices of size C_ij have to be kept in memory at once.
  % The latter option requires less memory, but would take much more time to
  % estimate.
  % This faster but memory hungry solution is implemented here.

  % Deal first with surface 1 and 2 (inner and outer skull
  %--------------------------------

  % NOTE:
  % C11st/C22st/C33st are simply the matrix C11/C22/C33 minus the identity
  % matrix, i.e. C11st = C11-eye(N)

  weight = (vol.cond(1)-vol.cond(2))/((vol.cond(1)+vol.cond(2))*2*pi);
  C11st  = bem_Cii_lin(vol.bnd(1).tri,vol.bnd(1).pnt, weight,defl(1),vol.bnd(1).pnt4);
  weight = (vol.cond(1)-vol.cond(2))/((vol.cond(2)+vol.cond(3))*2*pi);
  C21    = bem_Cij_lin(vol.bnd(2).pnt,vol.bnd(1).pnt,vol.bnd(1).tri, weight,defl(1));
  tmp1   = C21/C11st;

  weight = (vol.cond(2)-vol.cond(3))/((vol.cond(1)+vol.cond(2))*2*pi);
  C12    = bem_Cij_lin(vol.bnd(1).pnt,vol.bnd(2).pnt,vol.bnd(2).tri, weight,defl(2));
  weight = (vol.cond(2)-vol.cond(3))/((vol.cond(2)+vol.cond(3))*2*pi);
  C22st  = bem_Cii_lin(vol.bnd(2).tri,vol.bnd(2).pnt, weight,defl(2),vol.bnd(2).pnt4);
  tmp2   = C12/C22st;

  % Try to spare some memory:
  tmp10 = - tmp2 * C21 + C11st;
  clear C21 C11st
  tmp11 = - tmp1 * C12 + C22st;
  clear C12 C22st
    
  % Combine with the effect of surface 3 (scalp) on the first 2
  %------------------------------------------------------------
  weight = (vol.cond(1)-vol.cond(2))/(vol.cond(3)*2*pi);
  C31    = bem_Cij_lin(vol.bnd(3).pnt,vol.bnd(1).pnt,vol.bnd(1).tri, weight,defl(1));
%   tmp4   = C31/(- tmp2 * C21 + C11st );
%   clear C31 C21 C11st
  tmp4 = C31/tmp10;
  clear C31 tmp10

  weight = (vol.cond(2)-vol.cond(3))/(vol.cond(3)*2*pi);
  C32    = bem_Cij_lin(vol.bnd(3).pnt,vol.bnd(2).pnt,vol.bnd(2).tri, weight,defl(2));
%   tmp3   = C32/(- tmp1 * C12 + C22st );
%   clear  C12 C22st C32
  tmp3 = C32/tmp11;
  clear C32 tmp11

  tmp5 = tmp3*tmp1-tmp4;
  tmp6 = tmp4*tmp2-tmp3;
  clear tmp1 tmp2 tmp3 tmp4

  % Finally include effect of surface 3 on the others
  %--------------------------------------------------
  % As the gama1 intermediate matrix is built as the sum of 3 matrices, I can
  % spare some memory by building them one at a time, and summing directly
  weight = vol.cond(3)/((vol.cond(1)+vol.cond(2))*2*pi);
  Ci3    = bem_Cij_lin(vol.bnd(1).pnt,vol.bnd(3).pnt,vol.bnd(3).tri, weight,defl(3));
  gama1  = - tmp5*Ci3; % gama1 = - tmp5*C13;

  weight = vol.cond(3)/((vol.cond(2)+vol.cond(3))*2*pi);
  Ci3    = bem_Cij_lin(vol.bnd(2).pnt,vol.bnd(3).pnt,vol.bnd(3).tri, weight,defl(3));
  gama1  = gama1 - tmp6*Ci3; % gama1 = - tmp5*C13 - tmp6*C23;

  weight = 1/(2*pi);
  Ci3    = bem_Cii_lin(vol.bnd(3).tri,vol.bnd(3).pnt, weight,defl(3),vol.bnd(3).pnt4);
  gama1  = gama1 - Ci3; % gama1 = - tmp5*C13 - tmp6*C23 - C33st;
  clear Ci3

  % Build system matrix
  %--------------------
  i_gama1 = inv(gama1);
  vol.mat = [i_gama1*tmp5 i_gama1*tmp6 i_gama1];

elseif strcmp(cfg.method, 'openmeeg')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % this uses an implementation that was contributed by INRIA Odyssee Team
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % determine whether the OpenMEEG command-line executables is available
  hastoolbox('openmeeg', 1);
  % use the openmeeg wrapper function
  vol = openmeeg(vol);
  vol.type = 'openmeeg';

else
  error('unsupported method');
end % which method

