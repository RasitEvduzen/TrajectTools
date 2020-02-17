function pBasis = backandforth(trajType,BCt,BC,np,showFig)

if nargin < 5
    showFig = false;
end

trajType = lower(trajType);
nofpoly = length(BCt)-1;
pBasis = cell(1,nofpoly);

switch trajType
    case 'pos'
        % BC denotes the position boundary conditions
        BCp = BC;
        for k = 1:nofpoly % boudary condition calc for each segments
            initval = [BCp(k); zeros((np+1)/2-1,1);];
            finval = [BCp(k+1); zeros((np+1)/2-1,1);];
            pBasis{k} = polySolve(BCt(k),BCt(k+1),initval,finval,np,0);
        end
    case 'vel'
        % BC (cell) denotes
        % BC{1}: initial position
        % BC{2}: velocity boundary conditions
        BCp0 = BC{1};
        BCv = BC{2};
        dp = BCv2BCp(BCv,BCt);
        BCp = [BCp0,cumsum(dp)+BCp0];
        for k = 1:nofpoly % boudary condition calc for each segments
            initval = [BCp(k); BCv(k); zeros((np+1)/2-2,1);];
            finval = [BCp(k+1); BCv(k+1); zeros((np+1)/2-2,1);];
            pBasis{k} = polySolve(BCt(k),BCt(k+1),initval,finval,np,0);
        end
    otherwise
        error('error!')
end

if showFig
    dt = (pBasis{end}.BCt(end)-pBasis{1}.BCt(1));
    t = pBasis{1}.BCt(1)-dt/10:dt/1000:pBasis{end}.BCt(end)+dt/10;
    outPolyBasis(pBasis,1,t,showFig);
end

end

function dp = BCv2BCp(BCv,BCt)
% delta p
% syms t1 t2 v1 v2 t real
% p(t) = (v2-v1)/(t2-t1) * (t-t1) + v1;
% dp = int(p,t1,t2)

dt = diff(BCt);
vave = movmean(BCv,2); vave = vave(2:end);

dp = vave.*dt;

end

