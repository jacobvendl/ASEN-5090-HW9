function [CA] = generate_CA_code(PRN_selector)

G1 = ones(1,10);
G2 = ones(1,10);

for n = 1:1023
    % Extract G1 and G2 output
    G1_out(n) = G1(end);
    G2_out(n) = G2(end);
    
    % Extract CA code output
    phase = bitxor(G2(PRN_selector(1)),G2(PRN_selector(2)));
    CA_out(n) = bitxor(phase,G1(10));
    
    % Shift generators
    G1_new = bitxor(G1(3),G1(10));
    G1 = [G1_new G1(1:9)];
    G2_new = bitxor(bitxor(bitxor(bitxor(bitxor(G2(2),G2(3)),G2(6)),G2(8)),G2(9)),G2(10));
    G2 = [G2_new G2(1:9)];
end

CA = (CA_out == 0)*(1) + (CA_out == 1)*(-1);

end

