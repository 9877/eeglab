% tftopo()  - Generates a figure showing a selected image (e.g., an ERSP or ITC) from 
%             a supplied set of images for every scalp channel, plus topoplot() scalp 
%             maps at specified (x,y) (e.g., time,frequency) points.  Else, images the 
%             signed (selected) channel std(). Inputs may be outputs of timef(); else,
%             e.g., can be used to image a set of smoothed erpimage() images.
% Usage:
%        >> tftopo(tfdata,times,freqs,timefreqs,showchan,chanlocs,...
%                                                  limits,signifs,selchans)
% Inputs:
%   tfdata    = Set of nchans time/freq ERSPs or ITCs from timef() (or any other
%               time/freq matrix), one for each channel.
%   times     = Vector of times in msec from timef()
%   freqs     = Vector of frequencies in Hz from timef() 
%   timefreqs = Vector of time/frequency points to show topoplot() maps for
%                      Format: size (2,npoints), each row [ms Hz]
%
% Optional inputs:
%   showchan = Channel number of tfdata to image, or 0
%               {default=0 -> image the median-signed st. dev. across channels} 
%   chanlocs = Electrode locations file (for format see >> topoplot example)
%              {default 'chan.locs'}
%   limits   = Vector of plotting limits [minms maxms minhz maxhz mincaxis maxcaxis]
%              Omit, or use nan's to use tfdata limits. Ex: [nan nan -100 400];
%   signifs  = Significance level(s) (e.g., from timef()), for zero'ing non-significant 
%              tfdata {default: none}
%   selchans = Channels to include in topoplot() scalp maps (and image std()) {default: all}
%
% Authors: Scott Makeig & Marissa Westerfield, SCCN/INC/UCSD, La Jolla, 3/01 
%
% See also: spectopo(), timtopo(), envtopo(), changeunits()

% Copyright (C) Scott Makeig & Marissa Westerfield, SCCN/INC/UCSD, La Jolla, 3/01
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
% Revision 1.44  2002/05/19 14:17:55  scott
% *** empty log message ***
%
% Revision 1.43  2002/05/19 14:16:11  scott
% *** empty log message ***
%
% Revision 1.42  2002/05/19 14:15:03  scott
% *** empty log message ***
%
% Revision 1.41  2002/05/19 14:12:53  scott
% *** empty log message ***
%
% Revision 1.40  2002/05/19 14:12:08  scott
% *** empty log message ***
%
% Revision 1.39  2002/05/19 14:07:12  scott
% *** empty log message ***
%
% Revision 1.38  2002/05/19 14:06:40  scott
% *** empty log message ***
%
% Revision 1.37  2002/05/19 14:05:50  scott
% testing -sm
%
% Revision 1.36  2002/05/19 14:00:45  scott
% *** empty log message ***
%
% Revision 1.35  2002/05/19 13:57:54  scott
% *** empty log message ***
%
% Revision 1.34  2002/05/19 13:52:24  scott
% showchans=0 -> image std() of selchans images -sm
%
% Revision 1.33  2002/05/19 13:35:16  scott
% *** empty log message ***
%
% Revision 1.32  2002/05/19 13:34:12  scott
% showchan==0 -> image signed st dev -sm
%
% Revision 1.31  2002/05/19 13:26:10  scott
% adjusted channel label -sm
%
% Revision 1.30  2002/05/19 03:04:46  scott
% *** empty log message ***
%
% Revision 1.29  2002/05/19 02:57:24  scott
% *** empty log message ***
%
% Revision 1.28  2002/05/19 02:55:45  scott
% *** empty log message ***
%
% Revision 1.27  2002/05/19 02:53:45  scott
% *** empty log message ***
%
% Revision 1.26  2002/05/19 02:50:40  scott
% *** empty log message ***
%
% Revision 1.25  2002/05/19 02:28:08  scott
% *** empty log message ***
%
% Revision 1.24  2002/05/19 02:24:15  scott
% *** empty log message ***
%
% Revision 1.23  2002/05/19 02:21:17  scott
% *** empty log message ***
%
% Revision 1.22  2002/05/19 02:20:26  scott
% *** empty log message ***
%
% Revision 1.21  2002/05/19 02:18:36  scott
% *** empty log message ***
%
% Revision 1.20  2002/05/19 02:15:13  scott
% adding separate scale for showchan==0 -sm
%
% Revision 1.19  2002/04/30 21:24:48  scott
% *** empty log message ***
%
% Revision 1.18  2002/04/30 21:23:58  scott
% *** empty log message ***
%
% Revision 1.17  2002/04/30 21:22:46  scott
% *** empty log message ***
%
% Revision 1.16  2002/04/30 21:21:50  scott
% *** empty log message ***
%
% Revision 1.15  2002/04/30 21:21:15  scott
% *** empty log message ***
%
% Revision 1.14  2002/04/30 21:19:05  scott
% debugging sign feature for showchans==0 -sm
%
% Revision 1.13  2002/04/30 21:17:59  scott
% fg
%
% Revision 1.12  2002/04/30 21:17:01  scott
% adding sign -sm
%
% Revision 1.11  2002/04/30 20:53:35  scott
% debugging showchans==0 option -sm
%
% Revision 1.10  2002/04/30 20:47:39  scott
% *** empty log message ***
%
% Revision 1.9  2002/04/30 20:45:56  scott
% showchan==0 -> blockave(abs(tfdata)) -sm
%
% Revision 1.8  2002/04/27 01:37:19  scott
% same -sm
%
% Revision 1.7  2002/04/27 01:26:40  scott
% updated topoplot call -sm
%
% Revision 1.6  2002/04/27 01:19:33  scott
% same -sm
%
% Revision 1.5  2002/04/27 01:13:46  scott
% same -sm
%
% Revision 1.4  2002/04/27 01:10:29  scott
% same -sm
%
% Revision 1.3  2002/04/27 01:06:00  scott
% same -sm
%
% Revision 1.2  2002/04/27 01:04:12  scott
% added handling of 3-d tftopo data -sm
%
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 01-25-02 reformated help & license -ad 

