function rt_powerestimate(cfg)

% RT_POWERESTIMATE is an example realtime application for online
% power estimation. It should work both for EEG and MEG.
%
% Use as
%   rt_powerestimate(cfg)
% with the following configuration options
%   cfg.channel    = cell-array, see CHANNELSELECTION (default = 'all')
%   cfg.foilim     = [Flow Fhigh] (default = [0 120])
%   cfg.blocksize  = number, size of the blocks/chuncks that are processed (default = 1 second)
%   cfg.bufferdata = whether to start on the 'first or 'last' data that is available (default = 'last')
%
% The source of the data is configured as
%   cfg.dataset       = string
% or alternatively to obtain more low-level control as
%   cfg.datafile      = string
%   cfg.headerfile    = string
%   cfg.eventfile     = string
%   cfg.dataformat    = string, default is determined automatic
%   cfg.headerformat  = string, default is determined automatic
%   cfg.eventformat   = string, default is determined automatic
%
% To stop the realtime function, you have to press Ctrl-C

% Copyright (C) 2008, Robert Oostenveld
%
% $Log: not supported by cvs2svn $
% Revision 1.9  2009/04/21 09:59:52  roboos
% cleaned up cvs log comments
%
% Revision 1.8  2009/02/04 09:08:07  roboos
% ensure that the persistent variables related to header caching are cleared
% this is needed when switching the headerformat (from ctf_res4 to ctf_old) while continuing on the same file
%

% set the default configuration options
if ~isfield(cfg, 'dataformat'),     cfg.dataformat = [];      end % default is detected automatically
if ~isfield(cfg, 'headerformat'),   cfg.headerformat = [];    end % default is detected automatically
if ~isfield(cfg, 'eventformat'),    cfg.eventformat = [];     end % default is detected automatically
if ~isfield(cfg, 'blocksize'),      cfg.blocksize = 1;        end % in seconds
if ~isfield(cfg, 'channel'),        cfg.channel = 'all';      end
if ~isfield(cfg, 'foilim'),         cfg.foilim = [0 120];     end
if ~isfield(cfg, 'bufferdata'),     cfg.bufferdata = 'last';  end % first or last

% translate dataset into datafile+headerfile
cfg = checkconfig(cfg, 'dataset2files', 'yes');
cfg = checkconfig(cfg, 'required', {'datafile' 'headerfile'});

% ensure that the persistent variables related to caching are cleared
clear read_header
% start by reading the header from the realtime buffer
hdr = read_header(cfg.headerfile, 'cache', true, 'retry', true);

% define a subset of channels for reading
cfg.channel = channelselection(cfg.channel, hdr.label);
chanindx    = match_str(hdr.label, cfg.channel);
nchan       = length(chanindx);
if nchan==0
  error('no channels were selected');
end

% determine the size of blocks to process
blocksize = round(cfg.blocksize * hdr.Fs);

% this is used for scaling the figure
powmax = 0;

% set up the spectral estimator
specest = spectrum.welch('Hamming', min(hdr.Fs, blocksize));

prevSample  = 0;
count       = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is the general BCI loop where realtime incoming data is handled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while true

  % determine number of samples available in buffer
  hdr = read_header(cfg.headerfile, 'cache', true);

  % see whether new samples are available
  newsamples = (hdr.nSamples*hdr.nTrials-prevSample);

  if newsamples>=blocksize

    % determine the samples to process
    if strcmp(cfg.bufferdata, 'last')
      begsample  = hdr.nSamples*hdr.nTrials - blocksize + 1;
      endsample  = hdr.nSamples*hdr.nTrials;
    elseif strcmp(cfg.bufferdata, 'first')
      begsample  = prevSample+1;
      endsample  = prevSample+blocksize ;
    else
      error('unsupported value for cfg.bufferdata');
    end

    % remember up to where the data was read
    prevSample  = endsample;
    count       = count + 1;
    fprintf('processing segment %d from sample %d to %d\n', count, begsample, endsample);

    % read data segment from buffer
    dat = read_data(cfg.datafile, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx, 'checkboundary', false);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % from here onward it is specific to the power estimation from the data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % put the data in a fieldtrip-like raw structure
    data.trial{1} = dat;
    data.time{1}  = offset2time(begsample, hdr.Fs, endsample-begsample+1);
    data.label    = hdr.label(chanindx);
    data.hdr      = hdr;
    data.fsample  = hdr.Fs;

    % apply preprocessing options
    data.trial{1} = preproc_baselinecorrect(data.trial{1});

    figure(1)
    h = get(gca, 'children');
    hold on

    if ~isempty(h)
      % done on every iteration
      delete(h);
    end

    if isempty(h)
      % done only once
      powmax = 0;
      grid on
    end

    for i=1:nchan
      est = psd(specest, data.trial{1}(i,:), 'Fs', data.fsample);
      if i==1
        pow = est.Data;
      else
        pow = pow + est.Data;
      end
    end

    pow    = pow/nchan;
    powmax = max(max(pow), powmax); % this keeps a history

    plot(est.Frequencies, pow);
    axis([cfg.foilim(1) cfg.foilim(2) 0 powmax]);

    str = sprintf('time = %d s\n', round(mean(data.time{1})));
    title(str);

    xlabel('frequency (Hz)');
    ylabel('power');

    % force Matlab to update the figure
    drawnow

  end % if enough new samples
end % while true
