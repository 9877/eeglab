function [dat, w] = preproc_denoise(dat, refdat, hilbertflag)

% PREPROC_DENOISE performs a regression of the matrix dat onto
% refdat, and subtracts the projected data. Tis is for the 
% purpose of removing signals generated by coils during continuous
% head motion tracking, for exxample.
%
% Use as
%   [dat] = preproc_denoise(dat, refdat, hilbertflag)
% where
%   dat         data matrix (Nchan1 X Ntime)
%   refdat      data matrix (Nchan2 X Ntime)
%   hilbertflag specifying to regress out the real and imaginary parts of 
%                 the hilbert transformed signal. Only meaningful for narrow
%                 band reference data
%
% See also PREPROC

% Copyright (C) 2009, Jan-Mathijs Schoffelen
%
% $Log: not supported by cvs2svn $
% Revision 1.1  2009/03/13 13:32:50  jansch
% first commitment into cvs
%

if nargin<3,
  hilbertflag = 0;
end

n1 = size(dat,2);
n2 = size(refdat,2);
m1 = mean(dat,2);
m2 = mean(refdat,2);

%remove mean
refdat  = refdat-m2(:,ones(n2,1));
tmpdat  = dat-m1(:,ones(n1,1));

%do hilbert transformation
if hilbertflag>0,
  hrefdat = hilbert(refdat')';
  refdat  = [real(hrefdat);imag(hrefdat)];
end

c12 = tmpdat*refdat'; %covariance between signals and references
c1  = refdat*refdat'; %covariance between references and references
w   = (pinv(c1)*c12')'; %regression weights

%subtract
dat = dat-w*refdat;