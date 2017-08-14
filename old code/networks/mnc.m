function [mi,nmi, nvi,ce] = mnc(x, y)
% Compute mutual information I(x,y), nomalized variation information (1-I(x,y)/H(x,y)),
% and conditional entropy H(x|y) of two discrete variables x and y.
% Adapted by Julia Chartove Mo Chen (mochen80@gmail.com).
    assert(numel(x) == numel(y));
    n = numel(x);
    x = reshape(x,1,n);
    y = reshape(y,1,n);
    
    l = min(min(x),min(y));
    x = x-l+1;
    y = y-l+1;
    k = max(max(x),max(y));

    idx = 1:n;
    %Mx = sparse(idx,x,1,n,k,n);
	Mx = x;
    %My = sparse(idx,y,1,n,k,n);
	My = y;
    Pxy = nonzeros(Mx'*My/n); %joint distribution of x and y
    Hxy = -dot(Pxy,log2(Pxy+eps));

    Px = mean(Mx,1);
    Py = mean(My,1);

    % entropy of Py and Px
    Hx = -dot(Px,log2(Px+eps));
    Hy = -dot(Py,log2(Py+eps));

    % mutual information
    mi = Hx + Hy - Hxy;
	nmi = sqrt((mi/Hx)*(mi/Hy)); %normalized
	nvi = 2-(Hx+Hy)/Hxy;
	ce = Hxy-Hy;
end