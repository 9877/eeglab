% crossf() - Returns estimates and plots event-related coherence (ERCOH) changes
%        between two input time series (x,y). A lower panel (optionally) shows 
%        the coherence phase difference between the processes. In this panel: 
%           -90 degrees (blue)   means x leads y by a quarter cycle.
%            90 degrees (orange) means y leads x by a quarter cycle.
%        Click on each subplot to view separately and zoom in/out.
%
% Function description:
%        Uses EITHER fixed-window, zero-padded FFTs (faster) OR constant-Q 
%        0-padded wavelet DFTs (better sensitivity), both Hanning-tapered. 
%        Output frequency spacing is the lowest frequency ('srate'/'winsize') 
%        divided by the 'padratio'.
%
%        If an 'alpha' value is given, then bootstrap statistics are 
%        computed (from a distribution of 200 ('naccu') surrogate baseline
%        data epochs) for the baseline epoch, and non-significant features 
%        of the output plots are zeroed (e.g., plotted in green). The baseline
%        epoch is all windows with center times < the 'baseline' value or, 
%        if 'baseboot' is 1, the whole epoch. 
% Usage: 
%        >> [coh,mcoh,timesout,freqsout,cohboot,cohangles] ...
%                       = crossf(x,y,frames,tlimits,titl,          ...
%                                    srate,cycles,winsize,timesout,...
%                                              padratio,maxfreq,alpha,verts);
%
% Required inputs:
%       x       = first single-channel data  (1,frames*nepochs)      {none}
%       y       = second single-channel data (1,frames*nepochs)      {none}
%       frames  = frames per epoch                                   {750}
%       tlimits = [mintime maxtime] (ms) epoch time limits  {[-1000 2000]}
%       srate   = data sampling rate (Hz)                            {250}
%       cycles  = If >0 -> Number of cycles in each analysis wavelet 
%                 If==0 -> Use FFTs (constant window length 'winsize') {0}
%
%    Optional Coherence Type:
%       'type'  = ['coher'|'phasecoher'] Compute either linear coherence
%                 ('coher') or phase coherence ('phasecoher') also known
%                 as phase coupling factor' { 'phasecoher' }.
%       'shuffle' =integer indicating the number of time to compute 
%                 the (phase) coherence using shuffle trials 
%                 in order to obtain the amplitude or phase coherence 
%                 time locked to the stimulus {0=no shuffling}. 
%                 See also the option 'boottype'.
%
%    Optional Detrend:
%       'detret' = ['on'|'off'], Detrend data within epochs.   {'off'}
%       'detrep' = ['on'|'off'], Detrend data across trials    {'off'}
%
%    Optional FFT/DFT:
%       'winsize' = If cycles==0: data subwindow length (fastest, 2^n<frames);
%                   if cycles >0: *longest* window length to use. This
%                   determines the lowest output frequency  {~frames/8}
%       'timesout' = Number of output times (int<frames-winsize) {200}
%       'padratio' = FFTlength/winsize (2^k)                     {2}
%                   Multiplies the number of output frequencies by
%                   dividing their spacing. When cycles==0, frequency
%                   spacing is (low_frequency/padratio).
%       'maxfreq' = Maximum frequency (Hz) to plot (& output if cycles>0) {50}
%                   If cycles==0, all FFT frequencies are output.
%       'baseline' = Coherence baseline end time (ms). NaN=no baseline  {NaN}
%       'powbase'  = Baseline spectrum to log-subtract.          {from data}
%
%    Optional Bootstrap:
%       'alpha'    = If non-0, compute Two-tailed bootstrap significance prob.
%                    level. Show non-signif output values as green. {0}
%       'naccu'    = Number of bootstrap replications to compute {200}
%       'baseboot' = Bootstrap extend (0=same as 'baseline'; 1=whole epoch). 
%                    If no baseline is given (NaN), bootstrap extend is the 
%                    whole epoch {0}
%       'boottype' = ['times'|'timestrials'] Bootstrap type: Either shuffle
%                    windows ('times') or windows and trials
%                    ('timestrials')                             {'times'}
%       'bootsub'  = [naccuboot_integer] subtract stimulus locked coherence
%                    obtained from shuffled trials {0=off}. The integer 
%                    indicates how many shuffled trial averages to
%                    accumulate. Note that this number also determines 
%                    the number of bootstrap replication for significance of
%                    the returned coherence image, which is equal to
%                        naccu = ceil(timeout/naccuboot_integer).
%                    Also plot the bootstrap trial coherence on the left.
%                    Uses bootstrap function arguments for significance of
%                    the shuffled trial image ('boottype' is forced to 'timestrials')
%       'rboot'    = Bootstrap coherence limits (e.g., from crossf()) {from data}
%                    Be sure that the bootstrap type is identical to
%                    the one used to obtain bootstrap coherence limits.
nel%    Optional Scalp Map:
%       'topovec'  = (2,nchans) matrix, plot scalp topographies (maps) to plot {[]}
%                    ELSE (chan1,chan2), plot two cartoons showing channel locations.
%       'elocs'    = Electrode location file for scalp map       {none}
%                    File should be ascii in format of  >> topoplot example   
%
%    Optional Plot Features:
%       'plotamp'   = ['on'|'off'], Plot coherence magnitude      {'on'}
%       'plotphase' = ['on'|'off'], Plot coherence phase angle    {'on'}
%       'plotbootsub' = ['on'|'off'], Plot coherence for shuffled trials
%                    if made available using 'bootsub'           {'on'}
%       'title'     = Optional figure title                       {none}
%       'vert'      = Times to mark with a dotted vertical line   {none}
%       'linewidth' = Line width for marktimes traces (thick=2, thin=1) {2}
%       'cmax'      = Maximum amplitude for color scale  { use data limits }
%       'angleunit' = Phase units: 'ms' for msec or 'deg' for degrees {'deg'}
%       'axesfont'  = Axes font size                               {10}
%       'titlefont' = Title font size                              {8}
%
% Outputs: 
%       coh         = Matrix (nfreqs,timesout) of coherence magnitudes 
%       mcoh        = Vector of mean baseline coherence at each frequency
%       timesout    = Vector of output times (window centers) (ms).
%       freqsout    = Vector of frequency bin centers (Hz).
%       cohboot     = Matrix (nfreqs , 2) of [lower;upper] coh signif. limits
%                     if 'boottype' is 'trials',  (nfreqs,timesout, 2)
%       cohangle    = (nfreqs,timesout) matrix of coherence angles 
%
% Notes: 1) when cycles==0, nfreqs is total number of FFT frequencies.
%        2) 'blue' coherence lag -> x leads y; 'red' -> y leads x
%        3) strandard bootstrap method would be 'both' but it uses much
%           memory, so the 'times' method may be prefered in some cases.
%        4) if 'boottype' is 'trials', the average of the complex bootstrap
%           is subtracted from the coherence in order to compensate for
%           phase differences (the average is also subtracted from the 
%           bootstrap distribution). For other bootstraps, this is not
%           necessary since the phase is random.
%        5) if baseline is non-NaN, the baseline is subtracted from
%           the complex coherence. On the left hand side of the coherence
%           amplitude image, the baseline is displayed as a magenta line
%           (if no baseline is selected, this curve represents the average
%           power at every given frequency).
%
% Math:
% if X(t,f) and Y(t,f) are the spectral estimates of X and Y at frequency f
% and time t (* being the conjugate, || the norm, and n the number of trials)
%  coher      = sum_over_trials(X(t,f)Y(t,f)*)/sum_over_trials(|X(t,f)Y(t,f)|)
%  phasecoher = sum_over_trials(X(t,f)Y(t,f)*/|X(t,f)Y(t,f)|)/n
%
% Authors: Sigurd Enghoff, Arnaud Delorme & Scott Makeig
%          SCCN/INC/UCSD, La Jolla, 1998-2002 
%
% See also: timef()

