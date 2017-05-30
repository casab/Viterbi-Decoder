function [ output_data ] = viterbi_decoder( input_data )
%DECODING using viterbi algorithm
A0 = [0 0 0]; A1 = [1 1 1]; B0 = [1 1 1]; B1 = [0 0 0];
C0 = [1 0 1]; C1 = [0 1 0]; D0 = [0 1 0]; D1 = [1 0 1];
E0 = [0 1 1]; E1 = [1 0 0]; F0 = [1 0 0]; F1 = [0 1 1];
G0 = [1 1 0]; G1 = [0 0 1]; H0 = [0 0 1]; H1 = [1 1 0];

d_range = 200;

n = length(input_data)/3;
state_error = zeros(1, 8);

state_selection = [1 2 3 4 5 6 7 8];
redundant_check = [1 2 3 4 5 6 7 8];
decided_state_output = zeros(1, n);
if n>d_range-1
    state_output = zeros(8, d_range);
else
    state_output = zeros(8, n);
end

state_output(1, 1:3) = [0 0 0]; state_output(2, 1:3) = [1 0 0];
state_output(3, 1:3) = [0 1 0]; state_output(4, 1:3) = [1 1 0];
state_output(5, 1:3) = [0 0 1]; state_output(6, 1:3) = [1 0 1];
state_output(7, 1:3) = [0 1 1]; state_output(8, 1:3) = [1 1 1];

state_transition = struct('t1', [A0; A1], ...
    't2', [A0; E0; A1; E1], ...
    't3', [A0; C0; E0; G0; A1; C1; E1; G1;], ...
    't4', struct('first', [A0; C0; E0; G0; A1; C1; E1; G1;], ...
        'second', [B0; D0; F0; H0; B1; D1; F1; H1;]), ...
    't5', struct('first', [A0; C0; E0; G0], ...
        'second', [B0; D0; F0; H0]), ...
    't6', struct('first', [A0; C0], ...
        'second', [B0; D0]), ...
    't7', struct('first', A0, 'second', B0));

state_guide = struct('t1', [1; 1], ...
    't2', [1; 5; 1; 5], ...
    't3', [1; 3; 5; 7; 1; 3; 5; 7;], ...
    't4', struct('first', [1; 3; 5; 7; 1; 3; 5; 7;], ...
        'second', [2; 4; 6; 8; 2; 4; 6; 8;]), ...
    't5', struct('first', [1; 3; 5; 7], ...
        'second', [2; 4; 6; 8]), ...
    't6', struct('first', [1; 3], ...
        'second', [2; 4]), ...
    't7', struct('first', 1, 'second', 2));

for i = 1:n
    temp = zeros(1, 8);
    err_temp = zeros(1, 8);
    new_index = i;
    if i>d_range-1
        new_index = d_range-1;
        decided_state_output(1,i-new_index) = state_output(1, 1);
        state_output(:, 1) = [];
        if i > n-3
            state_output(:, new_index) = 0;
        end
    end
    if i == 1
        err_temp(1) = length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t1(1,:))));
        err_temp(5) = length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t1(2,:))));
    elseif i == 2
        for k =1:4
            err_temp(2*k-1) = state_error(state_guide.t2(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t2(k,:))));
        end
    elseif i == 3
        for k = 1:8
            err_temp(k) = state_error(state_guide.t3(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t3(k,:))));
        end
    elseif i == n-2
        for k = 1:4
            error1 = state_error(state_guide.t5.first(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t5.first(k,:))));
            error2 = state_error(state_guide.t5.second(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t5.second(k,:))));
            if error1 > error2
                err_temp(k) = error2;
                temp(1,k) = state_selection(state_guide.t5.second(k));
            else
                err_temp(k) = error1;
                temp(1,k) = state_selection(state_guide.t5.first(k));
            end
        end
        state_selection = temp;
    elseif i == n-1
        for k = 1:2
            error1 = state_error(state_guide.t6.first(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t6.first(k,:))));
            error2 = state_error(state_guide.t6.second(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t6.second(k,:))));
            if error1 > error2
                err_temp(k) = error2;
                temp(1,k) = state_selection(state_guide.t6.second(k));
            else
                err_temp(k) = error1;
                temp(1,k) = state_selection(state_guide.t6.first(k));
            end
        end
        state_selection = temp;
    elseif i == n
        error1 = state_error(state_guide.t7.first(1)) + ...
            length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t7.first(1,:))));
        error2 = state_error(state_guide.t7.second(1)) + ...
            length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t7.second(1,:))));
        if error1 > error2
            err_temp(1) = error2;
            temp(1,1) = state_selection(state_guide.t7.second(1));
        else
            err_temp(1) = error1;
            temp(1,1) = state_selection(state_guide.t7.first(1));
        end
        state_selection = temp;
    else
        for k = 1:8
            error1 = state_error(state_guide.t4.first(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t4.first(k,:))));
            error2 = state_error(state_guide.t4.second(k)) + ...
                length(find(xor(input_data(1,(3*i-2):3*i), state_transition.t4.second(k,:))));
            if error1 > error2
                err_temp(k) = error2;
                temp(1,k) = state_selection(state_guide.t4.second(k));
                state_output(temp(1,k), new_index) = k>4;
            else
                err_temp(k) = error1;
                temp(1,k) = state_selection(state_guide.t4.first(k));
                state_output(temp(1,k), new_index) = k>4;
            end
        end
        redundant_rows = find(ismember(redundant_check, temp)==0);
        if isempty(redundant_rows) == 0
            uniq_temp = unique(temp);
            copy_row = uniq_temp(histc(temp,uniq_temp)>1);
            for j=1:length(redundant_rows)
                index = find(temp==copy_row(j));
                temp(index(1)) = redundant_rows(j);
                state_output(redundant_rows(j), 1:new_index) = [state_output(copy_row(j), 1:new_index-1) 0];
            end
        end
        state_selection = temp;
    end
    state_error = err_temp;
end
if n>d_range-1
    decided_state_output(1, n-(d_range-2):n) = state_output(state_selection(1,1), :);
else
    decided_state_output = state_output(state_selection(1,1), :);
end
output_data = fliplr(decided_state_output);
output_data = output_data(4:end);
end
