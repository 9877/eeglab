% spectopo() - Plot the mean log spectrum of a set of data epochs at
%              all channels as a bundle of traces. At specified frequencies,
%              plot the relative topographic distribution of power.
%              Uses Matlab psd() from signal processing toolbox.
% Usage:
%        >> [spectra,freqs] = spectopo(data, frames, srate, 'key1', 'val1' ...
%                                                           'key2', 'val2' ...);
%
% Inputs:
%       data   = 2D (nchans,frames*epochs); % can be single-epoch
%                 or 3D (nbchan,frames,epochs)
%       frames = frames per epoch {0 -> data length}
%       srate  = sampling rate per channel (Hz)
%
% Optional inputs:
%   'freq'     = [float vector (Hz)] vector of frequencies for topoplot() scalp maps
%                of power at all channels, or single frequency to plot component 
%                contributions at a single channel ('plotchan').
%   'chanlocs' = electrode locations file (format: >> topoplot example)
%   'limits'   = axis limits [xmin xmax ymin ymax cmin cmax]
%                To use data limtis, omit final values or use nan's
%                i.e. [-100 900 nan nan -10 10], [-100 900]
%                Note that default color limits are symmetric around 0 and are
%                different for each head {defaults: all nans}
%   'title'    = [quoted string] plot title {default: none}
%   'freqfac'  = [int power of 2] approximate frequencies/Hz to compute {default: 4}
%   'percent'  = downsampling factor or approximate percentage of the data to
%                keep while computing spectra. Downsampling can be used to speed up
%                the computation. From 0 to 100 {default: 100}.
%   'reref'    = ['averef'|'off'] convert input data to average reference 
%                Default is 'off'. 
%
% Plot component contributions:
%   'weights'  = ICA unmixing matrix. 'freq' must contain a single frequency.
%                ICA maps of the N (='nicamaps') components that account for the most
%                power at the selected frequency ('freq') are plotted along with
%                the spectra of the selected channel ('plotchan') and components
%                ('icacomps').
%   'plotchan' = [integer] channel at which to compute independent conmponent
%                contributions at the selected frequency ('freq'). {[]=channel with
%                higest power at 'freq').If 0, plot RMS power at all channels. 
%   'nicamaps' = [integer] number of ICA component maps to plot (Default 4).
%   'icacomps' = [integer array] indices of ICA component spectra to plot ([]=all).
%   'icamaps'  = [integer array] force plotting of selected ica compoment maps ([]=the
%                'nicamaps' largest).
%
% Topoplot options:
%    opther 'key','val' options are propagated to topoplot() for map display
%    (see help topoplot())
%
% Outputs:
%        spectra = (nchans,nfreqs) power spectra (average over epochs) in dB
%        freqs   = frequencies of spectra (Hz)
%
% Notes: The old function call is still function for backward compatibility
%        >> [spectra,freqs] = spectopo(data, frames, srate, headfreqs, ...
%                               chanlocs, limits, titl, freqfac, percent);
%
% Authors: Scott Makeig, Arnaud Delorme & Marissa Westerfield, 
%          SCCN/INC/UCSD, La Jolla, 3/01 
%
% See also: timtopo(), envtopo(), tftopo(), topoplot()

% Copyright (C) 3/01 Scott Makeig & Marissa Westerfield, SCCN/INC/UCSD, 
% scott@sccn.ucsd.edu
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
% Revision 1.8  2002/07/20 01:17:10  arno
% new version with component plotting options
%
% Revision 1.7  2002/07/18 16:00:46  arno
% adding option for not plotting channels
%
% Revision 1.6  2002/07/07 22:44:49  scott
% *** empty log message ***
%
% Revision 1.5  2002/07/07 22:42:17  scott
% help msg -sm
%
% Revision 1.4  2002/07/07 22:38:27  scott
% adding 'reref','averef' option -sm
%
% Revision 1.3  2002/04/21 00:38:25  scott
% 'Selecting randomly' -> 'Randomly selecting' -sm
%
% Revision 1.2  2002/04/18 18:19:28  arno
% adding 3D option
%
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 3-20-01 added limits arg -sm
% 01-25-02 reformated help & license -ad 
% 02-15-02 scaling by epoch number line 108 - ad, sm & lf
% 03-15-02 add all topoplot options -ad
% 03-18-02 downsampling factor to speed up computation -ad
% 03-27-02 downsampling factor exact calculation -ad
% 04-03-02 added axcopy -sm

% Uses: MATLAB psd(), changeunits(), topoplot(), textsc()

function [eegspecdB,freqs]=spectopo(data,frames,srate,varargin) 
	%headfreqs,chanlocs,limits,titl,freqfac, percent, varargin)

