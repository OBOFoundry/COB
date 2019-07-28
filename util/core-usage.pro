:- use_module(library(sparqlprog/ontologies/ontobee)).
:- use_module(library(sparqlprog/endpoints)).

:- rdf_register_prefix(skos, 'http://www.w3.org/2004/02/skos/core#').

core_term_usage(C,X,G,Num) :-
        rdf(C,skos:exactMatch,X),
        ??(ontobee,
           aggregate_group(count(Y),[G],rdf(Y,_,X,G),Num),
           x(G,Num)).




        