% Copyright (C) 8/1/98 Sigurd Enghoff, Arnaud Delorme & Scott Makeig, SCCN/INC/UCSD
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
% Revision 1.16  2002/04/24 21:02:28  scott
% added topoplots of two heads -sm
%
% Revision 1.15  2002/04/24 02:43:18  arno
% debugging amplitude coherence
%
% Revision 1.14  2002/04/20 00:53:14  arno
% restorings some outputs options
%
% Revision 1.13  2002/04/19 23:20:23  arno
% changing trial bootstrap, not optimal, waiting for further inputs
%
% Revision 1.12  2002/04/19 19:46:28  arno
% crossf with new trial coherence bootstrap (minus mean)
%
% Revision 1.11  2002/04/12 18:10:55  scott
% added note
%
% Revision 1.10  2002/04/12 01:30:43  arno
% compatibility for returning frequencies with timef
%
% Revision 1.9  2002/04/12 01:13:40  arno
% debuging no ploting option
%
% Revision 1.8  2002/04/12 01:08:13  arno
% change plotamps to plotamp in help message
%
% Revision 1.7  2002/04/12 00:41:37  arno
% programming baseboot
%
% Revision 1.6  2002/04/11 02:39:34  arno
% updated header message
%
% Revision 1.5  2002/04/10 01:29:45  arno
% adding vert optional input
%
% Revision 1.4  2002/04/09 19:36:38  arno
% corrected bootstrap optional input
%
% Revision 1.3  2002/04/09 18:59:06  arno
% corrected typo in header that made the function to crash
%
% Revision 1.2  2002/04/07 02:24:36  scott
% worked on hlpe message, changed some defaults -sm
%
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 11-20-98 defined g.linewidth constant -sm
% 04-01-99 made number of frequencies consistent -se
% 06-29-99 fixed constant-Q freq indexing -se
% 08-13-99 added cohangle plotting -sm
% 08-20-99 made bootstrap more efficient -sm
% 08-24-99 allow nan values introduced by possible eventlock() preproc. -sm
% 03-16-00 added lead/lag interpretation to help msg - sm & eric visser
% 03-16-00 added axcopy() feature -sm & tpj
% 04-20-00 fixed Rangle sign for wavelets, added verts array -sm
% 01-22-01 corrected help msg when nargin<2 -sm & arno delorme
% 01-25-02 reformated help & license, added links -ad 
% 03-09-02 function restructuration -ad
%  add 'key', val arguments (+ external baseboot, baseline, color axis, angleunit...)
%  add detrending (across time and trials) + 'coher' option for amplitude coherence
%  significance only if alpha is given, ploting options in 'plotamp' and 'plotphase'
% 03-16-02 timeout automatically adjusted if too high -ad 
% 04-03-02 added new options for bootstrap -ad 

function [R,mbase,times,freqs,Rbootout,Rangle,Rsignif] = crossf(X, Y, frame, tlimits, Fs, varwin, varargin)

%varwin,winsize,nwin,oversmp,maxfreq,alpha,verts,caxmax)

