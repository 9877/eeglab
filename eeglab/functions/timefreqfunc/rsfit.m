% rsfit() - find p value for a given value in a given distribution
%             using Ramberg-Schmeiser distribution
%
% Usage: >> p = rsfit(x, val)
%        >> [p c l chi2] = rsfit(x, val)
%
% Input:
%   x    - [float array] accumulation values
%   val  - [float] value to test
%
% Output:
%   p    - p value
%   c    - [mean var skewness kurtosis] distribution cumulants
%   l    - [4x float vector] Ramberg-Schmeiser distribution best fit
%          parameters.
%   chi2 - [float] chi2 for goodness of fit (based on 12 bins).
%
% Author: Arnaud Delorme, SCCN, 2003
%
% See also: rsadjust(), rsget(), rspdfsolv(), rspfunc()
%
% Reference: Ramberg, J.S., Tadikamalla, P.R., Dudewicz E.J., Mykkytka, E.F.
%            A probability distribution and its uses in fitting data. 
%            Technimetrics, 1979, 21: 201-214.

% Copyright (C) 2003 Arnaud Delorme, SCCN, arno@salk.edu
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
% Revision 1.2  2003/07/09 16:23:01  arno
% adding error messages
%
% Revision 1.1  2003/07/08 15:59:53  arno
% Initial revision
%

function [p, c, l, res] = rsfit(x, val)

    if nargin < 2
        help rsfit;
        return;
    end;
    
    % moments
    % -------
    m1  = mean(x);
    m2  = sum((x-m1).^2)/length(x);
    m3  = sum((x-m1).^3)/length(x);
    m4  = sum((x-m1).^4)/length(x);

    xmean = m1;
    xvar  = m2;
    xskew = m3/(m2^1.5);
    xkurt = m4/(m2^2);
    c     = [ xmean xvar xskew xkurt ];
    
    if xkurt < 0
        disp('rsfit error: Can not fit negative kurtosis');
        save('/home/arno/temp/dattmp.mat', '-mat', 'x');
        disp('data saved to disk in /home/arno/temp/dattmp.mat');        
    end;
    
    % find fit
    % --------
    try, 
        [sol tmp exitcode] = fminsearch('rspdfsolv', [0.1 0.1], optimset('TolX',1e-12, 'MaxFunEvals', 1000000), abs(xskew), xkurt);    
    catch, exitcode = 0; % did not converge
    end;
    if ~exitcode
        try, [sol tmp exitcode] = fminsearch('rspdfsolv', -[0.1 0.1], optimset('TolX',1e-12, 'MaxFunEvals', 1000000), abs(xskew), xkurt);
        catch, exitcode = 0; end;
    end;
    if ~exitcode,           error('No convergence'); end;
    if sol(2)*sol(1) == -1, error('Wrong sign for convergence'); end;
    %fprintf('          l-val:%f\n', sol);
    
    res = rspdfsolv(sol, abs(xskew), xkurt);
    l3 = sol(1);
    l4 = sol(2);

    %load res;
    %[tmp indalpha3] = min( abs(rangealpha3 - xskew) );
    %[tmp indalpha4] = min( abs(rangealpha4 - xkurt) );
    %l3  = res(indalpha3,indalpha4,1);
    %l4  = res(indalpha3,indalpha4,2);    
    %res = res(indalpha3,indalpha4,3);
    
    % adjust fit
    % ----------
    [l1 l2 l3 l4] = rsadjust(l3, l4, xmean, xvar, xskew);
    l = [l1 l2 l3 l4];
    p = rsget(l, val);

    % compute goodness of fit
    % -----------------------
    if nargout > 3

        % histogram of value 12 bins
        % --------------------------
        [N X] = hist(x, 12);
        interval = X(2)-X(1);
        X = [X-interval/2 X(end)+interval/2]; % borders
        
        % regroup bin with less than 5 values
        % -----------------------------------
        for index = 1:length(N)-1
            if N(index) < 5
                N(index+1) = N(index+1) + N(index)
                N(index)   = [];
                X(index+1) = [];
            end;
        end;
        for index = length(N):-1:2
            if N(index) < 5
                N(index-1) = N(index-1) + N(index)
                N(index)   = [];
                X(index) = [];
            end;
        end;
        
        % compute expected values
        % -----------------------
        for index = 1:length(X)-1
            p1 = rsget( l, X(index+1));
            p2 = rsget( l, X(index  ));
            expect(index) = length(allvals)*(p1-p2);
        end;
        
        % value of X2
        % -----------
        res = sum(((expect - N).^2)./expect)
    end;
    return
