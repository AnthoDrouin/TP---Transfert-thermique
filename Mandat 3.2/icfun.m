function T0 = icfun(x)
global Tinit dx

i = int32(x/dx) + 1;
T0 = Tinit(i);

end