LOPLOTHZ = 1;  % low  Hz to plot
FREQFAC  = 4;  % approximate frequencies/Hz (default)

if nargin<3
   help spectopo
   return
end
if nargin <= 3 | isstr(varargin{1})
	% 'key' 'val' sequency
	fieldlist = { 'freq'         'real'     []                       [] ;
				  'chanlocs'      ''         []                       [] ;
				  'title'         'string'   []                       '';
				  'limits'        'real'     []                       [nan nan nan nan nan nan];
				  'freqfac'       'integer'  []                        FREQFAC;
				  'percent'       'real'     [0 100]                  100 ;
				  'reref'         'string'   { 'averef' 'no' }         'no' ;
				  'weights'       'real'     []                       [] ;
				  'plotchan'      'integer'  [1:size(data,1)]         [] ;
				  'nicamaps'      'integer'  []                       4 ;
				  'icacomps'      'integer'  []                       [] ;
				  'icamaps'       'integer'  []                       [] };
	
	[g varargin] = finputcheck( varargin, fieldlist, 'spectopo', 'ignoreextras');
	if isstr(g), error(g); end;
else
	if nargin > 3,    g.freq = varargin{1};
	else              g.freq = [];
	end;
	if nargin > 4,	  g.chanlocs = varargin{2};
	else              g.chanlocs = [];
	end;
	if nargin > 5,    g.limits = varargin{3};
	else              g.limits = [nan nan nan nan nan nan];
	end;
	if nargin > 6,    g.title = varargin{4};
	else              g.title = '';
	end;
	if nargin > 7,    g.freqfac = varargin{5};
	else              g.freqfac = FREQFAC;
	end;
	if nargin > 8,    g.percent = varargin{6}*100;
	else              g.percent = 100;
	end;
	if nargin > 10,    g.reref = 'averef';
	else               g.reref = 'no';
	end;
	g.weights = [];
	g.icamaps = [];
end;
g.percent = g.percent/100; % make it from 0 to 1

data = reshape(data, size(data,1), size(data,2)*size(data,3));
if frames == 0
  frames = size(data,2); % assume one epoch
end

if ~isempty(g.freq) & min(g.freq)<0
   fprintf('spectopo(): freqs must be >=0 Hz\n');
   return
end
epochs = round(size(data,2)/frames);
if frames*epochs ~= size(data,2)
   error('Spectopo: non-integer number of epochs');
end
if ~isempty(g.weights)
	g.icawinv = pinv(g.weights); % maps
	if ~isempty(g.icacomps)
		g.weights = g.weights(g.icacomps, :);
		g.icawinv = g.icawinv(:,g.icacomps);
	else 
		g.icacomps = [1:size(g.weights,1)];
	end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute channel spectra using psd()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
epoch_subset = 1:epochs;
if g.percent ~= 1 & epochs > 1
    nb = round( g.percent*epochs);
    epoch_subset = zeros(1,epochs);
    while nb>0
        index = ceil(rand*epochs);
        if ~epoch_subset(index)
            epoch_subset(index) = 1;
            nb = nb-1;
        end;
    end;        
    epoch_subset = find(epoch_subset == 1);
    fprintf('Randomly selecting %d of %d data epochs for analysis...\n', length(epoch_subset),epochs);
end;
if isempty(g.weights)
	% computing data spectrum
	fprintf('Computing spectra: ')
	[eegspecdB freqs] = spectcomp( data, frames, srate, epoch_subset, g);
	fprintf('\n');
else
	% computing data spectrum
	if isempty(g.plotchan) | g.plotchan == 0
		fprintf('Computing spectra: ')
		[eegspecdB freqs] = spectcomp( data, frames, srate, epoch_subset, g);
		fprintf('\n');
	else
		fprintf('Computing spectra at specified channel: ')
		[eegspecdB freqs] = spectcomp( data(g.plotchan,:), frames, srate, epoch_subset, g);
		fprintf('\n');
	end;
	
	% selecting channel and spectrum
	if isempty(g.plotchan) % find channel of minimum power
		[tmp indexfreq] = min(abs(g.freq-freqs));
		[tmp g.plotchan] = min(eegspecdB(:,indexfreq));
		fprintf('Maximum power found at channel %d\n', g.plotchan);
	end;
	if g.plotchan == 0
		fprintf('Averaging power at all channels\n');
		eegspecdBtoplot = mean(eegspecdB, 1);
	else 
		eegspecdBtoplot = eegspecdB(g.plotchan, :);
	end;
	
	% computing component spectra
	fprintf('Computing spectra: ')
	[compeegspecdB freqs] = spectcomp( g.weights*data, frames, srate, epoch_subset, g);
	fprintf('\n');
	
	% selecting components to plot
	if isempty(g.icamaps)
		% weight power by channel projection weight
		if g.plotchan == 0
			compeegspecdB = repmat(mean(g.weights, [1 size(compeegspecdB,2)])) .* compeegspecdB;
		else
			compeegspecdB = repmat(g.weights(:,g.plotchan), [1 size(compeegspecdB,2)]) .* compeegspecdB;
		end;
		
		[tmp indexfreq] = min(abs(g.freq-freqs));
		g.icafreqsval   = compeegspecdB(:, indexfreq);
		[g.icafreqsval g.icamaps] = sort(g.icafreqsval);
		g.icamaps = g.icamaps(end:-1:1);
		if g.nicamaps < length(g.icamaps), g.icamaps = g.icamaps(1:g.nicamaps); end;
	else 
		[tmp indexfreq] = min(abs(g.freq-freqs));
		g.icafreqsval   = compeegspecdB(g.icamaps, indexfreq);
	end;
