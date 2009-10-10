function s = spearman_binned(cfg, dat, design)

%SPEARMAN_BINNED computes the rank-correlation coefficient
%between two variables in different conditions as labeled by
%design

%The input-data should be formatted as follows:
% first dimension : signals (or signal-combinations)
% second dimension: repetitions
% third dimension : frequencies (optional), or the two signals which will be correlated
% fourth dimension (optional): the two signals which will be correlated
% the last dimension should have length two, since this dimension contains the two variables 
% that are to be rank-correlated

%$Log: not supported by cvs2svn $
%Revision 1.3  2006/10/04 06:59:58  roboos
%renamed th eoption cfg.factor into ivar
%
%Revision 1.2  2006/04/12 12:48:38  roboos
%renamed cfg.randomfactor=>cfg.factor
%
%Revision 1.1  2006/01/05 15:41:36  jansch
%first implementation, to be called by statistics_random.m
%

if ~isfield(cfg, 'factor') & prod(size(design)) ~= max(size(design)),
  error('cannot determine the labeling of the trials');
elseif ~isfield(cfg, 'factor')
  cfg.ivar = 1;
end

nsgn = size(dat,1);
nrpt = size(dat,2);
if length(size(dat))==3,
  nfrq = 1;
  n    = size(dat,3);
elseif length(size(dat))==4,
  nfrq = size(dat,3);
  n    = size(dat,4);
end

if n ~= 2,
 error('the last dimension of the input should be 2');
end

cnd  = unique(design(cfg.ivar, :));
ncnd = length(cnd);


for k = 1:nsgn
  for j = 1:nfrq
    for m = 1:ncnd
      sel                = find(design(cfg.ivar, :) == cnd(m));
      dumdat             = squeeze(dat(k, sel, j, :));
      [srt, ind]         = sort(dumdat); 
      dumdat(ind(:,1),1) = [1:size(dumdat,1)]'; %do the rank-transformation
      dumdat(ind(:,2),2) = [1:size(dumdat,1)]';
      denom              = size(dumdat,1) * (size(dumdat,1)^2-1) / 6;
      rcc(k, j, m)       = 1 - sum(diff(dumdat, [], 2).^2) / denom;
    end
  end
end

s = rcc;