% Commandline arg defaults:
DEFAULT_ANGLEUNITS = 'deg';     % angle plotting units - 'ms' or 'deg'
DEFAULT_EPOCH	= 750;			% Frames per epoch
DEFAULT_TIMELIM = [-1000 2000];	% Time range of epochs (ms)
DEFAULT_FS		= 250;			% Sampling frequency (Hz)
DEFAULT_NWIN	= 200;			% Number of windows = horizontal resolution
DEFAULT_VARWIN	= 0;			% Fixed window length or base on cycles.
								% =0: fix window length to nwin
								% >0: set window length equal varwin cycles
								%     bounded above by winsize, also determines
								%     the min. freq. to be computed.
DEFAULT_OVERSMP	= 2;			% Number of times to oversample = vertical resolution
DEFAULT_MAXFREQ = 50;			% Maximum frequency to display (Hz)
DEFAULT_TITLE	= 'Event-Related Coherence';			% Figure title
DEFAULT_ALPHA   = NaN;			% Default two-sided significance probability threshold
           
if (nargin < 2)
	help crossf
	return
end

if (min(size(X))~=1 | length(X)<2)
	fprintf('crossf(): x must be a row or column vector.\n');
    return
elseif (min(size(Y))~=1 | length(Y)<2)
	fprintf('crossf(): y must be a row or column vector.\n');
    return
elseif (length(X) ~= length(Y))
	fprintf('crossf(): x and y must have same length.\n');
    return
end

if (nargin < 3)
	frame = DEFAULT_EPOCH;
elseif (~isnumeric(frame) | length(frame)~=1 | frame~=round(frame))
	fprintf('crossf(): Value of frames must be an integer.\n');
    return
elseif (frame <= 0)
	fprintf('crossf(): Value of frames must be positive.\n');
    return
elseif (rem(length(X),frame) ~= 0)
	fprintf('crossf(): Length of data vectors must be divisible by frames.\n');
    return
end

if (nargin < 4)
	tlimits = DEFAULT_TIMELIM;
elseif (~isnumeric(tlimits) | sum(size(tlimits))~=3)
	error('crossf(): Value of tlimits must be a vector containing two numbers.');
elseif (tlimits(1) >= tlimits(2))
	error('crossf(): tlimits interval must be [min,max].');
end

if (nargin < 5)
	Fs = DEFAULT_FS;
elseif (~isnumeric(Fs) | length(Fs)~=1)
	error('crossf(): Value of srate must be a number.');
elseif (Fs <= 0)
	error('crossf(): Value of srate must be positive.');
end

if (nargin < 6)
	varwin = DEFAULT_VARWIN;
elseif (~isnumeric(varwin) | length(varwin)~=1)
	error('crossf(): Value of cycles must be a number.');
elseif (varwin < 0)
	error('crossf(): Value of cycles must be either zero or positive.');
end

% consider structure for these arguments
% --------------------------------------
if ~isempty(varargin)
    try, g = struct(varargin{:}); 
    catch, error('Argument error in the {''param'', value} sequence'); end; 
end;
g.tlimits = tlimits;
g.frame   = frame;
g.srate   = Fs;
g.cycles  = varwin;

try, g.shuffle;    catch, g.shuffle = 0; end;
try, g.title;      catch, g.title = DEFAULT_TITLE; end;
try, g.winsize;    catch, g.winsize = max(pow2(nextpow2(g.frame)-3),4); end;
try, g.pad;        catch, g.pad = max(pow2(nextpow2(g.winsize)),4); end;
try, g.timesout;   catch, g.timesout = DEFAULT_NWIN; end;
try, g.padratio;   catch, g.padratio = DEFAULT_OVERSMP; end;
try, g.maxfreq;    catch, g.maxfreq = DEFAULT_MAXFREQ; end;
try, g.topovec;    catch, g.topovec = []; end;
try, g.elocs;      catch, g.elocs = ''; end;
try, g.alpha;      catch, g.alpha = DEFAULT_ALPHA; end;  
try, g.marktimes;  catch, g.marktimes = []; end; % default no vertical lines
try, g.marktimes = g.vert;       catch, g.vert = []; end; % default no vertical lines
try, g.powbase;    catch, g.powbase = nan; end;
try, g.rboot;      catch, g.rboot = nan; end;
try, g.plotamp;    catch, g.plotamp = 'on'; end;
try, g.plotphase;  catch, g.plotphase  = 'on'; end;
try, g.plotbootsub;  catch, g.plotbootsub  = 'on'; end;
try, g.detrep;     catch, g.detrep = 'off'; end;
try, g.detret;     catch, g.detret = 'off'; end;
try, g.baseline;   catch, g.baseline = NaN; end;
try, g.baseboot;   catch, g.baseboot = 0; end;
try, g.linewidth;  catch, g.linewidth = 2; end;
try, g.naccu;      catch, g.naccu = 200; end;
try, g.angleunit;  catch, g.angleunit = DEFAULT_ANGLEUNITS; end;
try, g.cmax;       catch, g.cmax = 0; end; % 0=use data limits
try, g.type;       catch, g.type = 'phasecoher'; end; 
try, g.boottype;   catch, g.boottype = 'times'; end; 
try, g.bootsub;    catch, g.bootsub = 0; end;

g.type     = lower(g.type);
g.boottype = lower(g.boottype);
g.detrep   = lower(g.detrep);
g.detret   = lower(g.detret);
g.plotphase = lower(g.plotphase);
g.plotbootsub = lower(g.plotbootsub);
g.bootsub = lower(g.bootsub);
g.plotamp   = lower(g.plotamp);
g.shuffle   = lower(g.shuffle);
g.AXES_FONT  = 10;
g.TITLE_FONT = 14;

% testing arguments consistency
% -----------------------------
if (~ischar(g.title))
	error('Title must be a string.');
end

if (~isnumeric(g.winsize) | length(g.winsize)~=1 | g.winsize~=round(g.winsize))
	error('Value of winsize must be an integer number.');
