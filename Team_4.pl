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
    connection(A,_,_,L),
    connection(_,B,_,L),
    proper_connection_default(A, B, D, L).

proper_connection(A, B, D, L):-
    connection(B,_,_,L),
    connection(_,A,_,L),
    \+unidirectional(L),
    proper_connection_default(B, A, D, L).

append_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line, Routes_So_Far, Routes):-
    proper_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line),
    \+last(Routes_So_Far, route(Conn_Line,_,Conn_Source,_)),
    append(Routes_So_Far, [route(Conn_Line,Conn_Source,Conn_Destination,Conn_Duration)] ,Routes).

append_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line, Routes_So_Far, Routes):-
    proper_connection(Conn_Source, Conn_Destination, Conn_Duration, Conn_Line),
    last(Routes_So_Far, route(Conn_Line,Source,Conn_Source,Duration)),
    \+last(Routes_So_Far, route(Conn_Line, Conn_Destination, Conn_Source,_)),
    Z=route(Conn_Line,Source,Conn_Destination,D),
    D is Duration+Conn_Duration,
    proper_connection(Source, Conn_Destination, D, Conn_Line),
    select(route(Conn_Line,Source,Conn_Source,Duration),Routes_So_Far,Z, Routes).



connected_default(Source, Destination, Week, Day, Max_Duration, Max_Routes, Duration, Routes):-
    Source \= Destination,
    proper_connection(Source, Destination, Duration, L),
    line(L, TYPE),
    \+strike(TYPE, Week, Day),
    Duration < Max_Duration,
    Max_Routes > 0,
    append_connection(Source, Destination, Duration, L, [], Routes).

connected_default(Source, Destination, Week, Day, Max_Duration, Max_Routes, Duration, Routes):-
    Source \= Destination,
    proper_connection(Intermediate, Destination, D1, L),
    Intermediate \= Source,
    Intermediate \= Destination,
    line(L, TYPE),
    \+strike(TYPE, Week, Day),

    New_Max_Duration is Max_Duration - D1,
    New_Max_Routes is Max_Routes - 1,
    New_Max_Duration >0,
    New_Max_Routes >0,
    
    connected_default(Source, Intermediate, Week, Day, New_Max_Duration, New_Max_Routes, DR, Prev_Routes),

    append_connection(Intermediate, Destination, D1, L, Prev_Routes, Routes),
    Duration is D1 +DR.

connected(Source, Destination, Week, Day, Max_Duration, Max_Routes, Duration, Routes):-
    connected_default(Source, Destination, Week, Day, Max_Duration, Max_Routes, Duration, Routes),
    \+ (member(route(s41,_,_,_), Routes), member(route(s42,_,_,_), Routes)).
    

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