function tftopo(tfdata,times,freqs,timefreqs,showchan,chanlocs,limits,signifs,selchans)

LINECOLOR= 'k';
LINEWIDTH = 2.5;
ZEROLINEWIDTH = 2.8;

if nargin<4
   help tftopo
   return
end
if nargin<9
  selchans = 0;
end

% default: don't define nargin(8), selchans 

if nargin<7
  limits = [nan nan nan nan nan nan];
end
if nargin<6
  chanlocs = 'chan.locs';  % default channel locations file
end
if nargin<5
  showchan = 0; % default tfdata image to show
end
if isempty(showchan)
  showchan=0;
end

if length(size(tfdata))==2
   nchans = round(size(tfdata,2)/length(times));
elseif length(size(tfdata))==3
   nchans = size(tfdata,3);
   tfdata=tfdata(:,:); % convert to 2-d
else
   help tftopo
   return
end
if nchans*length(times) ~= size(tfdata,2)
   fprintf('tftopo(): tfdata columns must be a multiple of the length of times (%d)\n',...
                 length(times));
   return
end
if showchan> nchans | showchan < 0
   fprintf('tftopo(): showchan (%d) must be <= nchans (%d)\n',showchan,nchans);
   return
end
if selchans==0
  selchans = 1:nchans;
end

if length(limits)<1 | isnan(limits(1))
  limits(1) = times(1);
end
if length(limits)<2 | isnan(limits(2))
  limits(2) = times(end);
end
if length(limits)<3 | isnan(limits(3))
  limits(3) = freqs(1);
end
if length(limits)<4 | isnan(limits(4))
  limits(4) = freqs(end);
end
if length(limits)<5 | isnan(limits(5)) % default caxis plotting limits
  limits(5) = -max(max(abs(tfdata)));
  mincax = limits(5); 
end
if length(limits)<6 | isnan(limits(6))
  if exist('mincax')
    limits(6) = -mincax; % avoid recalculation
  else
    limits(6) = max(max(abs(tfdata)));
  end
end

if exist('signifs') & length(signifs) == 1 % should be ITC
   signifs = [0 signifs];
end
  
if min(timefreqs(:,2))<0
   fprintf('tftopo(): timefreqs frequencies must be >=0 Hz\n');
   return
end
nchans = size(tfdata,2)/length(times);

if 0 % USE USER-SUPPLIED SCALP MAP ORDER. A GOOD ALGORITHM FOR SELECTING
     % timefreqs POINT ORDER GIVING MAX UNCROSSED LINES IS DIFFICULT!
  [tmp tfi] = sort(timefreqs(:,1)); % sort on times
  tmp = timefreqs;
  for t=1:size(timefreqs,1)
      timefreqs(t,:) = tmp(tfi(t),:);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute timefreqs point indices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tfpoints = size(timefreqs,1);
freqidx = zeros(1,tfpoints);
for f=1:tfpoints
   [tmp fi] = min(abs(freqs-timefreqs(f,2)));
   freqidx(f)=fi;
end
timeidx = zeros(1,tfpoints);
for f=1:tfpoints
   [tmp fi] = min(abs(times-timefreqs(f,1)));
   timeidx(f)=fi;
end
tfpidx = [timeidx' freqidx'];

%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjust plotting limits
%%%%%%%%%%%%%%%%%%%%%%%%%
[tmp minfreqidx] = min(abs(limits(3)-freqs)); % adjust min frequency
 limits(3) = freqs(minfreqidx);
[tmp maxfreqidx] = min(abs(limits(4)-freqs)); % adjust max frequency
 limits(4) = freqs(maxfreqidx);

[tmp mintimeidx] = min(abs(limits(1)-times)); % adjust min time
 limits(1) = times(mintimeidx);
[tmp maxtimeidx] = min(abs(limits(2)-times)); % adjust max time
 limits(2) = times(maxtimeidx);

