% pop_editeventvals() - Edit events contained in an EEG dataset structure. 
%               If the dataset is the only input, a window pops up 
%               allowing the user to insert the relevant parameter values.
%
% Usage: >> EEGOUT = pop_editeventvals( EEG, 'key1', value1, ...
%                                    'key2', value2, ... );
% Input:
%   EEG  - EEG dataset
%
% Optional inputs:
%   'sort'        - { field1 dir1 field2 dir2 } Sort events based on field1
%                   then on optional field2. Arg dir1 indicates the sort 
%                   direction (0 = increasing, 1 = decreasing).
%   'changefield' - {num field value} Insert the given value into the specified 
%                   field in event num. (Ex: {34 'latency' 320.4})
%   'changeevent' - {num value1 value2 value3 ...} Change the values of
%                   all fields in event num.
%   'add'         - {num value1 value2 value3 ...} Insert event before
%                   event num having the specified values.
%   'delete'      - vector of indices of events to delete
%
% Outputs:
%   EEGOUT        - EEG dataset with the selected events only
%
% Ex:  EEG = pop_editeventvals(EEG,'changefield', { 1 'type' 'target'});
%        % set field type of event number 1 to 'target'
%
% Author: Arnaud Delorme, CNL / Salk Institute, 15 March 2002
%
% See also: pop_selectevent(), pop_importevent()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, CNL / Salk Institute, 15 March 2002, arno@salk.edu
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
% Revision 1.18  2003/06/27 23:12:56  arno
% new implementation including append and urevents
%
% Revision 1.17  2003/02/04 21:33:18  arno
% debugging command line call with empty values
%
% Revision 1.16  2002/12/06 03:43:23  arno
% debuging event sorting
%
% Revision 1.15  2002/08/12 18:31:03  arno
% questdlg2
%
% Revision 1.14  2002/06/28 02:32:55  arno
% disabling ori fields
%
% Revision 1.13  2002/06/25 13:58:09  arno
% typo
%
% Revision 1.12  2002/05/21 20:45:23  scott
% removed ; from evalin() calls -sm
%
% Revision 1.11  2002/05/03 02:35:15  arno
% allowing sorting on latency
%
% Revision 1.10  2002/05/03 01:41:57  arno
% updating call for modifying latency
%
% Revision 1.9  2002/04/25 02:14:30  arno
% adding event field description
%
% Revision 1.8  2002/04/22 23:47:57  arno
% debugging 2 variable sorting
%
% Revision 1.7  2002/04/19 20:38:55  arno
% debuging sorting for integer arrays
%
% Revision 1.6  2002/04/18 18:23:39  arno
% typo can not
%
% Revision 1.5  2002/04/18 15:34:07  scott
% editted help msg -sm
%
% Revision 1.4  2002/04/18 15:29:23  scott
% [same] -sm
%
% Revision 1.3  2002/04/18 15:26:41  scott
% added number of events to title -sm
%
% Revision 1.2  2002/04/09 20:54:55  arno
% debuging latency display for latency in continuous data
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 03-16-02 text interface editing -sm & ad 
% 03-18-02 automatic latency switching display (epoch/continuous) - ad & sm 
% 03-18-02 debug soring order - ad
% 03-18-02 put latencies in ms - ad, lf & sm
% 03-29-02 debug latencies in ms - ad & sm
% 04-02-02 debuging test - ad & sm

function [EEG, com] = pop_editeventvals(EEG, varargin);

com ='';
if nargin < 1
   help pop_editeventvals;
   return;
end;	

