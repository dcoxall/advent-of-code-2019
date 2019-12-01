% Day 1: The Tyranny of the Rocket Equation
% https://adventofcode.com/2019/day/1

% Convert a line to an integer
parse_line(L) -> {V, _} = string:to_integer(L), V.

% Calculate the non recursive requirement
local_requirement(M) -> (M div 3) - 2.

% Calculate the fuel requirement whilst recursively
% summing the fuel required for the fuel itself
fuel_requirement(M, Additional) when Additional =< 0 -> M;
fuel_requirement(M, Additional) when Additional > 0 ->
  fuel_requirement(M + Additional, local_requirement(Additional)).

fuel_requirement(M) ->
  Fr = local_requirement(M),
  fuel_requirement(Fr, local_requirement(Fr)).

% Sum the fuel requirements for each line
sum_fuel(L, Acc) -> Acc + fuel_requirement(parse_line(L)).

% Iterate over each of the lines in a file
each_line(F, Acc) ->
  case io:get_line(F, "") of
    eof -> file:close(F), Acc;
    L   -> each_line(F, sum_fuel(L, Acc))
  end.

% Read the file and process each line
main(_) ->
  {ok, F} = file:open("./inputs/01.txt", read),
  io:format("~p~n", [each_line(F, 0)]).
