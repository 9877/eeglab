% pop_signalstat() - Computes and plots statistical characteristics of a signal,
%                    including the data histogram, a fitted normal distribution,
%                    a normal ditribution fitted on trimmed data, a boxplot, and
%                    the QQ-plot. The estimates value are printed in a panel and
%                    can be read as output. See SIGNALSTAT.
%
% Usage:
%   >>  OUTEEG = pop_signalstat( EEG, type ); % pops up
%   >>  [M,SD,sk,k,med,zlow,zhi,tM,tSD,tndx,ksh] = pop_signalstat( EEG, type, cnum );
%   >>  [M,SD,sk,k,med,zlow,zhi,tM,tSD,tndx,ksh] = pop_signalstat( EEG, type, cnum, percent );
%
% Inputs:
%   EEG   - input EEG dataset
%   type  - type of processing
%           1: process the raw  data; 0: the ICA components
%   cnum  - selected channel or component
%    
% Outputs:
%   OUTEEG  - output dataset
%
% See also:
%   SIGNALSTAT,  EEGLAB 

% Copyright (C) 2002 Luca Finelli, Salk/SCCN, La Jolla, CA
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

function varargout = pop_signalstat( EEG, typeproc, cnum, percent );

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            
varargout{1} = '';

% display help if not enough arguments
% ------------------------------------
if nargin < 2
	help pop_signalstat;
	return;
end;	
popup=0;
if nargin < 3
	popup = 1;
end;
if nargin < 4
	percent=5;
end;

% pop up window
% -------------
if (nargin < 3 & typeproc==1)
	promptstr    = { 'Enter EEG channel:'; 'Percent for trimmed statistics:' };
	inistr       = { '1';'5' };
	result       = inputdlg( promptstr, 'EEG channel selection', 1,  inistr);
	if length( result ) == 0 return; end;
	cnum   	     = eval( [ '[' result{1} ']' ] ); % the brackets allow to process matlab arrays
	percent      = eval( [ '[' result{2} ']' ] );
elseif (nargin < 3 & typeproc==0)
	promptstr    = { 'Enter component number:'; 'Percent for trimmed statistics:' };
	inistr       = { '1'; '5' };
	result       = inputdlg( promptstr, 'Component selection', 1,  inistr);
	if length( result ) == 0 return; end;
	cnum    	 = eval( [ '[' result{1} ']' ] ); % the brackets allow to process matlab arrays
    percent      = eval( [ '[' result{2} ']' ] );
end;

if length(cnum) ~= 1 | (cnum-floor(cnum)) ~= 0
	error('pop_signalstat(): Component index must be a single integer');
end

if cnum < 1 | cnum > EEG.nbchan
   error('pop_signalstat(): Component index out of range');
end;   

% call function signalstat() either on raw data or ICA data
% ---------------------------------------------------------
if typeproc == 1
	tmpsig=EEG.data(cnum,:);
%	[M,SD,sk,k,med,zlow,zhi,tM,tSD,tndx,ksh]=signalstat( EEG.data(cnum,:),1,[], percent);
	dlabel=[];
else 
	if ~isempty( EEG.icasphere )
        eeg_options; 
 	    if option_computeica  
    		tmpsig = EEG.icaact(cnum,:);
 	    else
            tmpsig = (EEG.icaweights(cnum,:)*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*size(EEG.data,2));
        end;
	%	[M,SD,sk,k,med,zlow,zhi,tM,tSD,tndx,ksh]=signalstat( tmpsig,1,'Component activity',percent);
		dlabel='Component activity';
	else
		error('You must run ICA first');
	end;	
end;	 

% outputs
% -------
outstr = '';
if ~popup
    for io = 1:nargout, outstr = [outstr 'varargout{' int2str(io) '},' ]; end;
    if ~isempty(outstr), outstr = [ '[' outstr(1:end-1) '] =' ]; end;
end;

% return the string command
% -------------------------
fprintf('Pop_signalstat: computing statistics...\n');
varargout{1} = sprintf('pop_signalstat( %s, %d, %d );', inputname(1), typeproc, cnum);
com          = sprintf('%s signalstat( tmpsig, 1, dlabel, percent ); %s', outstr);

eval(com)	
set(gcf, 'color', [1 1 1]);

return;
