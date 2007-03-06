% movav() - Perform a moving average of data indexed by xvals.
%           Supports use of a moving non-rectangular window.
%           Can be used to resample a data matrix to any size 
%           (see xadv NOTE below) and to regularize sampling of 
%           irregularly sampled data.
% Usage:
%  >> [outdata,outx] = movav(data,xvals,xwidth,xadv,firstx,lastx,xwin,nonorm);
%
% Input:
%   data   = input data (chans,frames)
%
% Optional inputs:
%   xvals  = increasing x-values for data frames (columnsa). The default 
%            [1:frames] is fastest {def|[]|0 -> 1:frames}
%   xwidth = smoothing-window width in xvals units {def|0->(hix-lox)/4}
%   xadv   = window step size in xvals units. NOTE: To reduce yyy frames 
%            to about xxx, xadv needs to be near yyy/xxx {default|0 -> 1}
%   firstx = low xval of first averaging window {def|[] -> min xvals}
%   lastx  = high xval of last averaging window {def|[] -> max xvals}
%   xwin   = vector of window values {def|0 -> ones() = square window}
%            May be long. NOTE: linear interp. is NOT used between values.
%            Example: gauss(1001,2) ->  [0.018 ... 1.0 ... 0.018]
%   nonorm = [1|0] If non-zero, do not normalize the moving sum. If
%            all y values are 1s. this creates a moving histogram. 
%            Ex: >> [oy,ox] = movav(ones(size(x)),x,xwd,xadv,[],[],0,1);
%            returns a moving histogram of xvals {default: 0}
% Outputs:
%   outdata = smoothed output data (chans,outframes)
%   outx    = xval midpoints of successive output windows
%
% Author: Scott Makeig, SCCN/INC/UCSD, La Jolla, 10-25-97 

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 10-25-97 Scott Makeig, SCCN/INC/UCSD, scott@sccn.ucsd.edu
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
% Revision 1.23  2007/03/05 15:33:46  scott
% implemented AG fix is sum(xwin) is near zero -sm
%
% Revision 1.22  2007/03/05 15:17:56  scott
% nelem() -> numel()
%
% Revision 1.21  2007/03/05 15:15:51  scott
% nothing
%
% Revision 1.20  2006/11/04 03:04:20  scott
% help msg calrification
%
% Revision 1.19  2006/07/26 03:37:25  toby
% change to outframes to choose an optimal number, was sometimes losing the last possible.
%
% Revision 1.18  2005/11/07 19:25:40  scott
% turned off debug and verbose flags -sm
%
% Revision 1.17  2005/11/07 19:25:14  scott
% debugged nonorm -sm
%
% Revision 1.16  2005/11/07 19:03:58  scott
% added nonorm option -sm
%
% Revision 1.15  2005/05/28 21:09:24  scott
% fixed 'fastave' bug
%
% Revision 1.14  2003/11/18 17:50:49  arno
% remove nanmean and nansum
%
% Revision 1.13  2002/10/21 00:17:23  arno
% updating default fisrtx and lastx input to allow for 0 latency (before 0=use default)
%
% Revision 1.12  2002/05/23 17:33:59  scott
% adjusting verbose output -sm
%
% Revision 1.11  2002/05/23 17:32:42  scott
% *** empty log message ***
%
% Revision 1.10  2002/05/23 17:30:20  scott
% *** empty log message ***
%
% Revision 1.9  2002/05/23 17:29:32  scott
% *** empty log message ***
%
% Revision 1.8  2002/05/23 17:27:56  scott
% allow []=default args -sm
%
% Revision 1.7  2002/05/23 17:24:13  scott
% *** empty log message ***
%
% Revision 1.6  2002/05/23 17:20:59  scott
% *** empty log message ***
%
% Revision 1.5  2002/05/23 17:19:21  scott
% *** empty log message ***
%
% Revision 1.4  2002/05/23 17:18:21  scott
% adjust default 'xvals' -sm
%
% Revision 1.3  2002/05/23 17:06:00  scott
% *** empty log message ***
%
% Revision 1.2  2002/05/23 17:03:41  scott
% added alternate functions nan_mean() and nan_sum() -sm
%
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 3-20-98 fixed bug in multi-channel windowed averaging -sm
% 6-10-98 changed mean() and sum() to nanmean() and nansum() -sm
% 2-16-99 tested for stat toolbox functions nanmean() and nansum() -sm
% 9-03-01 fixed gauss() example -sm
% 01-25-02 reformated help & licenses -ad 

function [outdata,outx] = movav(data,xvals,xwidth,xadv,firstx,lastx,xwin,nonorm)

MAXPRINT = 1; % max outframe numbers to print on tty
NEARZERO = 1e-22;
DEFAULT_XADV = 1; % default x window advance
verbose = 0;  % If 1, output process info
debugit = 0;  % If 1, output more process info

nanexist = 0;  
if nargin<1
   help movav
   return
else
  [chans,frames]=size(data);
end
if chans>1 & frames == 1,
  data   = data';   % make row vector
  tmp    = chans;
  chans  = frames;
  frames = tmp;
end
if frames < 4
  error('data are too short');
  return
end

flag_fastave = 0;
if nargin<2 | isempty(xvals) | (numel(xvals)==1 & xvals == 0)
  xvals = 1:frames; % flag default xvals
  flag_fastave = 0;
end
if size(xvals,1)>1 & size(xvals,2)>1
  error('xvals must be a vector');
end
xvals = xvals(:)'; % make xvals a row vector

if frames ~= length(xvals) 
    error('lengths of xvals and data not equal');
end

if nargin < 8 | isempty(nonorm)
  nonorm = 0;  % default -> return moving mean
end
if abs(nonorm) > NEARZERO
   nonorm = 1;
end

