% imagesclogy() - make an imagesc(0) plot with log y-axis values (ala semilogy())
%
% Usage:  >> imagesclogy(times,freqs,data,clim);
%
% Input:
%   times = vector of x-axis values
%   freqs = vector of y-axis values (LOG spaced)
%   data  = matrix of size (freqs,times)
%   clim  = optional color limit
%
% Author: Arnaud Delorme, SCCN/INC/UCSD, La Jolla, 4/2003 

% Copyright (C) 4/2003 Arnaud Delorme, SCCN/INC/UCSD, scott@sccn.ucsd.edu
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
% Revision 1.2  2003/04/29 18:30:39  arno
% adding clim
%
% Revision 1.1  2003/04/29 18:27:44  arno
% Initial revision
%

function imagesclogy(times,freqs,data,clim)

  if size(data,1) ~= length(freqs)
      fprintf('logfreq(): data matrix must have %d rows!\n',length(freqs));
      return
  end
  if size(data,2) ~= length(times)
      fprintf('logfreq(): data matrix must have %d columns!\n',length(times));
      return
  end
  if min(freqs)<= 0
      fprintf('logfreq(): frequencies must be > 0!\n');
      return
  end
  
  % problem with log images in Matlab: border are automatically added
  % to account for half of the width of a line: but they are added as
  % if the data was linear. The commands below compensate for this effect
  
  steplog = log(freqs(2))-log(freqs(1)); % same for all points
  realborders = [exp(log(freqs(1))-steplog/2) exp(log(freqs(end))+steplog/2)];
  newfreqs    = linspace(realborders(1), realborders(2), length(freqs));
  
  % regressing 3 times
  border  = mean(newfreqs(2:end)-newfreqs(1:end-1))/2; % automatically added to the borders in imagesc
  newfreqs = linspace(realborders(1)+border, realborders(2)-border, length(freqs));
  border  = mean(newfreqs(2:end)-newfreqs(1:end-1))/2; % automatically added to the borders in imagesc
  newfreqs = linspace(realborders(1)+border, realborders(2)-border, length(freqs));
  border  = mean(newfreqs(2:end)-newfreqs(1:end-1))/2; % automatically added to the borders in imagesc
  newfreqs = linspace(realborders(1)+border, realborders(2)-border, length(freqs));
  
  if nargin == 4
      imagesc(times,newfreqs,data,clim);
  else 
      imagesc(times,newfreqs,data);
  end;
  set(gca, 'yscale', 'log');
  
  % puting labels
  % -------------
  divs = linspace(log(freqs(1)), log(freqs(end)), 10);
  set(gca, 'xtickmode', 'manual');
  divs = ceil(exp(divs)); divs = unique(divs); % ceil is critical here, round might misalign
                                               % out-of border label with within border ticks
  set(gca, 'xtick', divs);
  
