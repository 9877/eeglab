% pop_subcomp() - substract a selected components from a dataset.
%
% Usage:
%   >> OUTEEG = pop_subcomp( INEEG, components, confirm);
%
% Inputs:
%   INEEG      - Input dataset.
%   components - Array of components to subtract. If empty, use the 
%                 pre-labeled components in the dataset 
%                (INEEG.reject.gcompreject).
%   confirm    - Display the difference between original and processed
%                dataset. 1=ask for confirmation. 0=do not ask. 
%                Default 0.
%
% Outputs:
%   OUTEEG     - output dataset.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: compvar()

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
% Revision 1.4  2002/04/11 00:58:12  arno
% updating result size check
%
% Revision 1.3  2002/04/08 02:50:11  scott
% *** empty log message ***
%
% Revision 1.2  2002/04/08 02:48:32  scott
% worked on spelling, made text msg depend on number of pre-labeled comps -sm
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 01-25-02 reformated help & license -ad 
% 02-15-02 propagate ica weight matrix -ad sm jorn 

function [EEG, com] = pop_subcomp( EEG, components, plotag )

com='';
if nargin < 1
   help pop_subcomp;
   return;
end;
if nargin < 3
	plotag = 0;
end;	
if nargin < 2
	% popup window parameters
	% -----------------------
	if ~isempty(EEG.reject.gcompreject)
      components = find(EEG.reject.gcompreject == 1);
      components = components(:)';
   	  promptstr    = { ['Components to subtract from data' 10 '(default: pre-labeled components to reject):'] };
   else
      components = [];
      promptstr    = { ['Components to subtract from data:'] };
   end;
	inistr       = { int2str(components) };
	result       = inputdlg( promptstr, 'Subtract components from data -- pop_subcomp()', 1,  inistr);
	if length(result) == 0 return; end;
	components   = eval( [ '[' result{1} ']' ] );
end;
 
if isempty(components)
	if ~isempty(EEG.reject.gcompreject)
      		components = find(EEG.reject.gcompreject == 0);
   	else
        	fprintf('Warning: no components specified, no rejection performed\n');
         	return;
   	end;
else
    if (max(components) > EEG.nbchan) | min(components) < 1
        error('Component index out of range');
    end;
end;

fprintf('Computing projection ....\n');
eeg_options; 
if option_computeica  
    [ compproj, varegg ] = compvar( EEG.data, EEG.icaact, EEG.icawinv, setdiff(1:EEG.nbchan, components));
else
    [ compproj, varegg ] = compvar( EEG.data, { EEG.icasphere EEG.icaweights }, EEG.icawinv, setdiff(1:EEG.nbchan, components));
end;    
compproj = reshape(compproj, EEG.nbchan, EEG.pnts, EEG.trials);

if  nargin < 2 | plotag ~= 0
   tracing  = [ squeeze(mean(EEG.data,3)) squeeze(mean(compproj,3))];
	figure;   
	plotdata(tracing, EEG.pnts, [EEG.xmin*1000 EEG.xmax*1000 0 0], 'Compare datasets (red=first set; blue=second set)');
end;
%fprintf( 'The ICA projection account for %2.2f percent of the data\n', 100*varegg);
	
if nargin < 2 | plotag ~= 0

    ButtonName=questdlg( 'Do you agree with the projection', ...
                         'Confirmation', 'NO', 'YES', 'YES');
    switch ButtonName,
        case 'NO', 
        	disp('Operation cancelled');
			close(gcf);
        	return;   
        case 'YES',
       		disp('Projection computed');
    end % switch
	close(gcf);
end;
EEG.data  = compproj;
EEG.setname = 'ICA filtered';
EEG.icaact = [];
EEG.icaweights = EEG.icaweights(setdiff(1:EEG.nbchan, components),:);
EEG.icawinv = EEG.icawinv(:,setdiff(1:EEG.nbchan, components));

com = sprintf('%s = pop_subcomp( %s, [%s], %d);', inputname(1), inputname(1), ...
   int2str(components), plotag);
return;
