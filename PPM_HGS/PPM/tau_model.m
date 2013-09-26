%
% This function computes the combined probability P(A|B,C) given the probabilities P(A), P(A|B) and P(A|C) using the hypothesis of permanence of ratios and the tau model
% Author: Thomas Hermans
% Date : November 2012
%
% input parameters :
% - pA = prior probability of the facies P(A)
% - pAB = Conditional probability of A given B P(A|B)
% - pAC = Conditional probability of A given C P(A|C)
% pAB and pAC must have the same size
% - tau = value of exponent tau 
%   tau > 1, more weight is given to C
%   tau < 1, more weight is given to B
%
% output parameter : 
% - pABC = Conditional probability of A given B AND C P(A|B,C)

function pABC = tau_model(pA,pAB,pAC,tau)

% Checking the consistency of sizes of variables
ncell = size(pAB,1);
nfacies = size(pAB,2);
if size(pAC,1)~=ncell
    disp('error : probabilities must be given on similar grids')
end
if length(pA)~=nfacies
    disp('error : the number of facies A must be the same for each event')
end
if size(pAC,2)~=nfacies
    disp('error : the number of facies A must be the same for each event')
end
pABC = zeros(ncell,nfacies);
for i=1:nfacies
%     a=(1-pA(i))/pA(i);
%     for j=1:ncell
%         b=(1-pAB(j,i))/pAB(j,i);
%         c=(1-pAC(j,i))/pAC(j,i);
%         pABC(j,i)=a^tau/(a^tau+b*c^tau);
%     end
    a=ones(ncell,1)*pA(i);
    a=(1-a)./a;
    b=pAB(:,i);
    b=(1-b)./b;
    c=pAC(:,i);
    c=(1-c)./c;
    pABC(:,i)=(a.^tau)./(a.^tau+b.*c.^tau);
end
    sum_pABC=sum(pABC');
    sum_pABC=sum_pABC'*ones(1,nfacies);
    pABC=pABC./sum_pABC;
end