mmidx = [mintimeidx maxtimeidx minfreqidx maxfreqidx];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Zero out non-significant image features ?????????????
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
range = limits(6)-limits(5);
colormap('jet');
c = colormap;
cc = zeros(256,3);
if size(c,1)==64
    for i=1:3
       cc(:,i) = interp(c(:,i),4);
    end
else
    cc=c;
end
cc(find(cc<0))=0;
cc(find(cc>1))=1;

if exist('signifs')
  minnull = round(256*(signifs(1)-limits(5))/range)
  if minnull<1
    minnull = 1;
  end
  maxnull = round(256*(signifs(2)-limits(5))/range)
  if maxnull>256
    maxnull = 256;
  end
  nullrange = minnull:maxnull;
  cc(nullrange,:) = repmat(cc(128,:),length(nullrange),1);
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot tfdata image for specified channel or selchans std()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure;
colormap(cc);
plotdim = 1+floor(tfpoints/2); % number of topoplots on top of image
imgax = sbplot(plotdim,plotdim,[plotdim*(plotdim-1)+1,2*plotdim-1]);

if showchan>0 % -> image showchan data
  imagesc(times(mmidx(1):mmidx(2)),freqs(mmidx(3):mmidx(4)),...
    matsel(tfdata,length(times),mmidx(1):mmidx(2),mmidx(3):mmidx(4),showchan));
  axis([limits(1:4)]);
  caxis([limits(5:6)]);
  hold on;

else % showchan==0 -> image std() of selchans
  tftimes = mmidx(1):mmidx(2);
  tffreqs = mmidx(3):mmidx(4);
  tfdat = matsel(tfdata,...
            length(times),...
              tftimes,...             
                tffreqs,...
                  selchans);

  tfdat = reshape(tfdat,length(tffreqs),length(tftimes),nchans);
  tfsign = sort(tfdat,3);
  tfsign = sign(tfsign(:,:,round(nchans/2)));

  if exist('std')==2
     tfave = tfsign.*std(abs(tfdat),1,3);
  else
     tfave = tfsign.*mean(abs(tfdat),3); % use mean() if std() not in search path
  end
  cmax = max(max(abs(tfave)));
  cmin = -cmax; % make symmetrical
  imagesc(times(tftimes),freqs(tffreqs),tfave);
  axis([limits(1:4)]);
  caxis([cmin cmax]);
  hold on;
end
axes(imgax)
xl=xlabel('Time (ms)');
set(xl,'fontsize',16);
set(gca,'yaxislocation','left')
if showchan>0
   % tl=title(['Channel ',int2str(showchan)]);
else
  if exist('std')==2
   tl=title(['Signed channel st. dev.']);
  else
   tl=title(['Signed channel mean']);
  end
end
set(tl,'fontsize',14);

yl=ylabel(['Frequency (Hz)']);
set(yl,'fontsize',16);

set(gca,'fontsize',14)
set(gca,'ydir','normal');

if min(times)<0 & max(times)>0
  plot([0 0],[freqs(1) freqs(end)],[LINECOLOR ':'],'linewidth',ZEROLINEWIDTH);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot topoplot maps at specified timefreqs points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wholeax  = sbplot(1,1,1);
topoaxes = zeros(1,tfpoints);
for n=1:tfpoints
   if n<=plotdim
      topoaxes(n)=sbplot(plotdim,plotdim,n);
   else
      topoaxes(n)=sbplot(plotdim,plotdim,plotdim*(n+1-plotdim));
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Plot connecting lines using changeunits()
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   from = changeunits([timefreqs(n,:)],imgax,wholeax);
   to   = changeunits([0.5,0.5],topoaxes(n),wholeax);
   axes(wholeax);
   plot([from(1) to(1)],[from(2) to(2)],LINECOLOR,'linewidth',LINEWIDTH);
   hold on
   mk=plot(from(1),from(2),[LINECOLOR 'o'],'markersize',9);
   set(mk,'markerfacecolor',LINECOLOR);
   axis([0 1 0 1]);
   axis off;
   drawnow
end

for n=1:tfpoints
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Plot scalp map using topoplot()
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   axes(topoaxes(n));
   scalpmap = matsel(tfdata,length(times),tfpidx(n,1),tfpidx(n,2),selchans)';
   topoplot(scalpmap,chanlocs,'maplimits',[limits(5) limits(6)],...
               'electrodes','on','shrink','off');
               % 'interlimits','electrodes')
   axis square;
   hold on
   tl=title([int2str(timefreqs(n,1)),' ms, ',int2str(timefreqs(n,2)),' Hz']);
   set(tl,'fontsize',13);
   caxis([limits(5:6)]);

   if n==tfpoints % & (mod(tfpoints,2)~=0) % image color bar by last map
      cb=cbar;
      pos = get(cb,'position');
      set(cb,'position',[pos(1:2) 0.023 pos(4)]);
   end
end

if showchan>0
     sbplot(4,4,1,'ax',imgax);
     topoplot(showchan,chanlocs,'electrodes','off', ...
                  'style', 'blank', 'emarkersize1chan', 10)
     axis('square')
end



% end % topoplot loop

