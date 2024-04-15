% This line consults the knowledge bases from this file,
% instead of needing to consult the files individually.
% This line MUST be included in the final submission.
:- ['transport_kb', 'slots_kb'].
proper_connection(Station_A, Station_B, Duration, Line):-
    connection(Station_A, Station_B, Duration, Line)
    ;
    (\+unidirectional(Line),
    connection(Station_B, Station_A, Duration, Line)).
proper_connection(Station_A, Station_B, Duration, Line):-
    ((connection(Station_A, Station_C, Duration1, Line),
    proper_connection(Station_C, Station_B, Duration2, Line))
    ;
    (\+unidirectional(Line),
    connection(Station_B, Station_D, Duration1, Line),
    proper_connection(Station_D, Station_A, Duration2, Line))),
    Duration is Duration1+Duration2.