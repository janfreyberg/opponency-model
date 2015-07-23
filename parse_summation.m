function [average_mixdur, average_domdur, switches, reversions] = parse_summation(p)
%PARSE_SUMMATION This function takes p-structure and returns "behavioural"
%data
%   Detailed explanation goes here


dom_time_points = abs(p.rA{3}-p.rB{3})./(p.rA{3}+p.rB{3}) > p.cutoff;
mix_time_points = abs(p.rA{3}-p.rB{3})./(p.rA{3}+p.rB{3}) <= p.cutoff;
A_time_points = abs(p.rA{3}-p.rB{3})./(p.rA{3}+p.rB{3}) > p.cutoff & p.rA{3} > p.rB{3};
B_time_points = abs(p.rA{3}-p.rB{3})./(p.rA{3}+p.rB{3}) > p.cutoff & p.rA{3} < p.rB{3};

[switches, reversions] = count_transitions([A_time_points', mix_time_points', B_time_points'], p);

sim_buttons = [dom_time_points', mix_time_points'];

[unique_codes, unique_times] = create_unique_list(sim_buttons, p.tlist'/1000);

[dom_index, mix_index] = find_percept_index(unique_codes);

[~, all_durs] = parse_percepts(unique_times, [], p.tlist(end)/2000);

dom_durs = all_durs(dom_index);
dom_durs = remove_tooshort(dom_durs, p.mintime);
mix_durs = all_durs(mix_index);
mix_durs = remove_tooshort(mix_durs, p.mintime);

average_mixdur = mean(mix_durs);
average_domdur = mean(dom_durs);
end

function [unique_code, unique_secs] = create_unique_list(button_codes, button_secs)
    %CREATE_UNIQUE_LIST [button_codes, button_secs] = create_unique_list(button_codes, button_secs);
    %   This removes duplicates
    duplicate_index = [false; all(button_codes(2:end, 1:2)==button_codes(1:end-1, 1:2), 2)];
    unique_code = button_codes(~duplicate_index, 1:2);
    unique_secs = button_secs(~duplicate_index, 1);
end

function [dom_index, mix_index] = find_percept_index(button_codes)
    %FIND_PERCEPT_INDEX [green_index, red_index, mix_index] = find_percept_index(percept_codes);
    %   just outputs a logical index for each percept
        dom_index = ismember(button_codes, [1 0], 'rows');
        mix_index = ismember(button_codes, [0 1], 'rows');
end

function [button_codes, percept_duration] = parse_percepts( button_times, button_codes, max_time )
    % [button_codes, percept_duration] = parse_percepts( button_times, button_codes )
    %   This script takes time of button onset, and code of which buttons were
    %   pressed, and returns the length of a percept, and what that percept
    %   was. These are not cleaned, so you need to do cleaning later.
    percept_duration = zeros(numel(button_times), 1); % preallocate for speed
    for i = 1:numel(button_times);
        if i < numel(button_times)
            percept_duration(i) = button_times(i+1) - button_times(i);
        elseif i == numel(button_times)
            percept_duration(i) = max_time - button_times(i);
        end
    end
end

function [percept_durs] = remove_tooshort(percept_durs, min_percept_dur)
    too_short_index = percept_durs < min_percept_dur;
    percept_durs(too_short_index, :) = [];
end

function [switches, reversions] = count_transitions(button_codes, p)
    duplicate_index = [true; all(button_codes(2:end, 1:3)==button_codes(1:end-1, 1:3), 2)];
    button_codes = button_codes(~duplicate_index, 1:3);
    button_times = p.tlist(~duplicate_index)/1000;
    [~, all_durs] = parse_percepts( button_times, button_codes, p.T );
    button_codes = button_codes(all_durs>p.mintime, 1:3);
    
    switches = 0;
    reversions = 0;
    mixed_removed = button_codes(~ismember(button_codes, [0 1 0], 'rows'), 1:3);
    for i = 2:size(mixed_removed, 1)
        if isequal( mixed_removed(i-1, 1:3), mixed_removed(i, 1:3))
            reversions = reversions + 1;
        else
            switches = switches + 1;
        end
    end
end