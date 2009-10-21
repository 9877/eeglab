function flush_header(filename, varargin)

% FLUSH_HEADER removes the header information from the data queue
% this also removes all data associated with the specific header.
%
% Use as
%   flush_header(filename, ...)
%
% See also FLUSH_DATA, FLUSH_EVENT

% Copyright (C) 2007, Robert Oostenveld
%
% $Log: not supported by cvs2svn $
% Revision 1.1  2008/11/13 09:55:36  roboos
% moved from fieldtrip/private, fileio or from roboos/misc to new location at fieldtrip/public
%
% Revision 1.4  2008/10/24 08:54:13  roboos
% added support for format=matlab (i.e. simply delete the file)
%
% Revision 1.3  2008/06/19 20:50:08  roboos
% added support for fcdc_buffer
%
% Revision 1.2  2007/11/05 17:00:38  roboos
% implemented for mysql
%
% Revision 1.1  2007/06/14 06:56:48  roboos
% created stub for flush_data and header, updated documentation
%
%

% set the defaults
headerformat = keyval('headerformat', varargin); if isempty(headerformat), headerformat = filetype(filename); end

switch headerformat
  case 'disp'
    % nothing to do

  case 'fcdc_buffer'
    [host, port] = filetype_check_uri(filename);
    buffer('flush_hdr', [], host, port);

  case 'fcdc_mysql'
    % open the database
    [user, password, server, port] = filetype_check_uri(filename);
    if ~isempty(port)
      server = sprintf('%s:%d', server, port);
    end
    mysql('open', server, user, password);
    % remove all previous header information
    cmd = 'TRUNCATE TABLE fieldtrip.header';
    mysql(cmd);
    mysql('close');

  case 'matlab'
    if exist(filename, 'file')
      warning(sprintf('deleting existing file ''%s''', filename));
      delete(filename);
    end

  otherwise
    error('unsupported data format');
end
