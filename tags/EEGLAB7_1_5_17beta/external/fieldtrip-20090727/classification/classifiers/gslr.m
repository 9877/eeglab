classdef gslr < classifier
%GSLR group sparsifying logistic regression
%
%   Group sparsifying logistic regression can be used to regularize a
%   logistic regression model with respect to feature groups. If we 
%   choose p=1 then GSLR reduces to standard l1 regularized logistic regression.
%
%   OPTIONS:
%   options are processed at a lower level (regularize and regularize_lr)
%   except 
%   lcurve : use lcurve approach for model selection (default = false)
%
%   SEE ALSO:
%   regularization_example.m
%   transfer_learning_example.m
%   slr_learn.m
%   slr_learn_transfer.m
%
%   Copyright (c) 2008, Marcel van Gerven
%
%   $Log: not supported by cvs2svn $
%

    properties
        
        model
        options
        diagnostics
        
        lcurve = false; % lcurve approach
      
    end

    methods
       function obj = gslr(varargin)
                            
          obj.options = [];
          
          % parse options
          for i=1:2:length(varargin)
                obj.options.(varargin{i}) = varargin{i+1};
          end
          
          % if true then we use the lcurve approach to find an optimal
          % regularization parameter
          if isfield(obj.options,'lcurve') && obj.options.lcurve
                       
            % use training data to test on
            obj.options.folds = 1;
            
          end            
        
       end
       function obj = train(obj,data,design)
         
         
           % training mode
           if iscell(data), error('classifier does not take multiple datasets'); end                        
           if isnan(obj.nclasses), obj.nclasses = max(design(:,1)); end

           [obj.model,obj.diagnostics] = slr_learn(obj.options,[design(:,1) data]);

           if isfield(obj.options,'lcurve') && obj.options.lcurve
            
             if isfield(obj.options,'verbose') && obj.options.verbose
               fprintf('using l-curve approach to find optimal model; ');
             end

             if isinf(obj.diagnostics.lambdas(1))
               
               % ignore first lambda (inf)
               lcurve = full(obj.diagnostics.lambdas(2:end));
               [idx,fit,err] = lcurve_inflection(lcurve(lcurve ~= 0)); % ignore trailing zeros
               obj.model = obj.diagnostics.path{idx+1};
               
             else
               
               lcurve = full(obj.diagnostics.lambdas);
               [idx,fit,err] = lcurve_inflection(lcurve(lcurve ~= 0)); % ignore trailing zeros
               obj.model = obj.diagnostics.path{idx};
             
             end

             if isfield(obj.options,'verbose') && obj.options.verbose
               fprintf('model index %d selected\n',idx);
             end
           
             obj.options.idx  = idx;
             obj.options.fit  = fit;
             obj.options.err  = err;
             
           end           
                      
       end
       
       function post = test(obj,data)       
           
         post = slr_classify([data ones(size(data,1),1)], obj.model);

       end
       
       function m = getmodel(obj,label,dims)
         % return the parameters wrt a class label in some shape 
         
         if nargin < 2 || isempty(label) || isnan(label)        

           % return model for all classes           
           m = full(obj.model(:,1:(end-1))); % ignore bias term

         else
           m = full(obj.model(label,1:(end-1))); % ignore bias term         
         end
         
         if nargin == 3 && numel(m) == prod(dims)
           m = reshape(m,dims);
         end
         
       end

    end
end 