if nargin < 7 | isempty(xwin)
  xwin = 0;
end

if nargin < 6 | isempty(lastx)
  lastx = [];
end
if isempty(lastx),
  if flag_fastave
    lastx = frames;
  else
    lastx = max(xvals);
  end
end

if nargin<5 | isempty(firstx)
  firstx = [];
end
if isempty(firstx),
  if flag_fastave
    firstx = 1;
  else
    firstx = min(xvals);
  end
end

if nargin<4 | isempty(xadv)
  xadv = 0;
end
if isempty(xadv) | xadv == 0,
  xadv = DEFAULT_XADV;
end

if nargin<3 | isempty(xwidth) | xwidth==0
  xwidth = (lastx-firstx)/4;  % DEFAULT XWIDTH
end

wlen = 1;  % default;
if flag_fastave==0
  if length(xwin)==1 & xwin ~=0,  % should be a vector or 0
    error('xwin not vector or 0');
  elseif size(xwin,1)>1 & size(xwin,2)>1 % not a matrix
    error('xwin cannot be a matrix'); 
  end
  if size(xwin,1)>1
    xwin = xwin';   % make row vector
  end

  if xwin~=0
    if abs(sum(xwin)) < NEARZERO
      fprintf('\nmovav(): abs(sum(xwin)) too small. Cannot normalize.\n');
    else
      xwin = xwin/abs(sum(xwin)); % make xwin values sum to 1;
    end
    wlen = length(xwin);
  end
end

%outframes = floor(0.99999+((lastx-firstx+xadv)-xwidth)/xadv);
outframes = floor(((lastx-firstx+xadv+1)-xwidth)/xadv);
if verbose
  fprintf('movav() will output %d frames.\n',outframes);
end
if outframes < 1,
   outframes = 1;
end
outdata = zeros(chans,outframes);
outx = zeros(1,outframes);
outxval = firstx+xwidth/2;
%
%%%%%%%%%%%%%%%%%%%%%% Print header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if verbose,
  fprintf('Performing moving averaging:\n')
  fprintf('Output will be %d chans by %d frames',chans,outframes);
  if wlen>1,
    fprintf(' using the specified width-%d window.\n',wlen);
  else
    fprintf(' using a width-%d square window.\n',xwidth);
  end
end
if debugit
   fprintf('   firstx = %g, lastx= %g, xwidth = %g xadv = %g\n',...
                   firstx,lastx,xwidth,xadv);
end
%
%%%%%%%%%%%%%%%%%%% Perform averaging %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
lox = firstx;
i = 0; % flag_fastave default
for f=1:outframes
   hix = lox+xwidth;
   outx(1,f)=outxval;
   outxval = outxval + xadv;
   if flag_fastave == 0 
      i = find(xvals>=lox & xvals < hix);
   end
   if length(i)==0,
      if f>1,
       outdata(:,f) = outdata(:,f-1); % If no data, replicate
       if debugit,
          fprintf('r');
       end
      else
       outdata(:,f) = zeros(chans,1); %  or else output zeros
       if debugit
         fprintf('0');
       end
      end
   elseif length(xwin)==1,
      if flag_fastave > 0
          outdata(:,f) = nan_mean(data(:,round(lox):round(hix))')'; 
          nix = length([round(lox):round(hix)]);
      else
          outdata(:,f) = nan_mean(data(:,i)')'; % Else average
          nix = length(i);
      end
      if nonorm & nix % undo division by number of elements summed
          outdata(:,f) = outdata(:,f)*nix;
      if debugit, fprintf('n'); end;
      end
      if debugit, fprintf('.'); end;
%
%%%%%%%%%%%%%%%%% Windowed averaging %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
   else % length(xwin) > 1
       if debugit
         fprintf('i %g, f %g\n',i,f);
       end
       wadv=(hix-lox)/wlen;
       ix = ceil((xvals(i)-lox)/wadv);
       zs = find(ix==0);
       ix(zs) = ones(1,zs); % ????????????????
       if length(xwin)>1
          sumx = sum(xwin(ix));
       else
          sumx=1;
       end
       if abs(sumx) < NEARZERO  % cannot normalize

         outdata(:,f) = nan_sum((((ones(chans,1)*xwin(ix)).*data(:,i)))')';
          % AG fix 3/5/07

       else % normalize
         outdata(:,f) = nan_sum((((ones(chans,1)*xwin(ix)).*data(:,i))/sumx)')'; 
       end 
       if nonorm & length(ix) % undo division by number of elements summed
         outdata(:,f) = outdata(:,f)*sumx;
         if debugit, fprintf('n'); end;
       end
   end
   lox = lox+xadv;
   if (outframes<MAXPRINT) 
      fprintf('%d ',f);
   end
end
if verbose,
  fprintf('\n');
end

%
%%%%%%%%%%%%%%%%%%%%%%% function nan_mean() %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% nan_mean() - take the column means of a matrix, ignoring NaN values
%
function out = nan_mean(in)

   nans = find(isnan(in));
   in(nans) = 0;
   sums = sum(in);
   nonnans = ones(size(in));
   nonnans(nans) = 0;
   nonnans = sum(nonnans,1);
   nononnans = find(nonnans==0);
   nonnans(nononnans) = 1;
   out = sum(in,1)./nonnans;
   out(nononnans) = NaN;

%
%%%%%%%%%%%%%%%%%%%%%%% function nan_sum() %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% nan_sum() - take the column sums of a matrix, ignoring NaN values
%
function out = nan_sum(in)

   nans = find(isnan(in));
   in(nans) = 0;
   out = sum(in,1);

   nonnans = ones(size(in));
   nonnans(nans) = 0;
   nonnans = sum(nonnans,1);
   nononnans = find(nonnans==0);
   out(nononnans) = NaN;
