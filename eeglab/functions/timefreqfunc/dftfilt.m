% dftfilt() - discrete Fourier filter
%
% Usage:
%   >> b = dftfilt(n,W,c,k,q)
%
% Inputs:
%   n - number of input samples
%   W - maximum angular freq. relative to n, 0 < W <= .5
%   c - cycles
%   k - oversampling
%   q - [0;1] 0->fft, 1->c cycles
%
% Authors: Sigurd Enghoff & Scott Makeig, SCCN/INC/UCSD, La Jolla, 8/1/98

% Copyright (C) 8/1/98 Sigurd Enghoff & Scott Makei, SCCN/INC/UCSD, scott@sccn.ucsd.edu
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
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 01-25-02 reformated help & license -ad 

function b = dftfilt(len,maxfreq,cycle,oversmp,wavfact)

srate = 2*pi/len;						    % Angular increment.
w = j * cycle * [0:srate:2*pi-srate/2]';	% Column.
x = 1:1/oversmp:maxfreq*len/cycle;		    % Row.
b = exp(-w*x);					            % Exponentiation of outer product.

for i = 1:size(b,2),
	m  = round(wavfact*len*(i-1)/(i+oversmp-1));	% Number of elements to discard.
	mu = round(m/2);				                % Number of upper elemnts.
	ml = m-round(m/2);				                % Number of lower elemnts.
	b(:,i) = b(:,i) .* [zeros(mu,1) ; hanning(len-m) ; zeros(ml,1)];
end
