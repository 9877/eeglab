function rt_brainampproxy(cfg)

% RT_BRAINAMPPROXY reads continuous data from a BrainAmp EEG acquisition
% system through the RDA network interface and writes it to a FieldTrip
% buffer.
%
% The FieldTrip buffer is a network transparent server that allows the
% acquisition client to stream data to it. An analysis client can connect
% to read the data upon request. Multiple clients can connect simultaneously,
% each analyzing a specific aspect of the data concurrently.
%
% Use as
%   rt_brainampproxy(cfg)
%
% The configuration should contain
%   cfg.host                 = string, name of computer running the recorder software (default = 'eeg002')
%   cfg.port                 = number, TCP port to connect to (default = 51244)
%   cfg.channel              = cell-array, see CHANNELSELECTION (default = 'all')
%   cfg.feedback             = 'yes' or 'no' (default = 'no')
%
% The target to write the data to is configured as
%   cfg.target.datafile      = string, target destination for the data (default = 'buffer://localhost:1972')
%   cfg.target.dataformat    = string, default is determined automatic
%   cfg.target.eventfile     = string, target destination for the events (default = 'buffer://localhost:1972')
%   cfg.target.eventformat   = string, default is determined automatic
%
% To stop this realtime function, you have to press Ctrl-C

% Copyright (C) 2009, Robert Oostenveld
%
% $Log: not supported by cvs2svn $
% Revision 1.6  2009/05/14 19:38:23  roboos
% moved rdaread into stand-alone function, new name is tcpread
% changed feedback handling
% fixed bug in write_event (was accidentally write_data)
%
% Revision 1.5  2009/02/03 15:37:39  roboos
% added an fprintf line
%
% Revision 1.4  2009/02/03 15:34:49  roboos
% reimplemented the reading and parsing of the stream from the TCP socket to better keep up with the incoming data
% this function has been tested succesfully on 64 channels and 500Hz (only for the 32 bit format)
% the handling of events/markers is NOT YET IMPLEMENTED
%
% Revision 1.3  2009/02/03 11:14:17  roboos
% work in progress, various changes
%
% Revision 1.2  2009/01/30 11:11:55  roboos
% various fixes and improvements, does not yet fully work
%
% Revision 1.1  2009/01/29 22:07:44  roboos
% first implementation
% most functionality for reading is in place, but not yet fully tested
% handling of events still needs to be added
%

cfg = checkconfig(cfg);

% set the defaults
if ~isfield(cfg, 'host'),               cfg.host = 'eeg002';                              end
if ~isfield(cfg, 'port'),               cfg.port = 51244;                                 end % 51244 is for 32 bit, 51234 is for 16 bit
if ~isfield(cfg, 'channel'),            cfg.channel = 'all';                              end
if ~isfield(cfg, 'feedback'),           cfg.feedback = 'no';                              end
if ~isfield(cfg, 'target'),             cfg.target = [];                                  end
if ~isfield(cfg.target, 'datafile'),    cfg.target.datafile = 'buffer://localhost:1972';  end
if ~isfield(cfg.target, 'dataformat'),  cfg.target.dataformat = [];                       end % default is to use autodetection of the output format
if ~isfield(cfg.target, 'eventfile'),   cfg.target.eventfile = 'buffer://localhost:1972'; end
if ~isfield(cfg.target, 'eventformat'), cfg.target.eventformat = [];                      end % default is to use autodetection of the output format

% convert to boolean value
feedback = strcmp(cfg.feedback, 'yes');

% this requires an external toolbox for the TCP communication
hastoolbox('tcp_udp_ip', 1);

% ensure that the persistent variables inside these functions are reinitialized
clear tcpread
clear pnet

% make a connection to the RDA
sock = pnet('tcpconnect', cfg.host, cfg.port);

if (sock<0)
  error('unable to establish connection with host');
else
  fprintf('connection establised with host %s on port %d\n', cfg.host, cfg.port);
end