end;
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute axis and caxis g.limits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(g.limits)<1 | isnan(g.limits(1))
   g.limits(1) = LOPLOTHZ;
end

if ~isempty(g.freq)
	if length(g.limits)<2 | isnan(g.limits(2))
		maxheadfreq = max(g.freq);
		if rem(maxheadfreq,5) ~= 0
			g.limits(2) = 5*ceil(maxheadfreq/5);
		else
			g.limits(2) = maxheadfreq*1.1;
		end
	end
	
	g.freq = sort(g.freq);          % Determine topoplot frequencies
	freqidx = zeros(1,length(g.freq)); % Do not interpolate between freqs
	for f=1:length(g.freq)
		[tmp fi] = min(abs(freqs-g.freq(f)));
		freqidx(f)=fi;
	end
else 
	g.limits(2) = 50;
end;

[tmp maxfreqidx] = min(abs(g.limits(2)-freqs)); % adjust max frequency
[tmp minfreqidx] = min(abs(g.limits(1)-freqs)); % adjust min frequency

if length(g.limits)<3|isnan(g.limits(3))
  g.limits(3) = min(min(eegspecdB(:,minfreqidx:maxfreqidx)));
end
if length(g.limits)<4|isnan(g.limits(4))
  g.limits(4) = max(max(eegspecdB(:,minfreqidx:maxfreqidx)));
end
dBrange = g.limits(4)-g.limits(3);   % expand range a bit beyond data g.limits
g.limits(3) = g.limits(3)-dBrange/7;
g.limits(4) = g.limits(4)+dBrange/7;

if length(g.limits)<5 % default caxis plotting g.limits
  g.limits(5) = nan;
end
if length(g.limits)<6 
  g.limits(6) = nan;
end

if isnan(g.limits(5))+isnan(g.limits(6)) == 1
   fprintf('spectopo(): limits 5 and 6 must either be given or nan\n');
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot spectrum of each channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(g.freq)
	specaxes = sbplot(3,4,[5 12]); 
end;

