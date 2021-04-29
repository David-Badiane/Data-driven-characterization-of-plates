function [f] = LSerror(x,freq,spec)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
freq = 2*pi*freq;
f = 0;

for ii = 1:length(freq)
f = f + ...
  real(spec(ii) -(x(3)+1i*x(4))/...
            (-(freq(ii)^2) + 1i*x(1)*2*x(2) * freq(ii) + x(2)^2 )...
            -(x(5) + 1i*x(6)) - (x(7)+ 1i*x(8)) / (freq(ii)^2) )^2 ...
     ...       
     +  imag(spec(ii) - (x(3)+1i*x(4))/...
     (-(freq(ii)^2) + 1i*x(1)*2*x(2) * freq(ii) + x(2)^2 )...
     -(x(5) + 1i*x(6)) - ((x(7)+1i*x(8)) / (freq(ii)^2)))^2;
end
 

end
