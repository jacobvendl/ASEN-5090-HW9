function [PRIF, iono] = ionocorr(C1, f1, P2, f2)

sz = size(C1,1);

PRIF = zeros(sz,1);
iono = zeros(sz,1);

for n = 1:sz
    iono(n) = (f2^2/(f1^2-f2^2))*(P2(n)-C1(n));
    PRIF(n) = (f1^2/(f1^2-f2^2))*C1(n) - (f2^2/(f1^2-f2^2))*P2(n);
end

end