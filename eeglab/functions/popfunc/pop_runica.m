% pop_runica() - run ica on a dataset
%
% Usage:
%   >> OUT_EEG = pop_runica( IN_EEG, ica_type, options );
%
% Inputs:
%   IN_EEG      - input dataset
%   ica_type    - ['runica'|'binica'|'jader'|'fastica'] The ICA algorithm 
%                 to use for the ICA decomposition. The nature of any 
%                 differences in the results of these algorithms have 
%                 not been well characterized. Default is binica() if
%                 it exists on the system, else runica().
%   options     - ICA algorithm options (see ICA routine help messages).
% 
% Note:
% 1) Infomax is the ICA algorithm we use most. It is based on Tony Bell's
%    algorithm, implemented by Scott Makeig using the natural gradient of 
%    Amari. It can also extract sub-Gaussian sources using the 'extended'
%    ICA option of Lee and Girolami. 
%    runica() is the all-Matlab version. binica() calls the (12x faster) 
%    binary version (separate download) translated to C by Sigurd Enghoff
% 2) jader() calls the JADE algorithm of Jean-Francois Cardoso
%    It is included in the EEGLAB toolbox.
% 3) To run fastica(), download the fastICA toolbox from
%    http://www.cis.hut.fi/projects/ica/fastica/ and make it available 
%    in your Matlab path. According to the authors, defaults parameters
%    are not optimal: try 'approach', 'sym' to estimate components in
%    parallel.
%
% Outputs:
%   OUT_EEG     - output dataset with ica computed
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: runica(), binica(), jader(), fastica()

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
% 03-07-02 add the eeglab options -ad
% 03-18-02 add other decomposition options -ad
% 03-19-02 text edition -sm

function [EEG, com] = pop_runica( EEG, icatype, varargin )

com = '';
if nargin < 1   
    help pop_runica;
    return;
end;

if nargin < 2 
    % popup window parameters
    % -----------------------
    promptstr    = { [ 'ICA algorithm to use [ runica | binica | jader | fastICA ]' 10 ...
                       '' ] ...
                      ['Commandline options (See algorithm help messages)']};
	inistr       = { 'runica' '' };
	result       = inputdlg( promptstr, 'Run ICA decomposition -- pop_runica()', 1,  inistr);
	if length(result) == 0 return; end;
	icatype      = result{1};
	options      = [ ',' result{2} ];
else
	options = [];
	for i=1:length( varargin )
		if isstr( varargin{ i } )
			options = [ options ', ''' varargin{i} '''' ];
		else
			options = [ options ', [' num2str(varargin{i}) ']' ];
		end;
	end;	
end;

%------------------------------
% compute ICA on a definite set
% -----------------------------
tmpdata = reshape( EEG.data, EEG.nbchan, EEG.pnts*EEG.trials);
switch lower(icatype)
    case 'runica' 
        if length(options) < 2
            [EEG.icaweights,EEG.icasphere] = runica( tmpdata, 'lrate', 0.001 );
        else    
            eval(sprintf('[EEG.icaweights,EEG.icasphere] = runica( tmpdata %s );', options));
        end;
     case 'binica'
        if ~isunix
            error('Pop_runica: binica can now only be used under UNIX');
        end;
        icadefs;
        if exist(ICABINARY) ~= 2
            error('Pop_runica: binica C program can not be found. Edit icadefs.m file and change ICABINARY variable');
        end;
        if length(options) < 2
            [EEG.icaweights,EEG.icasphere] = binica( tmpdata, 'lrate', 0.001 );
        else    
            eval(sprintf('[EEG.icaweights,EEG.icasphere] = binica(tmpdata %s );', options));
        end;
     case 'jader' 
        if length(options) < 2
            [EEG.icaweights] = jader( tmpdata );
        else    
            eval(sprintf('[EEG.icaweights] = jader( tmpdata %s );', options));
        end;
        EEG.icasphere = eye(size(EEG.icaweights,2));
     case 'fastica'
        if exist('fastica') ~= 2
            error('Pop_runica: for fast ica, you must first download the toolbox (see >> help pop_runica)');
        end;     
        if length(options) < 2
            [ ICAcomp, EEG.icaweights,EEG.icasphere] = fastica( tmpdata, 'displayMode', 'off' );
        else    
            eval(sprintf('[ ICAcomp, EEG.icaweights,EEG.icasphere] = fastica( tmpdata %s );', options));
        end;
     otherwise, error('Pop_runica: unrecognized algorithm');
end;
EEG.icawinv    = pinv(EEG.icaweights*EEG.icasphere); % a priori same result as inv

eeg_options; % changed from eeglaboptions 3/30/02 -sm
if option_computeica
    EEG.icaact    = (EEG.icaweights*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts);
    EEG.icaact    = reshape( EEG.icaact, EEG.nbchan, EEG.pnts, EEG.trials);
end;
if length(options < 2)
    com = sprintf('%s = pop_runica(%s, ''%s'');', inputname(1), inputname(1), icatype);
else
    com = sprintf('%s = pop_runica(%s, ''%s'' %s);', inputname(1), icatype, options);
end;
return;
