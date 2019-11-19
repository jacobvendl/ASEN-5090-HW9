function [tropo] = tropomodel(el, zen_trop)

sz = size(el,1);

Tz = zen_trop; % m

tropo = zeros(sz,1);
for n = 1:sz
    tropo(n) = Tz/sind(el(n));
end

end