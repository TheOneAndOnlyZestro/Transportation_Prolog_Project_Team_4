% This line consults the knowledge bases from this file,
% instead of needing to consult the files individually.
% This line MUST be included in the final submission.
:- ['transport_kb', 'slots_kb'].

proper_connection_default(A, B, D, L):- 
    connection(A,B, D,L).

proper_connection_default(A,B, D,L):-
    \+connection(A,B,D,L),
    connection(A,C,D1,L),
    proper_connection_default(C,B,D2,L),
    D is D1 + D2.
    
proper_connection(A, B, D, L):-
    proper_connection_default(A, B, D, L).

proper_connection(A, B, D, L):-
    \+unidirectional(L),
    proper_connection_default(B, A, D, L).