if nargin >=1 & isstr(EEG)
    strcom = EEG;
    
    % user data
    % ---------
    userdata  = get(gcf, 'userdata');
    EEG       = userdata{1};
    eventtmp  = userdata{2};
    oldcom    = userdata{3};
    allfields = fieldnames(eventtmp);
    tmpind    = strmatch('urevent', allfields);
    allfields(tmpind) = [];
    
    % current event
    % -------------
    objevent  = findobj('parent', gcf, 'tag', 'numval');
    valnum    = str2num(get(objevent, 'string'));
    
    switch strcom
    
     case 'goto', % **********************************************************
      
      % shift time
      % ----------
      shift     = varargin{1};
      valnum    = valnum + shift;
      if valnum < 1,                valnum = 1;                end;
      if valnum > length(eventtmp), valnum = length(eventtmp); end;
      set(objevent, 'string', num2str(valnum));

      % update fields
      % -------------
      for index = 1:length(allfields) 
          
          if strcmp( allfields{index}, 'latency') & ~isempty(eventtmp(valnum).latency)
              if isfield(eventtmp, 'epoch')
                   value = eeg_point2lat( eventtmp(valnum).latency, eventtmp(valnum).epoch, ...
                                          EEG.srate, [EEG.xmin EEG.xmax]*1000, 1E-3);
              else value = (eventtmp(valnum).latency-1)/EEG.srate+EEG.xmin;
              end;
          else value = getfield( eventtmp(valnum), allfields{index});
          end;
          
          % update interface
          % ----------------
          tmpobj = findobj('parent', gcf, 'tag', allfields{index});
          set(tmpobj, 'string', num2str(value));
      end;
      
      % update original
      % --------------- 
      tmpobj = findobj('parent', gcf, 'tag', 'original');
      if isfield(eventtmp, 'urevent') & eventtmp(valnum).urevent ~= valnum
           set(tmpobj, 'string', [ 'originally ' int2str(eventtmp(valnum).urevent)], ...
                       'horizontalalignment', 'center');
      else set(tmpobj, 'string', ' '); 
      end;
          
     case 'append', % **********************************************************

      shift     = varargin{1}; % shift is for adding before or after the event
      if isfield(eventtmp, 'epoch'), curepoch = eventtmp(valnum).epoch; end;
      valnum    = valnum + shift;
      
      % update events
      % -------------
      eventtmp(end+3)          = eventtmp(end);
      eventtmp(valnum+1:end-2) = eventtmp(valnum:end-3);
      eventtmp(valnum)         = eventtmp(end-1);
      eventtmp                 = eventtmp(1:end-2);
      if isfield(eventtmp, 'epoch'), eventtmp(valnum).epoch = curepoch; end;

      % update gui
      % ----------
      userdata{2} = eventtmp;
      set(gcf, 'userdata', userdata);
      pop_editeventvals('goto', shift);
      
      % update commands
      % ---------------
      tmpcell    = cell(1,1+length(fieldnames(eventtmp))); 
      tmpcell{1} = valnum;
      oldcom     = { oldcom{:} 'add', tmpcell };
      
     case 'delete', % **********************************************************
      
      eventtmp(valnum) = []; 
      valnum           = min(valnum,length(eventtmp));
      set(objevent, 'string', num2str(valnum));
      
      % update gui
      % ----------
      userdata{2} = eventtmp;
      set(gcf, 'userdata', userdata);
      pop_editeventvals('goto', 0);

      set(gcf, 'userdata', userdata);
      pop_editeventvals('goto', 0);

      % update commands
      % ---------------
      oldcom = { oldcom{:} 'delete', valnum };
    
     case 'assign', % **********************************************************
      
      field    = varargin{1};
      objfield = findobj('parent', gcf, 'tag', field);
      editval  = get(objfield, 'string');
      if ~isempty(str2num(editval)), editval =str2num(editval); end;
      
      % latency case
      % ------------
      if strcmp( field, 'latency') & ~isempty(editval)
          if isfield(eventtmp, 'epoch')
               editval = eeg_lat2point( editval, eventtmp(valnum).epoch, ...
                                       EEG.srate, [EEG.xmin EEG.xmax]*1000, 1E-3);
          else editval = (editval- EEG.xmin)*EEG.srate+1;
          end;
      end;
      eventtmp(valnum) = setfield(eventtmp(valnum), field, editval);
      
      % update history
      % --------------
      oldcom = { oldcom{:} 'changefield' { valnum field editval }};
     
     case 'sort', % **********************************************************
      
      field1 = get(findobj('parent', gcf, 'tag', 'listbox1'), 'value');
      field2 = get(findobj('parent', gcf, 'tag', 'listbox2'), 'value');
      order1 = get(findobj('parent', gcf, 'tag', 'order1'),   'value');
      order2 = get(findobj('parent', gcf, 'tag', 'order2'),   'value');
      
      newcom = {};
      if field1 > 1, newcom    = { newcom{:} allfields{field1-1} order1 }; end;
      if field2 > 1, newcom    = { newcom{:} allfields{field2-1} order2 }; end;
      if ~isempty(newcom)
          oldevents = EEG.event;
          EEG.event = eventtmp;
          EEG = pop_editeventvals( EEG, 'sort',  newcom );
          eventtmp  = EEG.event;
          EEG.event = oldevents;
      else
          return;
      end;
      
      % update gui
      % ----------
      userdata{2} = eventtmp;
      set(gcf, 'userdata', userdata);
      pop_editeventvals('goto', 0);
      
      
      % update history
      % --------------
      oldcom = { oldcom{:} 'sort' newcom };
      
      % warn user
      % ---------
      warndlg2('Sorting done');
      
    end;
    
    % save userdata
    % -------------
    userdata{2} = eventtmp;
    userdata{3} = oldcom;
    set(gcf, 'userdata', userdata);
    return;
