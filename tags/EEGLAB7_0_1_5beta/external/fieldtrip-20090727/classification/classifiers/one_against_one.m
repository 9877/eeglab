classdef one_against_one < classifier
%ONE_AGAINST_ONE one-against-one binary classification
%
%   This class evaluates a binary classifier on all possible pairs of class
%   labels
%
%   EXAMPLE:
%   
%   myproc = clfproc({ ...
%        preprocessor('prefun',@(x)(log10(x))) ...
%        standardizer() ... 
%        one_against_one('procedure',clfproc({gp()})) ...
%        });
%
%   SEE ALSO:
%   ensemble.m
%
%   Copyright (c) 2008, Marcel van Gerven
%
%   $Log: not supported by cvs2svn $
%

    properties        
        procedure = clfproc({da()}); % the used classification procedures
        combination = 'product'; % how to combine classifier output (not how to combine data)
    end
    
    methods
        function obj = one_against_one(varargin)

            obj = obj@classifier(varargin{:});
            
            % exactly one classifier for one-against-one
            assert(~iscell(obj.procedure));
            
        end
        function obj = train(obj,tdata,tdesign)
      
            if iscell(tdata), error('classifier does not take multiple datasets as input'); end

            if isnan(obj.nclasses), obj.nclasses = max(tdesign(:,1)); end

            % transform the data such that we have a cell element for each
            % class label pair
            nclasses = obj.nclasses;

            data = cell(1,nclasses*(nclasses-1)/2);
            design = cell(size(data));

            % create new data representation

            idx = 1;
            for i=1:nclasses
                for j=(i+1):nclasses

                    didx = (tdesign == i | tdesign == j);

                    data{idx} = tdata(didx,:);
                    design{idx} = tdesign(didx,:);
                    design{idx}(design{idx} == i) = 1;
                    design{idx}(design{idx} == j) = 2;

                    idx = idx+1;
                end
            end


            % replicate the classifier
            if ~iscell(obj.procedure)
                procedure = obj.procedure;
                obj.procedure = cell(1,length(data));
                for j=1:length(data)
                    obj.procedure{j} = procedure;
                end
            end

            for j=1:length(data)
                obj.procedure{j} = obj.procedure{j}.train(data{j},design{j});
            end

        end
        
        function post = test(obj,data)
                
            nclasses = obj.nclasses;
            
            cpost = cell(1,nclasses*(nclasses-1)/2);
            
            % get posteriors for all pairs
            idx = 1;
            for i=1:nclasses
                for j=(i+1):nclasses  
                    
                    % use ones to allow for products of probabilities
                    cpost{idx} = ones(size(data,1),obj.nclasses);
                    
                    cpost{idx}(:,[i j]) = cpost{idx}(:,[i j]) + obj.procedure{idx}.test(data);                       
                    idx = idx+1;
                end                
            end

            % combine the result
            post = combine_posteriors(cpost,obj.combination);
                        
        end
        
    end
end