elseif (g.winsize <= 0)
	error('Value of winsize must be positive.');
elseif (g.cycles == 0 & pow2(nextpow2(g.winsize)) ~= g.winsize)
	error('Value of winsize must be an integer power of two [1,2,4,8,16,...]');
elseif (g.winsize > g.frame)
	error('Value of winsize must be less than frame length.');
end

if (~isnumeric(g.timesout) | length(g.timesout)~=1 | g.timesout~=round(g.timesout))
	error('Value of timesout must be an integer number.');
elseif (g.timesout <= 0)
	error('Value of timesout must be positive.');
end
if (g.timesout > g.frame-g.winsize)
	g.timesout = g.frame-g.winsize;
	disp(['Value of timesout must be <= frame-winsize, timeout adjusted to ' int2str(g.timesout) ]);
end

if (~isnumeric(g.padratio) | length(g.padratio)~=1 | g.padratio~=round(g.padratio))
	error('Value of padratio must be an integer.');
elseif (g.padratio <= 0)
	error('Value of padratio must be positive.');
elseif (pow2(nextpow2(g.padratio)) ~= g.padratio)
	error('Value of padratio must be an integer power of two [1,2,4,8,16,...]');
end

if (~isnumeric(g.maxfreq) | length(g.maxfreq)~=1)
	error('Value of g.maxfreq must be a number.');
elseif (g.maxfreq <= 0)
	error('Value of g.maxfreq must be positive.');
elseif (g.maxfreq > Fs/2)
	fprintf('Warning: value of g.maxfreq greater that Nyquist rate\n\n');
end

if isempty(g.topovec)
	g.topovec = [];
elseif (size(g.topovec,2))~=2)
	error('tvec must be two column vectors.');
end

if isempty(g.elocs)
	g.elocs = '';
elseif (~ischar(g.elocs))
	error('Channel location file must be a valid text file.');
end

if (~isnumeric(g.alpha) | length(g.alpha)~=1)
	error('timef(): Value of g.alpha must be a number.\n');
elseif (round(g.naccu*g.alpha) < 2)
	fprintf('Value of g.alpha is out of the normal range [%g,0.5]\n',2/g.naccu);
    g.naccu = round(2/g.alpha);
	fprintf('  Increasing the number of bootstrap iterations to %d\n',g.naccu);
end
if g.alpha>0.5 | g.alpha<=0
    error('Value of g.alpha is out of the allowed range (0.00,0.5).');
end
if ~isnan(g.alpha)
   if g.baseboot > 0
     fprintf('Bootstrap analysis will use data in baseline (pre-0) subwindows only.\n')
   else
     fprintf('Bootstrap analysis will use data in all subwindows.\n')
   end
end
switch g.angleunit
    case { 'ms', 'deg' },;
    otherwise error('Angleunit must be either ''deg'' or ''ms''');
end;    
switch g.type
    case { 'coher', 'phasecoher' },;
    otherwise error('Type must be either ''coher'' or ''phasecoher''');
end;    
switch g.boottype
    case { 'times', 'timestrials' },;
    otherwise error('Boot type must be either ''times'' or ''timestrials''');
end;    
if (~isnumeric(g.shuffle))
	error('Shuffle type must be numeric');
end;
if (~isnumeric(g.bootsub))
	error('Bootsub must be numeric');
	if strcmp(g.boottype, 'times')
		('Warning: ''bootsub'' is being used, so ''boottype'' was forced to ''timestrials''');
		g.boottype = 'timestrials';
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shuffle trials if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if g.shuffle ~= 0
	fprintf('Data shuffled\n');
	XX = reshape(X, size(X,1), frame, size(X,2)/frame);
	YY = Y;
	X = [];
	Y = [];
	for index = 1:g.shuffle
		XX = shuffle(XX,1);
		X = [X XX(:,:)];
		Y = [Y YY];
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% winsize, nwin, oversmp, maxfreq, alpha, vert =marktimes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (g.cycles == 0) %%%%%%%%%%%%%% constant window-length FFTs %%%%%%%%%%%%%%%%
    freqs = g.srate/g.winsize*[1:2/g.padratio:g.winsize]/2;
    win = hanning(g.winsize);

	R  = zeros(g.padratio*g.winsize/2,g.timesout); % mean coherence
	RR = zeros(g.padratio*g.winsize/2,g.timesout); % (coherence)
	Rboot = zeros(g.padratio*g.winsize/2,g.naccu); % summed bootstrap coher
	switch g.type
	    case 'coher',
           cumulXY = zeros(g.padratio*g.winsize/2,g.timesout);
           cumulXYboot = zeros(g.padratio*g.winsize/2,g.naccu);
    end;
    if g.bootsub > 0
		Rboottrial = zeros(g.padratio*g.winsize/2, g.timesout, g.bootsub); % summed bootstrap coher
		cumulXYboottrial = zeros(g.padratio*g.winsize/2, g.timesout, g.bootsub);
    end;
else % %%%%%%%%%%%%%%%%%% Constant-Q (wavelet) DFTs %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   	freqs = g.srate*g.cycles/g.winsize*[2:2/g.padratio:g.winsize]/2;
    dispf = find(freqs <= g.maxfreq);
    freqs = freqs(dispf);

	win = dftfilt(g.winsize,g.maxfreq/g.srate,g.cycles,g.padratio,.5);
	R = zeros(size(win,2),g.timesout);       % mean coherence
	RR = repmat(nan,size(win,2),g.timesout); % initialize with nans
	Rboot = zeros(size(win,2),g.naccu);  % summed bootstrap coher
	switch g.type
	    case 'coher',
           cumulXY = zeros(size(win,2),g.timesout);
           cumulXYboot = zeros(size(win,2),g.naccu);
    end;        
    if g.bootsub > 0
		Rboottrial = zeros(size(win,2), g.timesout, g.bootsub); % summed bootstrap coher
		cumulXYboottrial = zeros(size(win,2), g.timesout, g.bootsub);
    end;            
