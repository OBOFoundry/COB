% Atom: A material entity consisting of exactly one atomic nucleus and the electron(s) orbiting it.

atom(A) -> 
        % the only parts are nuclei or electrons, or space
        not ((has_part(A,P),
             not not part_of_some(P,atomic_nucleus),
             not not part_of_some(P,electron),
             not immaterial_entity(P))). % is this required?

atom(A) ->
        not ((has_part(A,E),
             electron(E),
              not orbits(E,A))).

atom(A) ->
        has_part(A,N),
        part_of_some(N,atomic_nucleus),
        not ((has_part(A,N2),
              not(N2=N),
              part_of_some(N2,atomic_nucleus))).

part_of_some(P,C) ->
      part_of(P,W),
      type(W,C).

% Molecular Entity: A material entity that consists of two or more atoms that are all connected via covalent bonds such that any atom can be transitively connected with any other atom.

molecular_entity(E) ->
  material_entity(E),
  forall( (has_part(E,A1),
           atom(A1),
           has_part(E,A2),
           atom(A2),
           ) ->
          transitively_covalently_connected_to(A1,A2)).

transitively_covalently_connected_to(X,Y) :- covalently_connected_to(X,Y).
transitively_covalently_connected_to(X,Y) :- covalently_connected_to(X,Z),transitively_covalently_connected_to(Z,Y).

% If(A)-> Then( ...) ==> incohrent(A) :- not ...
        
