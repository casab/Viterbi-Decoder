function [ output_signal ] = conv_encoder( input_signal )
%conv_encoder function implements a 1/3 rate convolutional encoder
ff1 = 0; ff2 = 0; ff3 = 0;
input_signal = [0 0 0 input_signal];
size = length(input_signal);
    for i=1:size;
        input = input_signal(size+1-i);
        output1 = mod2(mod2(input,ff2),ff3);
        output2 = mod2(mod2(input,ff1),ff3);
        output3 = mod2(mod2(mod2(input,ff1),ff2),ff3);
        if i==1;
            output_signal = [output1 output2 output3];
        else
            output_signal = [output_signal output1 output2 output3];
        end
        ff3 = ff2;
        ff2 = ff1;
        ff1 = input;
    end
end

function y = mod2(a,b)
    y = mod(sum(a+b),2);
end