end

wintime = 500*g.winsize/g.srate;
times = [g.tlimits(1)+wintime:(g.tlimits(2)-g.tlimits(1)-2*wintime)/(g.timesout-1):g.tlimits(2)-wintime];

if ~isnan(g.baseline)
	baseln = find(times < g.baseline); % subtract means of pre-0 (centered) windows
	if isempty(baseln)
		baseln = 1:length(times); % use all times as baseline
		disp('Bootstrap baseline empty, using the whole epoch');
	end;
	baselength = length(baseln);
else
	baseln = 1:length(times); % use all times as baseline
	baselength = length(times); % used for bootstrap
end;

dispf = find(freqs <= g.maxfreq);
stp = (g.frame-g.winsize)/(g.timesout-1);
trials = length(X)/g.frame;

fprintf('\nComputing the Event-Related Cross-Coherence image\n');
fprintf(' based on %d trials of %d frames sampled at %g Hz.\n', trials,g.frame,g.srate);
fprintf('Trial timebase is %d ms before to %d ms after the stimulus\n', g.tlimits(1),g.tlimits(2));
if ~isnan(g.baseline)
	if length(baseln) == length(times)
		fprintf('Using full time range as baseline\n');
	else
		fprintf('Using times in under %d ms for baseline\n', g.baseline);
	end;
else 
	fprintf('No baseline is been used\n');	
end;
fprintf('The frequency range displayed is %g-%g Hz.\n',min(dispf),g.maxfreq);
if g.cycles==0
  fprintf('The data window size is %d samples (%g ms).\n',g.winsize,2*wintime);
  fprintf('The FFT length is %d samples\n',g.winsize*g.padratio);
else
  fprintf('The window size is %d cycles.\n',g.cycles);
  fprintf('The maximum window size is %d samples (%g ms).\n',g.winsize,2*wintime);
end
fprintf('The window is applied %d times\n',g.timesout);
fprintf(' with an average step size of %g samples (%g ms).\n', stp,1000*stp/g.srate);
fprintf('Results are oversampled %d times.\n',g.padratio);
if ~isnan(g.alpha)
  fprintf('Bootstrap confidence limits will be computed based on alpha = %g\n', g.alpha);
else
  fprintf('Bootstrap confidence limits will NOT be computed.\n'); 
end
switch g.plotphase
    case 'on', fprintf(['Coherence angles will be imaged in ',g.angleunit,'\n']);
end;

fprintf('\nProcessing trial (of %d):',trials);

% detrend over epochs (trials) if requested
% -----------------------------------------
switch g.detrep
    case 'on'
        X = reshape(X, g.frame, length(X)/g.frame);
        X = X - mean(X,2)*ones(1, length(X(:))/g.frame);
        Y = reshape(Y, g.frame, length(Y)/g.frame);
        Y = Y - mean(Y,2)*ones(1, length(Y(:))/g.frame);
end;        

firstboot = 1;
Rn=zeros(trials,g.timesout);
X = X(:)'; % make X and Y column vectors
Y = Y(:)';
for t=1:trials,
	if (rem(t,10) == 0)
		fprintf(' %d',t);
	end
    if rem(t,120) == 0
        fprintf('\n');
    end

	for j=1:g.timesout, % for each time window
		tmpX = X([1:g.winsize]+floor((j-1)*stp)+(t-1)*g.frame);
		tmpY = Y([1:g.winsize]+floor((j-1)*stp)+(t-1)*g.frame);

        if ~any(isnan(tmpX))
		  tmpX = tmpX - mean(tmpX);
		  tmpY = tmpY - mean(tmpY);
          switch g.detret, case 'on', 
              tmpX = detrend(tmpX); 
              tmpY = detrend(tmpY); 
          end;

		  if g.cycles == 0 % use FFTs
			tmpX = win .* tmpX(:);
			tmpY = win .* tmpY(:);
			tmpX = fft(tmpX,g.padratio*g.winsize);
			tmpY = fft(tmpY,g.padratio*g.winsize);
			tmpX = tmpX(2:g.padratio*g.winsize/2+1);
			tmpY = tmpY(2:g.padratio*g.winsize/2+1);
		  else 
			tmpX = win' * tmpX(:);
			tmpY = win' * tmpY(:);
		  end

          if ~isnan(g.alpha) & isnan(g.rboot)
           if firstboot==1
             tmpsX = repmat(nan,length(tmpX),g.timesout);
             tmpsY = repmat(nan,length(tmpY),g.timesout);
             firstboot = 0;
           end
           tmpsX(:,j) = tmpX;
           tmpsY(:,j) = tmpY;
          end

		  switch g.type
		      case 'coher',
		          R(:,j)      = R(:,j) + tmpX.*conj(tmpY); % complex coher.
                  cumulXY(:,j) = cumulXY(:,j)+abs(tmpX).*abs(tmpY);
		      case 'phasecoher',
		          R(:,j) = R(:,j) + tmpX.*conj(tmpY) ./ (abs(tmpX).*abs(tmpY)); % complex coher.
          end;
          Rn(t,j) = Rn(t,j)+1;
        end % ~any(isnan())
	end % time window
	
	if ~isnan(g.alpha) & isnan(g.rboot)
	   if strcmp(g.boottype, 'times') % get g.naccu bootstrap estimates for each trial
		   goodbasewins = find(Rn(t,:)==1);
		   if g.baseboot % use baseline windows only
			   goodbasewins = find(goodbasewins<=baselength); 
		   end
		   ngdbasewins = length(goodbasewins);
		   j=1;
		   if ngdbasewins > 1
			   while j<=g.naccu
				   s = ceil(rand([1 2])*ngdbasewins); % random ints [1,g.timesout]
				   s =goodbasewins(s);
				   tmpX = tmpsX(:,s(1));
				   tmpY = tmpsY(:,s(2));
				   if ~any(isnan(tmpX)) & ~any(isnan(tmpY))
					   switch g.type
						case 'coher',
						 Rboot(:,j) = Rboot(:,j) + tmpX.*conj(tmpY); % complex coher.
						 cumulXYboot(:,j) = cumulXYboot(:,j)+abs(tmpX).*abs(tmpY);
						case 'phasecoher',
						 Rboot(:,j) = Rboot(:,j) + tmpX.*conj(tmpY) ./ (abs(tmpX).*abs(tmpY)); % complex coher.
					   end;
					   j = j+1;
				   end
			   end
		   end;
		   
	   else
		   alltmpsX{t} = tmpsX;
		   alltmpsY{t} = tmpsX;
	   end;
	end