end;

if isempty(EEG.event)
    disp('Getevent: cannot deal with empty event structure');
    return;
end;   

allfields = fieldnames(EEG.event);
tmpind = strmatch('urevent', allfields);
allfields(tmpind) = [];

if nargin<2
    % transfer events to global workspace
    evalin('base', [ 'eventtmp = ' inputname(1) '.event;' ]);

    % add field values
    % ----------------
    geometry = { [2 0.5] };
    tmpstr = sprintf('Edit event field values (currently %d events)',length(EEG.event));
    uilist = { { 'Style', 'text', 'string', tmpstr, 'fontweight', 'bold'  } ...
               { 'Style', 'pushbutton', 'string', 'Delete event', 'callback', 'pop_editeventvals(''delete'');'  }};

    for index = 1:length(allfields) 

        geometry = { geometry{:} [1 1 1 1] };
        
        % input string
        % ------------
        if strcmp( allfields{index}, 'latency')
            if EEG.trials > 1
                 inputstr =  [ allfields{index} ' (ms)'];
            else inputstr =  [ allfields{index} ' (sec)'];
            end;   
		else inputstr =  allfields{index};
		end;
        
		% callback for displaying help
		% ----------------------------
        if index <= length( EEG.eventdescription )
             tmptext = EEG.eventdescription{ index };
			 if ~isempty(tmptext)
				 if size(tmptext,1) > 15,    stringtext = [ tmptext(1,1:15) '...' ]; 
				 else                        stringtext = tmptext(1,:); 
				 end;
			 else stringtext = 'no-description'; tmptext = 'no-description';
			 end;
        else stringtext = 'no-description'; tmptext = 'no-description';
        end;
		cbbutton = ['questdlg2(' vararg2str(tmptext) ...
					',''Description of field ''''' allfields{index} ''''''', ''OK'', ''OK'');' ];

        % create control
        % --------------
        cbedit = [ 'pop_editeventvals(''assign'', ''' allfields{index} ''');' ]; 
		uilist   = { uilist{:}, { }, ...
					 { 'Style', 'pushbutton', 'string', inputstr, 'callback',cbbutton  }, ...
					 { 'Style', 'edit', 'tag', allfields{index}, 'string', '', 'callback', cbedit } ...
                     { } };
    end;

    % add buttons
    % -----------
    geometry = { geometry{:} [1] [1.2 0.6 0.6 1 0.6 0.6 1.2] [1.2 0.6 0.6 1 0.6 0.6 1.2] [2 1 2] };
    
    tpappend = 'Append event before the current event';
    tpinsert = 'Insert event after the current event';
    tporigin = 'Original index of the event (in EEG.urevent table)';
    uilist   = { uilist{:}, ...
          { }, ...
          { },{ },{ }, {'Style', 'text', 'string', 'Event Num', 'fontweight', 'bold' }, { },{ },{ }, ...
          { 'Style', 'pushbutton', 'string', 'Append event',  'callback', 'pop_editeventvals(''append'', 0);', 'tooltipstring', tpappend }, ...
          { 'Style', 'pushbutton', 'string', '<<',            'callback', 'pop_editeventvals(''goto'', -10);' }, ...
          { 'Style', 'pushbutton', 'string', '<',             'callback', 'pop_editeventvals(''goto'', -1);' }, ...
          { 'Style', 'edit',       'string', '1',             'callback', 'pop_editeventvals(''goto'', 0);', 'tag', 'numval' }, ...
          { 'Style', 'pushbutton', 'string', '>',             'callback', 'pop_editeventvals(''goto'', 1);' }, ...
          { 'Style', 'pushbutton', 'string', '>>',            'callback', 'pop_editeventvals(''goto'', 10);' }, ...
          { 'Style', 'pushbutton', 'string', 'Insert event',  'callback', 'pop_editeventvals(''append'', 1);', 'tooltipstring', tpinsert }, ...
          { }, { 'Style', 'text',  'string', ' ', 'tag', 'original' 'horizontalalignment' 'center' 'tooltipstring' tporigin } { } };

    % add sorting options
    % -------------------
    listboxtext = 'No field selected';  
    for index = 1:length(allfields) 
         listboxtext = [ listboxtext '|' allfields{index} ]; 
    end;
    geometry = { geometry{:} [1] [1 1 1] [1 1 1] [1 1.5 0.5] };
    uilist = {  uilist{:}, ...
         { 'Style', 'text',       'string', 'Re-order events (for review only)', 'fontweight', 'bold'  }, ...
         { 'Style', 'text',       'string', 'Main sorting field:'  }, ...
         { 'Style', 'listbox',    'string', listboxtext, 'tag', 'listbox1' }, ...
         { 'Style', 'checkbox',   'string', 'Click for decreasing order', 'tag', 'order1' } ...
         { 'Style', 'text',       'string', 'Secondary sorting field:'  }, ...
         { 'Style', 'listbox',    'string', listboxtext, 'tag', 'listbox2' }, ...
         { 'Style', 'checkbox',   'string', 'Click for decreasing order', 'tag', 'order2' }, ...
         { 'Style', 'pushbutton', 'string', 'Re-sort', 'callback', 'pop_editeventvals(''sort'');' }, ...
         { }, { }};
   
    userdata = { EEG EEG.event {} };
    inputgui( geometry, uilist, 'pophelp(''pop_editeventvals'');', ...
                                  'Edit event values -- pop_editeventvals()', userdata, 'plot');
    pop_editeventvals('goto', 0);
    
    % wait for figure
    % ---------------
    fig = gcf;
    waitfor( findobj('parent', fig, 'tag', 'ok'), 'userdata');
    try, userdata = get(fig, 'userdata'); close(fig); % figure still exist ?
    catch, return; end;
    
    % transfer events
    % ---------------
    tmpevents = userdata{2};
    EEG.event = tmpevents;
    com       = sprintf('%s = pop_editeventvals(%s,%s);', inputname(1), inputname(1), vararg2str(userdata{3}));
    return;
    
else % no interactive inputs
    args = varargin;
end;

% scan all the fields of g
% ------------------------
for curfield = 1:2:length(args)
    switch lower(args{curfield})
        case 'sort', 
            tmparg = args{ curfield+1 };
            if length(tmparg) < 2, dir1 = 0;
            else                   dir1 = tmparg{2}; 
            end;
            if length(tmparg) > 2
	            if length(tmparg) < 4, dir2 = 0;
	            else                   dir2 = tmparg{4}; 
	            end;
	            try, eval(['tmparray = cell2mat( { EEG.event.' tmparg{3} ' } );']);
	            catch, eval(['tmparray = { EEG.event.' tmparg{3} ' };']);
	            end;
				if strcmp( tmparg{3}, 'latency') & EEG.trials > 1
					tmparray = eeg_point2lat(tmparray, {EEG.event.epoch}, EEG.srate, [EEG.xmin EEG.xmax], 1);
				end;
	            [X I] = sort( tmparray );
	            if dir2 == 1, I = I(end:-1:1); end;
	            events = EEG.event(I);
	        else
	            events = EEG.event;
	        end;  
            try, eval(['tmparray = cell2mat( { events.' tmparg{1} ' } );']);
            catch, eval(['tmparray = { events.' tmparg{1} ' };']);
	        end;
			if strcmp( tmparg{1}, 'latency') & EEG.trials > 1
				tmparray = eeg_point2lat(tmparray, {events.epoch}, EEG.srate, [EEG.xmin EEG.xmax], 1);
			end;
	        [X I] = sort( tmparray );
	        if dir1 == 1, I = I(end:-1:1); end;
	        EEG.event = events(I);
	   case 'delete'
	        EEG.event(args{ curfield+1 })=[];
	   case 'changefield'
            tmpargs = args{ curfield+1 };
            if length( tmpargs ) < 3
                error('Pop_editeventvals: not enough arguments to change field value');
            end;
            valstr = reformat(tmpargs{3}, strcmp(tmpargs{2}, 'latency'), EEG.trials > 1, tmpargs{1} );
            eval([ 'EEG.event(' int2str(tmpargs{1}) ').'  tmpargs{2} '=' fastif(isempty(valstr), '[]', valstr) ';' ]);
	   case 'add'
            tmpargs = args{ curfield+1 };
            allfields = fieldnames(EEG.event);
            if length( tmpargs ) < length(allfields)+1
                error('Pop_editeventvals: not enough arguments to change all field values');
            end;
            num = tmpargs{1};
            EEG.event(end+1) = EEG.event(end);
            EEG.event(num+1:end) = EEG.event(num:end-1);
            for index = 1:length( allfields )
                valstr = reformat(tmpargs{index+1}, strcmp(allfields{index}, 'latency'), EEG.trials > 1, num );
                eval([ 'EEG.event(' int2str(num) ').' allfields{index} '=' fastif(isempty(valstr), '[]', valstr) ';' ]);
	        end;
	   case 'changeevent'
            tmpargs = args{ curfield+1 };
            num = tmpargs{1};
            allfields = fieldnames(EEG.event);
            if length( tmpargs ) < length(allfields)+1
                error('Pop_editeventvals: not enough arguments to change all field values');
            end;
            for index = 1:length( allfields )
                valstr = reformat(tmpargs{index+1}, strcmp(allfields{index}, 'latency'), EEG.trials > 1, num );
                eval([ 'EEG.event(' int2str(num) ').' allfields{index} '=' fastif(isempty(valstr), '[]', valstr) ';' ]);
	        end;
	end;
end;

% generate the output command
% ---------------------------
if exist('userdat') == 1
    if ~isempty(userdat)
        args = { args{:} userdat{:} };
    end;
end; 
com = sprintf('EEG = pop_editeventvals( %s', inputname(1));
for i=1:2:length(args)
    if iscell(args{i+1})
        com = sprintf('%s, ''%s'', {', com, args{i} );
        tmpcell = args{i+1};
        for j=1:length(tmpcell);
            if isstr( tmpcell{j} )   com = sprintf('%s ''%s'',', com, tmpcell{j} );
            else                     com = sprintf('%s [%s],',   com, num2str(tmpcell{j}) );
            end;
        end;
        com = sprintf('%s } ', com(1:end-1));     
    else
        com = sprintf('%s, ''%s'', [%s]', com, args{i}, num2str(args{i+1}) );
    end;       
end;
com = [com ');'];

return;

% format the output field
% -----------------------
function strval = reformat( val, latencycondition, trialcondition, eventnum)
    if latencycondition
        if trialcondition > 1
            strval = ['eeg_point2lat(' num2str(val) ', EEG.event(' int2str(eventnum) ').epoch, EEG.srate,[EEG.xmin EEG.xmax]*1000, 1E-3);' ];
        else    
            strval = [ '(' num2str(val) '-EEG.xmin)*EEG.srate+1;' ]; 
        end;
    else
        if isstr(val), strval = [ '''' val '''' ];
        else           strval = num2str(val);
        end;
    end;
