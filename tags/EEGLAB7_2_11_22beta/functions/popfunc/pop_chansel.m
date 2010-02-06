% pop_chansel() - pop up a graphic interface to select channels
%
% Usage:
%   >> [chanlist] = pop_chansel(chanstruct); % a window pops up
%   >> [chanlist strchannames cellchannames] = ...
%                        pop_chansel(chanstruct, 'key', 'val', ...);
%
% Inputs:
%   chanstruct     - channel structure. See readlocs()
%
% Optional input:
%   'withindex'      - ['on'|'off'] add index to each entry. May also a be 
%                      an array of indices
%   'select'         - selection of channel. Can take as input all the
%                      outputs of this function.
%   'selectionmode' - selection mode 'multiple' or 'single'. See listdlg2().
%
% Output:
%   chanlist      - indices of selected channels
%   strchannames  - names of selected channel names in a concatenated string
%                   (channel names are separated by space characters)
%   cellchannames - names of selected channel names in a cell array
%
% Author: Arnaud Delorme, CNL / Salk Institute, 3 March 2003

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 3 March 2003 Arnaud Delorme, Salk Institute, arno@salk.edu
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
% Revision 1.25  2007/08/07 00:39:00  arno
% remove debug message
%
% Revision 1.24  2007/08/06 18:32:58  arno
% help message again
%
% Revision 1.23  2007/08/06 18:24:07  arno
% help message
%
% Revision 1.22  2007/08/06 17:31:17  arno
% update help message.
%
% Revision 1.21  2007/08/06 17:30:25  arno
% fix bug 247 about numerical entries
%
% Revision 1.20  2006/05/13 13:29:40  arno
% support for event types with sapce
%
% Revision 1.19  2006/03/29 00:49:38  scott
% txt
%
% Revision 1.18  2006/01/10 00:42:58  arno
% fixing scrolling more than 60 channels
%
% Revision 1.17  2005/09/27 22:03:07  arno
% fix argument 'withindex' must be numeric
%
% Revision 1.16  2005/07/28 15:47:51  arno
% allow using input indices
%
% Revision 1.15  2004/11/10 17:34:46  arno
% add selection mode
%
% Revision 1.14  2004/11/10 17:27:07  arno
% debug last
%
% Revision 1.13  2004/11/10 16:48:02  arno
% NEW CHANNEL SELECTOR
%
% Revision 1.12  2004/11/10 16:09:45  arno
% nothing
%
% Revision 1.11  2003/08/05 18:20:05  arno
% same
%
% Revision 1.10  2003/08/05 18:17:49  arno
% assign default arguments
%
% Revision 1.9  2003/05/14 18:12:32  arno
% typo
%
% Revision 1.8  2003/04/16 00:25:58  arno
% also generate a string with all channels names
%
% Revision 1.7  2003/04/16 00:16:43  arno
% returning channel names
%
% Revision 1.6  2003/03/05 18:53:32  arno
% handle empty entries
%
% Revision 1.5  2003/03/05 18:46:49  arno
% debug for numerical channels
%
% Revision 1.4  2003/03/05 18:34:50  arno
% same
%
% Revision 1.3  2003/03/05 18:33:27  arno
% handling cancel
%
% Revision 1.2  2003/03/04 15:06:27  roberto
% no change
%
% Revision 1.1  2003/03/03 19:32:31  arno
% Initial revision
%

function [chanlist,chanliststr, allchanstr] = pop_chansel(chans, varargin); 
    
    if nargin < 1
        help pop_chansel;
        return;
    end;
    if isempty(chans), disp('Empty input'); return; end;
    if isnumeric(chans),
        for c = 1:length(chans)
            newchans{c} = num2str(chans(c));
        end;
        chans = newchans;
    end;
    chanlist    = [];
    chanliststr = {};
    allchanstr  = '';
    
    g = finputcheck(varargin, { 'withindex'     {  'integer' 'string' } { [] {'on' 'off'} }   'off';
                                'select'        { 'cell' 'string' 'integer' } [] [];
                                'selectionmode' 'string' { 'single' 'multiple' } 'multiple'});
    if isstr(g), error(g); end;
    if ~isstr(g.withindex), chan_indices = g.withindex; g.withindex = 'on';
    else                    chan_indices = 1:length(chans);
    end;
    
    % convert selection to integer
    % ----------------------------
    if isstr(g.select) & ~isempty(g.select)
        g.select = parsetxt(g.select);
    end;
    if iscell(g.select) & ~isempty(g.select)
        if isstr(g.select{1})
            tmplower = lower( chans );
            for index = 1:length(g.select)
                matchind = strmatch(lower(g.select{index}), tmplower, 'exact');
                if ~isempty(matchind), g.select{index} = matchind;
                else error( [ 'Cannot find ''' g.select{index} '''' ] );
                end;
            end;
        end;
        g.select = [ g.select{:} ];
    end;
    if ~isnumeric( g.select ), g.select = []; end;
    
    % add index to channel name
    % -------------------------
	tmpstr = {chans};
    if isnumeric(chans{1})
        tmpstr = [ chans{:} ];
        tmpfieldnames = cell(1, length(tmpstr));
        for index=1:length(tmpstr), 
            if strcmpi(g.withindex, 'on')
                tmpfieldnames{index} = [ num2str(chan_indices(index)) '  -  ' num2str(tmpstr(index)) ]; 
            else
                tmpfieldnames{index} = num2str(tmpstr(index)); 
            end;
        end;
    else
        tmpfieldnames = chans;
        if strcmpi(g.withindex, 'on')
            for index=1:length(tmpfieldnames), 
                tmpfieldnames{index} = [ num2str(chan_indices(index)) '  -  ' tmpfieldnames{index} ]; 
            end;
        end;
    end;
    [chanlist,tmp,chanliststr] = listdlg2('PromptString',strvcat('(use shift|Ctrl to', 'select several)'), ...
                'ListString', tmpfieldnames, 'initialvalue', g.select, 'selectionmode', g.selectionmode);   
    if tmp == 0
        chanlist = [];
        chanliststr = '';
        return;
    else
        allchanstr = chans(chanlist);
    end;
    
    % test for spaces
    % ---------------
    spacepresent = 0;
    if ~isnumeric(chans{1})
        tmpstrs = [ allchanstr{:} ];
        if ~isempty( find(tmpstrs == ' ')) | ~isempty( find(tmpstrs == 9))
            spacepresent = 1;
        end;
    end;
    
    % get concatenated string (if index)
    % -----------------------
    if strcmpi(g.withindex, 'on') | spacepresent
        if isnumeric(chans{1})
            chanliststr = num2str(celltomat(allchanstr));
        else
            chanliststr = '';
            for index = 1:length(allchanstr)
                if spacepresent
                    chanliststr = [ chanliststr '''' allchanstr{index} ''' ' ];
                else
                    chanliststr = [ chanliststr allchanstr{index} ' ' ];
                end;
            end;
            chanliststr = chanliststr(1:end-1);
        end;
    end;
       
    return;
