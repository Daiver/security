
%frac(10.002)

N = 100000;
%seq = zeros() %frac_seq(11, 0.5);
R0 = 0.002;
R0 = 0.5;
cnst = 11;
Rc = R0;
for i = 1:N seq(i) = frac6(cnst, Rc) ; Rc = seq(i); end

j = N - 100;
seq(j)
I = -1;
for i = 1 : j
    if abs(seq(i) - seq(j)) < 0.0001
    %if seq(i) == seq(j)
        if I == -1
            I = i;
        else
            J = i;
            break
        end
    end
end

I
J
l = J - I
L = I + l

Lseq = seq(1:L);
lseq = seq(1:l);
Lseq;
Mean = mean(Lseq)
Var = var(Lseq)
%V = 0;
%for i = 1:L
%    V += (Lseq(i) - Mean)^2;
%end
%V/L
hist(Lseq);
grid on;
% pause()
K = 10
freq = zeros(1, K);
rounded_r = fix(Lseq * K);
for i=1:L
    ind = rounded_r(i) + 1;
    freq(ind) = freq(ind) + 1;
end
freq
% Xi
v = L / K;
Xi = 0;
for i=1:K
    %printf("Step: %d, Xi: %f\n", i, ((freq(i) - v)^2) / v);
    Xi = Xi + (freq(i) - v)^2;
end
Xi = Xi/v
pause()

















% Digit frequency
%digitfreq = zeros(1, 10);
%for i=1:L
%    tmp = sscanf( sprintf( '%f', Lseq(i)), '%1d' )';
%    for j=3:8
%        digitfreq(tmp(j)+1) = digitfreq(tmp(j)+1) + 1;
%    end
%end
%figure;
%digitfreq
%bar(0:9, digitfreq/6);
%grid on;
%legend("Digit frequency");

%bar(0:K-1, freq);
%grid on;
%pause()
%c = 1;
%for i=1:2:L-1
%    a(c) = Lseq(i);
%    b(c) = Lseq(i+1); 
%    c = c + 1;
%end

%figure;
%plot(a, b, 'g.');
%legend ("Scatter map of random numbers");

