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

append_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line, Routes_So_Far, Routes):-
    proper_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line),
    last(Routes_So_Far, route(Conn_Line,Source,Conn_Source,Duration)),
    Z=route(Conn_Line,Source,Conn_Destination,D),
    D is Duration+Conn_Duration,
    select(route(Conn_Line,Source,Conn_Source,Duration),Routes_So_Far,Z, Routes).
append_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line, Routes_So_Far, Routes):-
    proper_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line),
    \+last(Routes_So_Far, route(Conn_Line,_,Conn_Source,_)),
    append(Routes_So_Far, [route(Conn_Line,Conn_Source,Conn_Destination,Conn_Duration)] ,Routes).

%-----------------------------TIME-CONVERSIONS----------------------------------
mins_to_twentyfour_hr(Minutes, TwentyFour_Hours, TwentyFour_Mins):-
    TwentyFour_Hours is Minutes // 60,
    TwentyFour_Mins is Minutes mod 60.

twentyfour_hr_to_mins(TwentyFour_Hours, TwentyFour_Mins, Minutes):-
    Minutes is (TwentyFour_Hours*60)+TwentyFour_Mins.

slot_to_mins(Slot_Num, Minutes):-
    slot(Slot_Num,H,M),
    twentyfour_hr_to_mins(H,M,Mins),
    Minutes = Mins.