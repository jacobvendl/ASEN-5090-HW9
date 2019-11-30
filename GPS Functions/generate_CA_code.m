function [caCode] = generate_CA_code(PRN_num,integration_time)

%Jake Vendl
%ASEN 5090
%hw1prob1 fxn, this creates a 1023-digit CA code for GPS satellites with a
%given PRN #

%I transcribed the whole catalog here for future use
PRN_catalog = [2,6; 3,7; 4,8; 5,9; 1,9; 2,10;
    1,8; 2,9; 3,10; 2,3; 3,4; 5,6;
    6,7; 7,8; 8,9; 9,10; 1,4; 2,5;
    3,6; 4,7; 5,8; 6,9; 1,3; 4,6; 5,7;
    6,8; 7,9; 8,10; 1,6; 2,7; 3,8;
    4,9; 5,10; 4,10; 1,7; 2,8; 4,10];

PRN = PRN_catalog(PRN_num,:);

G1 = ones(1,10);
G2 = ones(1,10);

for i=1:integration_time/0.001*1023
    %G1 operations
    G1_out(i) = G1(end); %this goes before the shift
    newG1bit = int8(xor(G1(3),G1(10))); %from pg 63
    G1 = [newG1bit G1(1:9)];
    
    %G2 operations
    G2_out(i) = G2(end);
    
    %G2 bit is cascading xor logic
    newG2bit = int8(xor(xor(xor(xor(xor(G2(2),G2(3)),G2(6)),G2(8)),G2(9)),G2(10)));
    G2i(i) = int8(xor(G2(PRN(1)),G2(PRN(2))));
    G2 = [newG2bit G2(1:9)];
    
    %lets meet in the middle now
    caCode(i) = xor(G2i(i),G1_out(i));
end

caCode = (caCode==0)*(1) + (caCode==1)*(-1);
end %end the fxn

