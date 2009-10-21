classdef blinreg < regressor
%BLR Bayesian linear regression with spatiotemporal interactions
%
% Note: 
%   a bias term is added to the model
%
% Copyright (c) 2009, Marcel van Gerven
%
% $Log: not supported by cvs2svn $
%

    properties

      % prior precision matrix of the auxiliary variables
      prior
            
      % variance of the noise term
      varnoise = 1;
      
      % precision of the bias term (will be added to the model)
      precbias = []; % small precision translates into high variance
      
      % (either 'probit' or gaussian 'quadrature' to approximate posterior) 
      approximation = 'quadrature'      
      
      % number of weights for gaussian quadrature
      nweights = 100;
      
      % approximation of the model evidence
      logp

      % estimated parameters
      Gauss
      
      % computation time
      toc
      
      % whether or not EP converged
      convergence
      
      % number of used iterations
      counter
      
      % dimensions of the data; can be used to generate prior
      dims = [];
      
      % coupling strength for each dimension; if numel=1 and dims > 1 then
      % we use that coupling strength for all dimensions
      coupling = [];
      
      scale      = 0.01;  % scale parameter; applied when prior is unspecified and in initialization
      
      % mask that can be used to access only a subset of a volume of data
      % when specifying the coupling
      mask = [];
      
      % some mutable options for laplacedegenerate_ep
      
      fraction    = 0.99;   % fraction or power for fractional/power EP
      niter       = 100;    % maximum number of iterations
      temperature = 1;      % forces MAP like behaviour for t->0
      tolerance   = 1e-5;   % convergence criterion
      degenerate  = [];     % whether or not to run in degenerate mode
      
    end

    methods
       function obj = blinreg(varargin)
       
           % check availability
           if ~exist('LinRegLaplaceEP','file')
               error('not yet available...');
           end
           
           obj = obj@regressor(varargin{:});
           
           if isempty(obj.precbias)
                              
               % NOTE: EP doesnt seem to converge for low precisions 
               % (i.e., large scales)
               %obj.precbias = 0.01 ./ obj.scale;
               
               % we choose the precision of the bias term to be 1/scale
               obj.precbias = 1 ./ obj.scale;
           end                      
           
            if isempty(obj.prior)
               
               nfeatures = prod(obj.dims);
                  
               if isempty(obj.coupling) || isempty(obj.dims)
                   
                   if obj.verbose
                       fprintf('using decoupled prior\n');
                   end
                   
                   obj.prior = spalloc(nfeatures,nfeatures,nfeatures+1);
                   obj.prior(1:(nfeatures+1):numel(obj.prior)) = 1;
                   
               else
                   
                   if numel(obj.coupling)==1 && numel(obj.dims) > 1
                       obj.coupling = obj.coupling*ones(1,numel(obj.dims));
                   end
                   
                   obj.coupling(obj.coupling > 0) = -obj.coupling(obj.coupling > 0);
                   
                   if obj.verbose
                       fprintf('using prior with coupling [ ');
                       fprintf('%g ',obj.coupling);
                       fprintf('], scale %g, and bias precision %g\n',obj.scale,obj.precbias);
                   end
                   
                   obj.prior = construct_prior(obj.dims,obj.coupling,'mask',obj.mask,'circulant',[0 0 0 0]);
                   
               end
               
               obj.prior = scale_prior(obj.prior,'lambda',obj.scale);
               
               % add bias term if not yet done
               obj.prior(nfeatures+1,nfeatures+1) = obj.precbias;               
               
           else
               
               if obj.verbose
                   fprintf('using prespecified prior\n');
               end
               
            end                     
           
       end
       function obj = train(obj,data,design)
           % simply stores input data and design
           
           % some checking
           if iscell(data), error('regressor does not take multiple datasets as input'); end
           
           if isempty(obj.degenerate)
               obj.degenerate = size(data,1) < size(data,2);
           end
           
           if obj.verbose
               if obj.degenerate
                   fprintf('running in degenerate mode\n');
               else
                   fprintf('running in nondegenerate mode\n');
               end
           end
           
           obj.nfeatures = size(data,2);
           obj.nexamples = size(data,1);                     
                                 
           % add bias term
           data = [data ones(size(data,1),1)];
           
           if size(obj.prior,1)==obj.nfeatures
               % add bias term if not yet done
               obj.prior(obj.nfeatures+1,obj.nfeatures+1) = obj.precbias;
           end
          
           % run the algorithm
           [obj.Gauss,terms,obj.logp,obj.toc,obj.convergence,obj.counter] = LinRegLaplaceEP(design(:,1),data,obj.prior, ...
               obj.varnoise,'fraction',obj.fraction,'niter',obj.niter,'temperature',obj.temperature,'lambda',obj.scale,...
               'tol',obj.tolerance,'degenerate',obj.degenerate);
           
           if obj.verbose
               fprintf('EP ran for %d iterations\n',obj.counter);
           end
           
           if ~obj.convergence && obj.verbose
               fprintf('EP did not converge\n');
           else
               fprintf('EP converged\n');
           end
      
          
       end
       function post = test(obj,data)       
           
         error('to do...');
         
           if iscell(data), error('regressor does not take multiple datasets as input'); end
            
           data = [data ones(size(data,1),1)];
           
           % compute univariate means           
           M = data * obj.Gauss.m;
           
           % compute univariate variances on the fly
           % also add the covariance for the betas to the output.

           nsamples = size(obj.Gauss.A,1);
           
           scaledA = obj.Gauss.A .* (repmat(1./obj.Gauss.diagK',nsamples,1));
           W1 = obj.Gauss.A*scaledA';
           % now W1 = A * diag(1./obj.Gauss.diagK) * A'
           
           % add Delta (aka hatK)
           W1(1:(nsamples+1):numel(W1)) = W1(1:(nsamples+1):numel(W1)) + (1./obj.Gauss.hatK)';

           W2 = data*scaledA';
           % now W2 = X * diag(1./obj.Gauss.diagK) * A'

           scaledX = data .* (repmat(1./obj.Gauss.diagK',size(data,1),1));
           W3 = data*scaledX';
           % now W3 = X * diag(1./obj.Gauss.diagK) * X'
           
           C = diag(W3 - (W2 / W1) * W2');
           % changed W2 * inv(W1) * W2' to (W2 / W1) * W2'
                     
           if strcmp(obj.approximation,'probit') % probit approximation
           
             z = M .* (1 + pi .* C./8).^(-0.5);
             y = 1 ./ (1 + exp(-z));
                          
           else % Gaussian quadrature to compute sigma(z) * N(z,m,c)
                               
             nweights = obj.nweights;
             whermite = nan;
             
             % repeat until we have valid points
             while any(isnan(whermite(:)))
               
               [xhermite,whermite] = gausshermite(nweights);
               xhermite = xhermite(:);
               whermite = whermite(:);
               nhermite = length(whermite);
               
               nweights = nweights/2;
             end
             
             x = repmat(M,1,nhermite) + sqrt(C)*xhermite';
             g = logistic(x);   % returns - log (1 + exp(-x)) with special attention for very small and very large x

             h = g + log(repmat(whermite',size(data,1),1));
             maxh = max(h,[],2);
             
             y = exp(maxh) .* sum(exp(h - repmat(maxh,[1 size(h,2)])),2);
           
           end
                      
           post = [y 1 - y];
            
       end
       function [m,varaux,varprior,meanbeta,varbeta] = getmodel(obj,label,dims)
         % return the variances of the auxiliary variables as the model; this 
         % determines in turn the magnitude of the betas through: U = u^2 + v^2
         % we output variances relative to the prior variances
         %
         % other return values:
         % mean of the betas 
         % variance of the betas
         %
         % Note: bias term must be included in prior
         
         varaux = obj.Gauss.auxC(1:(end-1)); % ignore bias term

         % compute variances of the auxiliary variables under the prior
         [L,dummy,S] = chol(sparse(obj.prior),'lower'); 
         invA = fastinvc(L);
         varprior = full(diag(S*invA*S'));
         varprior = varprior(1:(end-1));
         
         % model is posterior variance divided by prior variance of the
         % auxiliary variables; chose minus because of interpretation
         % problems...
         m = (varaux - varprior);
        
         % mean and variance of the regression coefficients
         meanbeta = obj.Gauss.m(1:(end-1));
         varbeta = obj.Gauss.diagC(1:(end-1));
         
         if nargin == 3 && numel(m) == prod(dims)
           
           varaux = reshape(varaux,dims);
           varprior = reshape(varprior,dims);
           m = reshape(m,dims);
           
           meanbeta = reshape(meanbeta,dims);
           varbeta  = reshape(varbeta,dims);
           
         end
         
       end
       
       function [Y,X,B,P,u,v] = sample(obj,M)
         % This function samples from the prior and creates M vectors for 
         % the regression coefficients beta; this function replicates
         % sample_betas and then computes a dataset from it.
         %
         % Y   : outputs
         % X   : covariates
         % B   : regression coefficients
         % P   : Bernoulli probabilities
         % u,v : auxiliary variables
         %
         
         if obj.verbose
           fprintf('sampling betas from auxiliary variables using scaled prior\n');
         end
         
         if nargin < 2, M = 1; end
         n = size(obj.prior,1);
  
         % get samples for auxiliary variables
         u = sample_from_prior(zeros(n,1),obj.prior,M);
         v = sample_from_prior(zeros(n,1),obj.prior,M);
         
         % get samples for betas
         B = normrnd(zeros(n,M),sqrt(u.^2 + v.^2));
                  
         % create random dataset
         X = randn(size(B));
         X(size(B,1),:) = 1; % bias

         Y = X .* B;
                  
         % data as nexamples X nfeatures
         X = X(1:(size(B,1)-1),:)'; % ignore bias term
         Y = Y';
         
       end
       

    end
end 
