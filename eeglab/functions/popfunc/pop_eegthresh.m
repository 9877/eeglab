% pop_eegthresh() - rejection of artifact in a dataset using thresholding
%               (i.e. standard) method.
%
% Usage:
%   >> Indexes = pop_eegthresh( INEEG, typerej, elec_comp, negthresh, ...
%                posthresh, starttime, endtime, superpose, reject);
%
% Inputs:
%   INEEG      - input dataset
%   typerej    - type of rejection (0 = independent components; 1 = eeg
%              data). Default is 1. For independent components, before
%              thresholding, the activity is normalized for each 
%              component.
%   elec_comp  - [e1 e2 ...] electrodes (number) or components to take 
%              into consideration for rejection
%   negthresh  - negative threshold limit in mV (can be an array if 
%              several electrodes; if less numbe  of values than number 
%              of electrodes the last value is used for the remaining 
%              electrodes). For independent component, this threshold is
%              expressed in term of standard deviation. 
%   posthresh  - positive threshold limit in mV (same syntax as negthresh)
%   starttime  - starting time limit in second (same syntax as negthresh)
%   endtime    - ending time limit in second (same syntax as negthresh)
%   superpose  - 0=do not superpose pre-labelling with previous
%              pre-labelling (stored in the dataset). 1=consider both
%              pre-labelling (using different colors). Default is 0.
%   reject     - 0=do not reject labelled trials (but still store the 
%              labels. 1=reject labelled trials. Default is 0.
%
% Outputs:
%   Indexes    - index of rejected sweeps
%     when eegplot is called, modifications are applied to the current 
%     dataset at the end of the call of eegplot (when the user press the 
%     button 'reject').
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: eegthresh(), eeglab(), eegplot(), pop_rejepoch() 

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

function [EEG, I1, com] = pop_eegthresh( EEG, icacomp, elecrange, negthresh, posthresh, ...
   						starttime, endtime, superpose, reject, topcommand);

I1 = [];
com = '';
if nargin < 1
   help pop_eegthresh;
   return;
end;  
if nargin < 2
   icacomp = 0;
end;  

icacomp = ~icacomp;
if icacomp == 1
	if isempty( EEG.icasphere )
		disp('Error: you must run ICA first'); return;
	end;
end;

if nargin < 3

	% which set to save
	% -----------------
	promptstr   = { fastif(icacomp==0, 'Component (number; ex: 2 4 5):', 'Electrode (number; ex: 2 4 5):'), ...
					fastif(icacomp==0, 'Negative thresholds (std: ex:-3 -4 -2):', 'Negative thresholds (mV; ex:-20 -10 -15):'), ...
					fastif(icacomp==0, 'Positive thresholds (std: ex:3 4 2):', 'Positive thresholds (mV; ex:20 10 15):'), ...
					'Starttime(s;ex -0.1 0.3):', ...
					'Entime(s;ex 0.2):', ...
               'Cumulate/compare with current rejection', ...
         		'Actually reject trial (YES or NO for just labelling them' };
	inistr      = { fastif(icacomp==0, ['1:' int2str(EEG.nbchan)], '1:5'), ...
					fastif(icacomp==0, '-10', '-20'),  ...
					fastif(icacomp==0, '10', '20'), ...
					num2str(EEG.xmin), ...
					num2str(EEG.xmax), ...
               'NO', ...
            	'NO' };

	result       = inputdlg( promptstr, fastif(icacomp, 'Trial rejection using components -- pop_eegthresh()', 'Classic trials rejection -- pop_eegthresh()'), 1,  inistr);
	size_result  = size( result );
	if size_result(1) == 0 return; end;
	elecrange    = result{1};
	negthresh    = result{2};
	posthresh    = result{3};
	starttime    = result{4};
	endtime      = result{5};
	switch lower(result{6}), case 'yes', superpose=1; otherwise, superpose=0; end;
	switch lower(result{7}), case 'yes', reject=1; otherwise, reject=0; end;
end;

if isstr(elecrange) % convert arguments if they are in text format 
	calldisp = 1;
	elecrange = eval( [ '[' elecrange ']' ]  );
	negthresh = eval( [ '[' negthresh ']' ]  );
	posthresh = eval( [ '[' posthresh ']' ]  );
	starttime = eval( [ '[' starttime ']' ]  );
	endtime   = eval( [ '[' endtime ']' ]  );
else
	calldisp = 0;
end;

if any(starttime < EEG.xmin) fprintf('Warning : starttime inferior to minimum time, adjusted'); starttime(find(starttime < EEG.xmin)) = EEG.xmin; end;
if any(endtime   > EEG.xmax) fprintf('Warning : starttime inferior to minimum time, adjusted'); endtime(find(endtime > EEG.xmax)) = EEG.xmax;end;

if icacomp == 0
	[I1 Irej NS Erej] = eegthresh( EEG.data, EEG.pnts, elecrange, negthresh, posthresh, [EEG.xmin EEG.xmax], starttime, endtime);
else
    % test if ICA was computed
    % ------------------------
    eeg_options; % changed from eeglaboptions 3/30/02 -sm
 	if option_computeica  
    	icaacttmp = EEG.icaact(elecrange, :, :);
	else
        icaacttmp = (EEG.icaweights(elecrange,:)*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts);
        icaacttmp = reshape( icaacttmp, length(elecrange), EEG.pnts, EEG.trials);
    end;
	[Irej Erejtmp] = eegthresh( icaacttmp, 1:length(elecrange), negthresh, posthresh, [EEG.xmin EEG.xmax], starttime, endtime);
    Erej = zeros(size(EEG.icaweights,1), size(EEG.trials,2));
    Erej(elecrange,:) = Erejtmp;
end;

fprintf('%d channel selected\n', size(elecrange(:), 1));
fprintf('%d/%d trials rejected\n', size(I2(:), 1), EEG.trials);
tmprejectelec = zeros( 1, EEG.trials);
tmprejectelec(I2) = 1;
if icacomp
   tmpelecIout = zeros(EEG.nbchan, EEG.trials);
else
   tmpelecIout = zeros(size(EEG.icaweight,1), EEG.trials);
end;
tmpelecIout(elecrange, I2) = tmprej;

if calldisp
    if icacomp == 0 macrorej  = 'EEG.reject.rejthresh';
        			macrorejE = 'EEG.reject.rejthreshE';
    else			macrorej  = 'EEG.reject.icarejthresh';
        			macrorejE = 'EEG.reject.icarejthreshE';
    end;
	eeg_rejmacro; % script macro for generating command and old rejection arrays
	     
    if icacomp == 0
        eeg_multieegplot( EEG.data(elecrange,:,:), tmprejectelec, tmpelecIout(elecrange,:), oldrej, oldrejE, 'srate', ...
		      EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000 , 'command', command); 
    else
        eeg_multieegplot( icaacttmp, tmprejectelec, tmpelecIout(elecrange,:), oldrej, oldrejE, 'srate', ...
		      EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000 , 'command', command); 
    end;	
end;

com = sprintf('Indexes = pop_eegthresh( %s, %d, [%s], [%s], [%s], [%s], [%s], %d, %d);', ...
   inputname(1), ~icacomp, num2str(elecrange),  num2str(negthresh), ...
   num2str(posthresh), num2str(starttime ) , num2str(endtime), superpose, reject ); 

return;

% reject artifacts in a sequential fashion to save memory (ICA ONLY)
% -------------------------------------------------------
function [Irej, Erej] = thresh( data, elecrange, timerange, negthresh, posthresh, starttime, endtime);
    Irej    = [];
    Erej    = zeros(size(data,1), size(data,2));
    for index = 1:length(elecrange)
       tmpica = data(index,:,:);
       tmpica = reshape(tmpica, 1, size(data,2)*size(data,3));
       
       % perform the rejection
       % ---------------------	
	   tmpica = (tmpica-mean(tmpica,2)*ones(1,size(tmpica,2)))./ (std(tmpica,0,2)*ones(1,size(tmpica,2)));
	   [I1 Itmprej NS Etmprej] = eegthresh( tmpica, size(data,2), 1, negthresh, posthresh, ...
						timerange, starttime, endtime);
 	   Irej = union(Irej, Itmprej);
 	   Erej(elecrange(index),Itmprej) = Etmprej;
	end;

