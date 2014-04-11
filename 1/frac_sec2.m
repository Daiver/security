
function seq = frac_seq2(cnst, R0)
    i = 1;
    Rc = frac(cnst * R0 + pi);
    seq(1) = Rc;
    mn = 1;
    a = containers.Map;
    
    mi = -1;
    mR = 0;
    while a.isKey(num2str(Rc)) == 0 %check(seq, Rc) % (Rc !=  R0) 
        i = i + 1;
        a(num2str(Rc)) = 1;
        Rc = frac(cnst * Rc + pi);
        seq(i) = Rc;
        %if abs(R0 - Rc) < mn
            %mn = abs(R0 - Rc);
            %mi = 0;
            %mR = Rc;
            i
            Rc
            %mn
    %end
    end %while
end

%function v = check(seq, rc)
%    v = true;
%    for i = 1:size(seq') - 1
%        if seq(i) == rc
%            v = false;
%        end
%    end
%end