end % t = trial
abs(R(1:10))
cumulXY(1:10)

% handle trial bootstrap types
% ----------------------------
if g.bootsub > 0
    fprintf('\nProcessing trial bootstrap (of %d):',trials);
    for allt=1:trials
		if (rem(allt,10) == 0)
			fprintf(' %d',allt);
		end
	    if rem(allt,120) == 0
	        fprintf('\n');
	    end
	    j=1;
	    while j<=g.bootsub
			t = ceil(rand([1 2])*trials); % random ints [1,g.timesout]
			tmpsX = alltmpsX{t(1)};
			tmpsY = alltmpsY{t(2)};
			if all(Rn(t(1),:) == 1) & all(Rn(t(2),:) == 1)
				switch g.type
				   case 'coher',
					Rboottrial(:,:,j) = Rboottrial(:,:,j) + tmpsX.*conj(tmpsY); % complex coher.
					cumulXYboottrial(:,:,j) = cumulXYboottrial(:,:,j)+abs(tmpsX).*abs(tmpsY);
				   case 'phasecoher',
					Rboottrial(:,:,j) = Rboottrial(:,:,j) + tmpsX.*conj(tmpsY) ./ (abs(tmpsX).*abs(tmpsY)); % complex coher.
				  end;
				  j = j+1;
			end
	    end
	end;
end;

% handle timestrials bootstrap
% ----------------------------
if strcmp(g.boottype, 'timestrials') & isnan(g.rboot)
    fprintf('\nProcessing time and trial bootstrap (of %d):',trials);
    for allt=1:trials
		if (rem(allt,10) == 0)
			fprintf(' %d',allt);
		end
	    if rem(allt,120) == 0
	        fprintf('\n');
	    end
	    j=1;
	    while j<=g.naccu
			t = ceil(rand([1 2])*trials); % random ints [1,g.timesout]
			
			goodbasewins = find((Rn(t(1),:) & Rn(t(2),:)) ==1);
			if g.baseboot % use baseline windows only
				goodbasewins = find(goodbasewins<=baselength); 
			end
			ngdbasewins = length(goodbasewins);
			
			if ngdbasewins>1
				s = ceil(rand([1 2])*ngdbasewins); % random ints [1,g.timesout]
				s=goodbasewins(s);
				
				tmpsX = alltmpsX{t(1)};
				tmpsY = alltmpsY{t(2)};
				tmpX = tmpsX(:,s(1));
				tmpY = tmpsY(:,s(2));
				if all(Rn(t(1),s(1)) == 1) & all(Rn(t(2),s(2)) == 1)
					switch g.type
					 case 'coher',
					  Rboot(:,j) = Rboot(:,j) + tmpX.*conj(tmpY); % complex coher.
					  cumulXYboot(:,j) = cumulXYboot(:,j)+abs(tmpX).*abs(tmpY);
					 case 'phasecoher',
					  Rboot(:,j) = Rboot(:,j) + tmpX.*conj(tmpY) ./ (abs(tmpX).*abs(tmpY)); % complex coher.
					end;
					j = j+1;		
				end 
			end
		end;            
	end
end;
clear alltmpsX alltmpsY;

% if coherence, perform the division
% ----------------------------------
switch g.type
 case 'coher',
  R = R ./ cumulXY;
  if ~isnan(g.alpha) & isnan(g.rboot)
	  Rboot = Rboot ./ cumulXYboot;  
  end;
  if g.bootsub > 0
	  Rboottrial = Rboottrial ./ cumulXYboottrial;
  end;
 case 'phasecoher',
  Rn = sum(Rn, 1);
  R = R ./ (ones(size(R,1),1)*Rn);               % coherence magnitude
  if ~isnan(g.alpha) & isnan(g.rboot)
	  Rboot = Rboot / trials;  
  end;
  if g.bootsub > 0
	  Rboottrial = Rboottrial / trials;
  end;
end;

