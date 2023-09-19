function jbmat = GetJordan0Block(n)
%where jbmat is in M_{n \times n}(F)
jbmat = [zeros(n-1,1),eye(n-1);zeros(1,n)];