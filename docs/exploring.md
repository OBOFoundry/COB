# Exploring COB

## Browse

COB is available on the following browsers:

- [Ontobee](http://www.ontobee.org/ontology/COB)
- [OLS](https://www.ebi.ac.uk/ols/ontologies/cob)
- [BioPortal](http://bioportal.bioontology.org/ontologies/COB)

You can also enter any COB class PURL into a browser to resolve it; e.g. [http://purl.obolibrary.org/obo/COB_0000011](http://purl.obolibrary.org/obo/COB_0000011) (atom)

## Files

- End products
    - [cob.owl](cob.owl): the *current version* of COB containing new terms in the COB namespace
    - [cob-to-external.owl](cob-to-external.owl) COB terms and OBO Foundry counterparts with proposed equivalencies
    - [cob-examples.owl](cob-examples.owl): additional child terms as examples. This file is edited by hand.
- Editors/Source files
   - [cob-edit.owl](cob-edit.owl): the editors version
   - [cob-to-external.tsv](cob-to-external.tsv): TSV source of cob-to-external
   - [Makefile](Makefile): workflow for build COB


## COB demo

As a demonstration of how COB could be used to unify OBO ontologies in the future we produce an ontology:

 - [products/demo-cob.owl](products/demo-cob.owl)

This has selected subsets of certain ontologies merged in with
cob-to-external. It is incomplete and messy. Please see the Makefile
for how to add more to it.
