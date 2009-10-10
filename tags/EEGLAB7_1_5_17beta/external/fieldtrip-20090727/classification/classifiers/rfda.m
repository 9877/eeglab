classdef rfda < classifier
%RFDA regularized fisher discriminant analysis
%
%   Copyright (c) 2008, Pawel Herman
%
%   $Log: not supported by cvs2svn $
%

    properties

        kernel_type = 'linear'; 
        kernel_parameter = 1; % kernel parameter
        C = 1; % regularization parameter
        
        % internal parameters
        
        alpha = 0;
        bias = 0;
        SV;
        
    end

    methods
       function obj = rfda(varargin)
                  
           obj = obj@classifier(varargin{:});
                      
       end
       function obj = train(obj,data,design)
            
           if iscell(data), error('RFDA does not take multiple datasets as input'); end
           if isnan(obj.nclasses), obj.nclasses = max(design(:,1)); end           
           if obj.nclasses ~= 2, error ('only valid for two-class problems'); end
           
           design(design == 1) = -1;
           design(design == 2) = 1;
           
           lambda = obj.C;
           obj.SV = data;

           if strcmp(obj.kernel_type,'rbf')
               K = rbf_ker(data,obj.kernel_parameter);
           elseif strcmp(obj.kernel_type,'linear')
               K = data * data';
           else
               disp('Unknown kernel type');
               obj.alpha = 0;
               obj.bias = 0;
               return
           end

           ell = size(K,1);
           ellplus = (sum(design) + ell)/2;
           yplus = 0.5*(design + 1);
           ellminus = ell - ellplus;
           yminus = yplus - design;
           rescale = ones(ell,1)+design*((ellminus-ellplus)/ell);
           plusfactor = 2*ellminus/(ell*ellplus);
           minusfactor = 2*ellplus/(ell*ellminus);
           B = diag(rescale) - (plusfactor * yplus) * yplus' - (minusfactor * yminus) * yminus';
           obj.alpha = (B*K + lambda*eye(ell,ell))\design;
           obj.bias = 0.25*(obj.alpha'*K*rescale)/(ellplus*ellminus);

                       
       end
       function post = test(obj,data)       
           
           if iscell(data), error('RFDA does not take multiple datasets as input'); end
           
           if strcmp(obj.kernel_type,'rbf')
               Ktest = rbf_prim(obj.SV,data,obj.kernel_parameter);
           elseif strcmp(obj.kernel_type,'linear')
               Ktest = obj.SV * data';
           else
               disp('Unknown kernel type');
               post = [];
               return
           end

           sgns = sign(Ktest'*obj.alpha - obj.bias);

           post = zeros(size(sgns,1),obj.nclasses);           
           post(sgns == -1,1) = 1;
           post(sgns == 1,2) = 1;
           
           
       end

    end
end 