if isempty(g.weights)
	pl=plot(freqs(1:maxfreqidx),eegspecdB(:,1:maxfreqidx)');
else 
	pl=plot(freqs(1:maxfreqidx),eegspecdBtoplot(:,1:maxfreqidx)');
end;
set(pl,'LineWidth',2);
set(gca,'TickLength',[0.02 0.02]);
axis([freqs(minfreqidx) freqs(maxfreqidx) g.limits(3) g.limits(4)]);
xl=xlabel('Frequency (Hz)');
set(xl,'fontsize',16);
yl=ylabel('Rel. Power (dB)');
set(yl,'fontsize',16);
set(gca,'fontsize',16)
box off;
if ~isempty(g.weights)
	set(pl, 'linewidth', 2, 'color', 'k');
	hold on;
	pl2=plot(freqs(1:maxfreqidx),compeegspecdB(:,1:maxfreqidx)');
	newaxis = axis;
	newaxis(3) = min(newaxis(3), min(min(compeegspecdB(:,1:maxfreqidx))));
	newaxis(4) = max(newaxis(4), max(max(compeegspecdB(:,1:maxfreqidx))));
	axis(newaxis);
end;

if ~isempty(g.freq)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Plot lines through channel trace bundle at each headfreq
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	for f=1:length(g.freq)
		hold on; 
		plot([freqs(freqidx(f)) freqs(freqidx(f))], ...
			 [min(eegspecdB(:,freqidx(f))) max(eegspecdB(:,freqidx(f)))],...
			 'k','LineWidth',2.5);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Plot connecting lines using changeunits()
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	headax = zeros(1,length(g.freq));
	for f=1:length(g.freq)+length(g.icamaps)
		headax(f) = sbplot(3,length(g.freq)+length(g.icamaps),f);
		axis([-1 1 -1 1]);
	end
	large = sbplot(1,1,1);
	for f=1:length(g.freq)+length(g.icamaps)
		if f>length(g.freq) % special case of ica components
			from = changeunits([freqs(freqidx(1)),g.icafreqsval(f-1)],specaxes,large);
			%g.icafreqsval contain the sorted frequency values at the specified frequency
		else 
			from = changeunits([freqs(freqidx(f)),max(eegspecdB(:,freqidx(f)))],specaxes,large);
		end;
		to = changeunits([0,0],headax(f),large);
		hold on;
		li(f) = plot([from(1) to(1)],[from(2) to(2)],'k','LineWidth',2);
		axis([0 1 0 1]);
		axis off;
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Plot heads using topoplot()
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('Plotting scalp distributions: ')
	for f=1:length(g.freq)
		axes(headax(f));
		topodata = eegspecdB(:,freqidx(f))-mean(eegspecdB(:,freqidx(f)));
		if isnan(g.limits(5)),     maplimits = 'absmax';
		else                       maplimits = [g.limits(5) g.limits(6)];
		end;
		if ~isempty(varargin)
			topoplot(topodata,g.chanlocs,'maplimits',maplimits, varargin{:}); 
		else
			topoplot(topodata,g.chanlocs,'maplimits',maplimits); 
		end
		if f<length(g.freq)
			tl=title([num2str(freqs(freqidx(f)), '%3.1f')]);
		else
			tl=title([num2str(freqs(freqidx(f)), '%3.1f') ' Hz']);
		end
		set(tl,'fontsize',16);
		axis square;
		drawnow
		fprintf('.');
	end;
	fprintf('\n');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Plot independant components
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if ~isempty(g.weights)
		% use headaxe from 2 to end (reserved earlier)
		set(li(1), 'linewidth', 3); % make the line with the scalp topoplot thicker than others
		for index = 1:length(g.icamaps)
			axes(headax(index+1));
			compnum = g.icamaps(index);
			topoplot(g.icawinv(:,compnum),g.chanlocs,varargin{:}); 
			tl=title(int2str(compnum));
			set(tl,'fontsize',16);
			axis square;
			drawnow
		end;
	end;

	%%%%%%%%%%%%%%%%
	% Plot color bar
	%%%%%%%%%%%%%%%%
	cb=cbar;
	pos = get(cb,'position');
	set(cb,'position',[pos(1) pos(2) 0.03 pos(4)]);
	set(cb,'fontsize',12);
	if isnan(g.limits(5))
		ticks = get(cb,'ytick');
		[tmp zi] = find(ticks == 0);
		ticks = [ticks(1) ticks(zi) ticks(end)];
		set(cb,'ytick',ticks);
		set(cb,'yticklabel',{'-','0','+'});
	end
end;

%%%%%%%%%%%%%%%%
% Draw title
%%%%%%%%%%%%%%%%
if ~isempty(g.title)
  tl = textsc(g.title,'title');
  set(tl,'fontsize',15)
end

%%%%%%%%%%%%%%%%
% Turn on axcopy
%%%%%%%%%%%%%%%%
axcopy

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function computing spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eegspecdB, freqs] = spectcomp( data, frames, srate, epoch_subset, g);
	nchans = size(data,1);
	fftlength = 2^round(log(srate)/log(2))*g.freqfac;
	for c=1:nchans
		for e=epoch_subset
			if strcmp(g.reref, 'averef')
				[tmpspec,freqs] = psd(averef(matsel(data,frames,0,c,e)),fftlength,...
									  srate,fftlength/2,fftlength/8);
			else
				[tmpspec,freqs] = psd(matsel(data,frames,0,c,e),fftlength,...
									  srate,fftlength/2,fftlength/8);
			end
			if c==1 & e==epoch_subset(1)
				eegspec = zeros(nchans,length(freqs));
			end
			%eegspec(c,:) = eegspec(c,:) + tmpspec';
			eegspec(c,:) = eegspec(c,:) + log10(tmpspec');
		end
		fprintf('.')
	end
	epochs = round(size(data,2)/frames);
	eegspecdB = 10*log10(eegspec/epochs); % convert power to dB
	%eegspecdB = 10*eegspec/epochs; % convert power to dB
	return;
% Before the linear summation was used 
% ------------------------------------
% eegspecdB = 10*log10(eegspec/epochs); % convert power to dB
% and in the loop eegspec(c,:) = eegspec(c,:) + tmpspec'
