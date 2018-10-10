function Sout = image2D_logistic(Input,a,b,c)

% Input is a 2D image

input_max = max(max(Input));

I = Input - (input_max/2);
I = 20*I/input_max;


Sout = c./(exp(-b*(I-a))+c);
