function res = sign_fortran(x,y)

if y >= 0
    res =  abs(x);
else
    res =  -1*abs(x);
end