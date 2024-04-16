% This line consults the knowledge bases from this file,
% instead of needing to consult the files individually.
% This line MUST be included in the final submission.
:- ['transport_kb', 'slots_kb'].

%-------------SLOTS---------------------------

rem_dupli([],[]).
rem_dupli([H|T],L):-
    member(H, T),
    rem_dupli(T, L).
rem_dupli([H|T],L):-
    \+member(H, T),
    rem_dupli(T, L1),
    L = [H|L1].
    

group_days(GROUP, Day_Timings):-
    findall(day_timing(Wk,Dy), scheduled_slot(Wk,Dy,_,_,GROUP), D1),
    rem_dupli(D1, Day_Timings),!.

day_slots(Group, Week, Day, Slots):-
    findall(S,scheduled_slot(Week, Day, S, _, Group), Slots).

earliest_slot(Group, Week, Day, Slot):-
    day_slots(Group,Week,Day, [Slot | _]).
%-------------TRANSPORTATION------------------
proper_connection_default(A, B, D, L):- 
    connection(A,B, D,L).

proper_connection_default(A,B, D,L):-
    \+connection(A,B,D,L),
    connection(A,C,D1,L),
    proper_connection_default(C,B,D2,L),
    D is D1 + D2.
    
proper_connection(A, B, D, L):-
    connection(_,B,_,L),
    proper_connection_default(A, B, D, L).

proper_connection(A, B, D, L):-
    \+unidirectional(L),
    connection(_,B,_,L),
    proper_connection_default(B, A, D, L).