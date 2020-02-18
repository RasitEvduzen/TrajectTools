function out = int_pBasis(pBasis,n_int,initval)
%int_pBasis - integral polynomial basis
%
% out = int_pBasis(pBasis,n_int,initval)
%   pBasis  : polynomial basis generated by polySolve
%   n_int   : order of integration
%   initval : initial value(s) 
%             e.g. initval = [0;,... % initial values for the first integration
%                            0;]; % initial values for the second integration
%   out     : ingegrated polynomial basis
%             see outPolyBasis
% Author    : Wataru Ohnishi, University of Tokyo, 2020
%%%%%

if nargin < 2, n_int = 1; end

if nargin < 3 || isempty(initval)
    initval = zeros(n_int,1);
end
k = 1;
while k <= n_int
    pBasis = int_pBasis_main(pBasis,initval(k));
    k = k + 1;
end
out = pBasis;
end


function out = int_pBasis_main(pBasis,initval)
if ~iscell(pBasis), pBasis = {pBasis}; end
nofpoly = length(pBasis); % number of trajectory segments
out = cell(1,nofpoly);

out{1}.BCt = pBasis{1}.BCt;
out{1}.BC0 = [initval; pBasis{1}.BC0;];
temp = polyint(pBasis{1}.a_syms(1,:));
temp = [zeros(1,length(pBasis{1}.a_syms(1,:))-length(temp)+1),temp];
temp(end) = out{1}.BC0(1)-polyval(double(temp),out{1}.BCt(1));
out{1}.a_syms = [temp; ...
    [zeros(size(pBasis{1}.a_syms,1),1),pBasis{1}.a_syms]];
out{1}.a_vpas = double(out{1}.a_syms);
out{1}.BC1 = [polyval(out{1}.a_vpas(1,:),out{1}.BCt(2));...
    pBasis{1}.BC1;];
out{1} = orderfields(out{1});

for k = 2:nofpoly
    out{k}.BCt = pBasis{k}.BCt;
    out{k}.BC0 = out{k-1}.BC1;
    temp = polyint(pBasis{k}.a_syms(1,:));
    temp = [zeros(1,length(pBasis{k}.a_syms(1,:))-length(temp)+1),temp];
    temp(end) = out{k}.BC0(1)-polyval(double(temp),out{k}.BCt(1));
    out{k}.a_syms = [temp; ...
        [zeros(size(pBasis{k}.a_syms,1),1),pBasis{k}.a_syms]];
    out{k}.a_vpas = double(out{k}.a_syms);
    out{k}.BC1 = [polyval(out{k}.a_vpas(1,:),out{k}.BCt(2));...
        pBasis{k}.BC1];
    out{k} = orderfields(out{k});
end
end