% compute baseline
% ----------------
mbase = mean(abs(R(:,baseln)'));     % mean baseline coherence magnitude

% compute bootstrap significance level
% ------------------------------------
if ~isnan(g.alpha) & isnan(g.rboot) % if bootstrap analysis included . . .
	Rboot = abs(Rboot); % normalize bootstrap magnitude to [0,1]
	if ~isnan(g.baseline)
		Rboot = Rboot - repmat(mbase', [1 g.naccu]); % subtract the man also from Rboot
	end;
	Rboot = sort(Rboot')';
	Rbootout = Rboot;
elseif ~isnan(g.rboot)
	Rboot = g.rboot;
	Rbootout = Rboot;
end;

if ~isnan(g.alpha) % if bootstrap analysis included . . .
	i = round(g.naccu*g.alpha);
	Rboot = Rboot';
	Rsignif = mean(Rboot(g.naccu-i+1:g.naccu,:)); % significance levels for Rraw
	Rboot = [mean(Rboot(1:i,:)); mean(Rboot(g.naccu-i+1:g.naccu,:))];
	%Rboot = [mean(Rboot(1:i,:)) ; mean(Rboot(g.naccu-i+1:g.naccu,:))];
end % NOTE: above, mean ?????

if g.bootsub < 0
	meanRboot = mean(Rboot,3);
	figure
	plotall(meanRboot, Rboot, times, freqs, mbase, dispf, g);
	% WARNING RBOOT IS OF RANK N AND MEANRBOOT IS OF RANK N*g.bootsub
	% MBASE IS NOT GOOD EITHER
	
	R = R - meanRboot; % must subtract man R boot from R (complex)
	Rboot = Rboot - repmat(meanRboot, [1 1 g.naccu]); % subtract the man also from Rboot
	Rboot = sort(abs(Rboot),3);  
	if ~isnan(g.baseline)
		Rboot = Rboot - repmat(mbase', [1 g.timesout g.naccu]); % subtract the man also from Rboot
	end;
	Rbootout = Rboot;
else	
	plotall(R, Rboot, Rsignif, times, freqs, mbase, dispf, g);
	Rangle = angle(R);
end;

% ------------------
% plotting functions
% ------------------
function plotall(R, Rboot, Rsignif, times, freqs, mbase, dispf, g) 

switch lower(g.plotphase)
   case 'on',  
       switch lower(g.plotamp), 
          case 'on', ordinate1 = 0.67; ordinate2 = 0.1; height = 0.33; g.plot = 1;
          case 'off', ordinate2 = 0.1; height = 0.9; g.plot = 1;
       end;     
   case 'off', ordinate1 = 0.1; height = 0.9; 
       switch lower(g.plotamp), 
          case 'on', ordinate1 = 0.1; height = 0.9;  g.plot = 1;
          case 'off', g.plot = 0;
       end;     
end; 

% compute angles
% --------------
Rangle = angle(R);
if g.cycles ~= 0
   Rangle = -Rangle; % make lead/lag the same for FFT and wavelet analysis
end
R = abs(R);
if ~isnan(g.baseline)
	R = R - repmat(mbase',[1 g.timesout]); % remove baseline mean
end;
Rraw =R; % raw coherence values

	
if g.plot
    fprintf('\nNow plotting...\n');
	set(gcf,'DefaultAxesFontSize',g.AXES_FONT)
	colormap(jet(256));
	
	pos = get(gca,'position'); % plot relative to current axes
	q = [pos(1) pos(2) 0 0];
	s = [pos(3) pos(4) pos(3) pos(4)];
	axis('off')
end;

switch lower(g.plotamp)
 case 'on' 
    %
    % Image the coherence [% perturbations] 
    %
	RR = R;
	if ~isnan(g.alpha) % zero out (and 'green out') nonsignif. R values
        switch g.boottype
	       case 'trials',
		      RR(find((RR > Rbootplus) & (RR < Rbootminus))) = 0;
		      Rraw(find(Rsignif >= Rraw))=0;
		      Rboottime = [mean(Rbootplus(dispf,:),1); mean(Rbootminus(dispf,:),1)];
		      Rsigniftime = mean(Rsignif(dispf,:),1);
		      Rboot = [mean(Rbootplus,2) mean(Rbootminus,2)]';
		      Rsignif = mean(Rsignif,2)';
		   otherwise
		      RR(find((RR > repmat(Rboot(1,:)',[1 g.timesout])) ...
	              & (RR < repmat(Rboot(2,:)',[1 g.timesout])))) = 0;
		      Rraw(find(repmat(Rsignif',[1,size(Rraw,2)])>=Rraw))=0;
		   end;   
	end

	if g.cmax == 0
	    coh_caxis = max(max(R(dispf,:)))*[-1 1];
	else
	    coh_caxis = g.cmax*[-1 1];
	end

	h(6) = axes('Units','Normalized', 'Position',[.1 ordinate1 .8 height].*s+q);

	map=hsv(300); % install circular color map - green=0, yellow, orng, red, violet = max
	              %                                         cyan, blue, violet = min
	map = flipud([map(251:end,:);map(1:250,:)]);
	map(151,:) = map(151,:)*0.9; % tone down the (0=) green!
	colormap(map);

	imagesc(times,freqs(dispf),RR(dispf,:),coh_caxis); % plot the coherence image

	hold on
	plot([0 0],[0 freqs(max(dispf))],'--m','LineWidth',g.linewidth)
	for i=1:length(g.marktimes)
	  plot([g.marktimes(i) g.marktimes(i)],[0 freqs(max(dispf))],'--m','LineWidth',g.linewidth);
	end;
	hold off
	set(h(6),'YTickLabel',[],'YTick',[])
	set(h(6),'XTickLabel',[],'XTick',[])
	%title('Event-Related Coherence')

	h(8) = axes('Position',[.95 ordinate1 .05 height].*s+q);
	cbar(h(8),151:300,[0 coh_caxis(2)]); % use only positive colors (gyorv) 

	%
	% Plot delta-mean min and max coherence at each time point on bottom of image
	%
	h(10) = axes('Units','Normalized','Position',[.1 ordinate1-0.1 .8 .1].*s+q); % plot marginal means below
	Emax = max(R(dispf,:)); % mean coherence at each time point
	Emin = min(R(dispf,:)); % mean coherence at each time point
	if ~isnan(g.alpha) & strcmp(g.boottype, 'trials') % plot bootstrap significance limits (base mean +/-)
	    plot(times,Rboottime([1 2],:),'g','LineWidth',g.linewidth); hold on;
	    plot(times,Rsigniftime,'k:','LineWidth',g.linewidth);
		plot(times,Emax,'b');
		plot(times,Emin,'b');
		plot([times(1) times(length(times))],[0 0],'LineWidth',0.7);
		plot([0 0],[-500 500],'--m','LineWidth',g.linewidth);
		for i=1:length(g.marktimes)
		  plot([g.marktimes(i) g.marktimes(i)],[-500 500],'--m','LineWidth',g.linewidth);
		end;
		axis([min(times) max(times) 0 max([Emax(:)' Rsignif(:)'])*1.2])
    else
		plot(times,Emax,'b');
		hold on
		plot(times,Emin,'b');
		plot([times(1) times(length(times))],[0 0],'LineWidth',0.7);
		plot([0 0],[-500 500],'--m','LineWidth',g.linewidth);
		for i=1:length(g.marktimes)
		  plot([g.marktimes(i) g.marktimes(i)],[-500 500],'--m','LineWidth',g.linewidth);
		end;
		axis([min(times) max(times) 0 max(Emax)*1.2])
    end;
	tick = get(h(10),'YTick');
	set(h(10),'YTick',[tick(1) ; tick(length(tick))])
	set(h(10),'YAxisLocation','right')
    xlabel('Time (ms)')
	ylabel('coh.')

	%
	% Plot mean baseline coherence at each freq on left side of image
	%

	h(11) = axes('Units','Normalized','Position',[0 ordinate1 .1 height].*s+q); % plot mean spectrum
	E = abs(mbase(dispf)); % baseline mean coherence at each frequency
	if ~isnan(g.alpha) % plot bootstrap significance limits (base mean +/-)
		plot(freqs(dispf),E,'m','LineWidth',g.linewidth); % plot mbase
	    hold on
		% plot(freqs(dispf),Rboot(:,dispf)+[E;E],'g','LineWidth',g.linewidth);
		plot(freqs(dispf),Rboot([1 2],dispf),'g','LineWidth',g.linewidth);
		plot(freqs(dispf),Rsignif(dispf),'k:','LineWidth',g.linewidth);
		axis([freqs(1) freqs(max(dispf)) 0 max([E Rsignif])*1.2]);
	else             % plot marginal mean coherence only
		plot(freqs(dispf),E,'LineWidth',g.linewidth);
		% axis([freqs(1) freqs(max(dispf)) min(E)-max(E)/3 max(E)+max(E)/3]);
		if ~isnan(max(E))
	    	axis([freqs(1) freqs(max(dispf)) 0 max(E)*1.2]);
	    end;
	end

	tick = get(h(11),'YTick');
	set(h(11),'YTick',[tick(1) ; tick(length(tick))])
	set(h(11),'View',[90 90])
	xlabel('Freq. (Hz)')
	ylabel('coh.')
end;

switch lower(g.plotphase)
  case 'on'
   %
   % Plot coherence phase lags in bottom panel
   %
   h(13) = axes('Units','Normalized','Position',[.1 ordinate2 .8 height].*s+q);
   if strcmp(g.angleunit,'ms')  % convert to ms
     Rangle = (Rangle/(2*pi)).*repmat(1000./freqs(dispf)',1,length(times)); 
     maxangle = max(max(abs(Rangle)));
   else
     Rangle = Rangle*180/pi; % convert to degrees
     maxangle = 180; % use full-cycle plotting 
   end
   Rangle(find(Rraw==0)) = 0; % set angle at non-signif coher points to 0

   imagesc(times,freqs(dispf),Rangle(dispf,:),[-maxangle maxangle]); % plot the 
   hold on                                             % coherence phase angles
   plot([0 0],[0 freqs(max(dispf))],'--m','LineWidth',g.linewidth); % zero-time line
   for i=1:length(g.marktimes)
     plot([g.marktimes(i) g.marktimes(i)],[0 freqs(max(dispf))],'--m','LineWidth',g.linewidth);
   end;

   ylabel('Freq. (Hz)')
   xlabel('Time (ms)')

   h(14)=axes('Position',[.95 ordinate2 .05 height].*s+q);
   cbar(h(14),0,[-maxangle maxangle]); % two-sided colorbar
end

if g.plot
   if (length(g.title) > 0) % plot title
	   axes('Position',pos,'Visible','Off');               
	   h(13) = text(-.05,1.01,g.title);
	   set(h(13),'VerticalAlignment','bottom')
	   set(h(13),'HorizontalAlignment','left')
	   set(h(13),'FontSize',g.TITLE_FONT)
   end
   %
   %%%%%%%%%%%%%%% plot topoplot() %%%%%%%%%%%%%%%%%%%%%%%
   %
   if (~isempty(g.topovec))
         h(15) = subplot('Position',[-.1 .43 .2 .14].*s+q);
         topoplot(g.topovec(:,1),g.elocs,'electrodes','off', ...
                    'style', 'blank', 'emarkersize1chan', 10);

         h(16) = subplot('Position',[.9 .43 .2 .14].*s+q);
         topoplot(g.topovec(:,2),g.elocs,'electrodes','off', ...
                    'style', 'blank', 'emarkersize1chan', 10);
        axis('square')
   end

   axcopy(gcf);
end;
