% pop_rejtrend() - Detect linear trends in EEG activity and reject the  
%                  epoched trials based on the accuracy of the linear
%                  fit.
% Usage:
%   >> OUTEEG = pop_rejtrend( INEEG, typerej, electrodes, ...
%                winsize, minslope, minR, superpose, reject);
%
% Inputs:
%   INEEG      - input dataset
%   typerej    - type of rejection (1 = independent components; 0 = eeg
%                data). Default is 0.
%   electrodes - [e1 e2 ...] electrodes (number) to take into 
%                consideration for rejection
%   winsize    - integer determining the number of consecutive points
%                for the detection of linear patterns
%   minslope   - minimal absolute slope of the linear trend of the 
%                activity for rejection
%   minR       - minimal R^2 (coefficient of determination between
%                0 and 1)
%   superpose  - 0=do not superpose pre-labelling with previous
%                pre-labelling (stored in the dataset). 1=consider both
%                pre-labelling (using different colors). Default is 0.
%   reject     - 0=do not reject labelled trials (but still store the 
%                labels. 1=reject labelled trials. Default is 0.
%
% Outputs:
%   OUTEEG     - output dataset with labeled rejected sweeps
%     when eegplot is called, modifications are applied to the current 
%     dataset at the end of the call of eegplot (when the user press the 
%     button 'reject').
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: rejtrend(), eeglab(), eegplot(), pop_rejepoch() 

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
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

% 01-25-02 reformated help & license -ad 
% 03-07-02 added srate argument to eegplot call -ad
% 03-07-02 add the eeglab options -ad

function [EEG, com] = pop_rejtrend( EEG, icacomp, elecrange, winsize, ...
				minslope, minstd, superpose, reject, topcommand);

com = '';
if nargin < 1
   help pop_rejtrend;
   return;
end;  
if nargin < 2
   icacomp = 0;
end;  
if icacomp == 1
	if isempty( EEG.icasphere )
	    ButtonName=questdlg( 'Do you want to run ICA now ?', ...
                         'Confirmation', 'NO', 'YES', 'YES');
    	switch ButtonName,
        	case 'NO', disp('Operation cancelled'); return;   
        	case 'YES', [ EEG com ] = pop_runica(EEG);
    	end % switch
	end;
end;	
if nargin < 3

	% which set to save
	% -----------------
	promptstr   = { fastif(icacomp==0, 'Component (number; ex: 2 4 5):', 'Electrode (number; ex: 2 4 5):'), ...
	                'Size of the window of consecutive alike values (in data points)', ... 
					'Minimal absolute slope (trend) of the activity (ex: 0.5):', ...
					'Minimal fit R square (0-1, ex: 0.8):', ...
               		'Cumulate/compare with current rejection', ...
         			'Actually reject trial (YES or NO for just labelling them' };
	inistr      = { ['1:' int2str(EEG.nbchan)], ...
					int2str(EEG.pnts),  ...
					'0.5', ...
					'0.3', ...
               		'NO', ...
            		'NO' };

	result       = inputdlg( promptstr, fastif(icacomp, 'Trend rejection in component -- po_rejtrend()', 'Trend rejection -- po_rejtrend()'), 1,  inistr);
	size_result  = size( result );
	if size_result(1) == 0 return; end;
	elecrange    = result{1};
	winsize      = result{2};
	minslope     = result{3};
	minstd       = result{4};
	switch lower(result{5}), case 'yes', superpose=1; otherwise, superpose=0; end;
	switch lower(result{6}), case 'yes', reject=1; otherwise, reject=0; end;
end;

if isstr(elecrange) % convert arguments if they are in text format 
	calldisp = 1;
	elecrange = eval( [ '[' elecrange ']' ]  );
	winsize   = eval( [ '[' winsize ']' ]  );
	minslope  = eval( [ '[' minslope ']' ]  );
	minstd    = eval( [ '[' minstd ']' ]  );
else
	calldisp = 0;
end;

if icacomp == 0
	[rej rejE] = rejtrend( EEG.data(elecrange, :, :), winsize, minslope, minstd);
else
    % test if ICA was computed or if one has to compute on line
    % ---------------------------------------------------------
    eeg_options; % changed from eeglaboptions 3/30/02 -sm
	if option_computeica  
        icaacttmp = EEG.icaact(elecrange, :, :);
	else
        icaacttmp = EEG.icaweights(elecrange,:)*EEG.icasphere*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts);
        icaacttmp = reshape( icaacttmp, length(elecrange), EEG.pnts, EEG.trials);
    end;
    [rej rejE] = rejtrend( icaacttmp, winsize, minslope, minstd);
end;
fprintf('%d channel selected\n', size(elecrange(:), 1));
fprintf('%d/%d trials rejected\n', length(find(rej > 0)), EEG.trials);

if calldisp
    if icacomp == 0 macrorej  = 'EEG.reject.rejconst';
        			macrorejE = 'EEG.reject.rejconstE';
    else			macrorej  = 'EEG.reject.icarejconst';
        			macrorejE = 'EEG.reject.icarejconstE';
    end;
	eeg_rejmacro; % script macro for generating command and old rejection arrays

	if icacomp == 0
		eeg_multieegplot( EEG.data(elecrange,:,:), rej, rejE, oldrej, oldrejE, 'srate', ...
		      EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000 , 'command', command); 
	else
		eeg_multieegplot( icaacttmp, rej, rejE, oldrej, oldrejE, 'srate', ...
		      EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000 , 'command', command); 
	end;	
end;

com = sprintf('Indexes = pop_rejtrend( %s, %d, [%s], %s, %s, %s, %d, %d);', ...
   inputname(1), icacomp, num2str(elecrange),  num2str(winsize), num2str(minslope), num2str(minstd), superpose, reject ); 

return;
