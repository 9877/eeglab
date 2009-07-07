function dif = meandiff(data,design)
% MEANDIFF computes the l2 norm of the difference between the means of the data of
% different classes w.r.t. the global mean per feature
%
%   dif = meandiff(data,design)
%
%   Copyright (c) 2008, Marcel van Gerven
%
%   $Log: not supported by cvs2svn $
%

    nclasses = max(design(:,1));
    nfeatures = size(data,2);

    dif = zeros(nclasses,nfeatures);
    for j=1:nclasses        
        dif(j,:) = nanmean(data(design==j,:));
    end
    dif = dif - repmat(nanmean(data),[nclasses 1]);
    dif = sqrt(sum(dif.^2));

end