hdr = [];
while isempty(hdr)
  % read the message header
  msg       = [];
  msg.uid   = tcpread(sock, 16, 'uint8');
  msg.nSize = tcpread(sock, 1, 'int32');
  msg.nType = tcpread(sock, 1, 'int32');

  if feedback
    fprintf('msg.nType = %d\n', msg.nType);
  end

  % if ~isequal(msg.uid, [255 69 88 67 255 255 255 76 255 74 255 255 255 255 20 80])
  %  error('incorrect message identifier');
  % end

  % read the message body
  switch msg.nType
    case 1
      % this is a message containing header details
      msg.nChannels         = tcpread(sock, 1, 'int32');
      msg.dSamplingInterval = tcpread(sock, 1, 'double');
      msg.dResolutions      = tcpread(sock, msg.nChannels, 'double');
      for i=1:msg.nChannels
        msg.sChannelNames{i} = tcpread(sock, char(0), 'char');
      end

      % convert to a fieldtrip-like header
      hdr.nChans  = msg.nChannels;
      hdr.Fs      = 1/(msg.dSamplingInterval/1e6);
      hdr.label   = msg.sChannelNames;
      % determine the selection of channels to be transmitted
      cfg.channel = channelselection(cfg.channel, hdr.label);
      chanindx = match_str(hdr.label, cfg.channel);
      % remember the original header details for the next iteration
      hdr.orig = msg;

    otherwise
      % skip unknown message types
      % error('unexpected message type from RDA (%d)', msg.nType);
  end
end

count = 0;

while (true)
  % read the message header
  msg       = [];
  msg.uid   = tcpread(sock, 16, 'uint8');
  msg.nSize = tcpread(sock, 1, 'int32');
  msg.nType = tcpread(sock, 1, 'int32');

  if feedback
    fprintf('msg.nType = %d\n', msg.nType);
  end

  %   if ~isequal(msg.uid, [255 69 88 67 255 255 255 76 255 74 255 255 255 255 20 80])
  %     error('incorrect message identifier');
  %   end

  % read the message body
  switch msg.nType
    case 2
      % this is a 16 bit integer data block
      msg.nChannels     = hdr.orig.nChannels;
      msg.nBlocks       = tcpread(sock, 1, 'int32');
      msg.nPoints       = tcpread(sock, 1, 'int32');
      msg.nMarkers      = tcpread(sock, 1, 'int32');
      msg.nData         = tcpread(sock, [msg.nChannels msg.nPoints], 'int16');
      for i=1:msg.nMarkers
        msg.Markers(i).nSize      = tcpread(sock, 1, 'int32');
        msg.Markers(i).nPosition  = tcpread(sock, 1, 'int32');
        msg.Markers(i).nPoints    = tcpread(sock, 1, 'int32');
        msg.Markers(i).nChannel   = tcpread(sock, 1, 'int32');
        msg.Markers(i).sTypeDesc  = tcpread(sock, char(0), 'char');
      end

    case 4
      % this is a 32 bit floating point data block
      msg.nChannels     = hdr.orig.nChannels;
      msg.nBlocks       = tcpread(sock, 1, 'int32');
      msg.nPoints       = tcpread(sock, 1, 'int32');
      msg.nMarkers      = tcpread(sock, 1, 'int32');
      msg.fData         = tcpread(sock, [msg.nChannels msg.nPoints], 'single');
      for i=1:msg.nMarkers
        msg.Markers(i).nSize      = tcpread(sock, 1, 'int32');
        msg.Markers(i).nPosition  = tcpread(sock, 1, 'int32');
        msg.Markers(i).nPoints    = tcpread(sock, 1, 'int32');
        msg.Markers(i).nChannel   = tcpread(sock, 1, 'int32');
        msg.Markers(i).sTypeDesc  = tcpread(sock, char(0), 'char');
      end

    case 3
      % acquisition has stopped
      break

    otherwise
      % ignore all other message types
  end

  % convert the RDA message into data and/or events
  dat   = [];
  event = [];

  if msg.nType==2 && msg.nPoints>0
    % FIXME should I apply the calibration here?
    dat = msg.nData(chanindx,:);
  end

  if msg.nType==4 && msg.nPoints>0
    % FIXME should I apply the calibration here?
    dat = msg.fData(chanindx,:);
  end

  if (msg.nType==2 || msg.nType==4) && msg.nMarkers>0
    % FIXME convert the message to events
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % from here onward it is specific to writing the data to another stream
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if ~isempty(dat)
    count = count + 1;
    fprintf('writing %d channels, %d samples\n', size(dat,1), size(dat,2));
    if count==1
      % flush the file, write the header and subsequently write the data segment
      write_data(cfg.target.datafile, dat, 'header', hdr, 'dataformat', cfg.target.dataformat, 'chanindx', chanindx, 'append', false);
    else
      % write the data segment
      write_data(cfg.target.datafile, dat, 'header', hdr, 'dataformat', cfg.target.dataformat, 'chanindx', chanindx, 'append', true);
    end
    dat = [];
  end

  if ~isempty(event)
    % write the events
    fprintf('writing %d events\n', length(event));
    write_event(cfg.target.eventfile, event, 'eventformat', cfg.target.eventformat, 'append', true);
    event = [];
  end

end % while true

% FIXME close the connection, this should be handled in some try-catch statement
pnet(sock,'close');
