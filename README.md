# Core Ontology for Biology and Biomedicine (COB)

This project is an attempt to bring together key terms from a wide range of [Open Biological and Biomedical Ontology (OBO)](http://obofoundry.org) projects into a single, small ontology. The goal is to improve interoperabilty and reuse across the OBO community through better coordination of key terms. Our plan is to keep this ontology small, but ensure that one or more COB terms can be used as the root of any given OBO library ontology.

The current version of COB (`cob-edit.owl`) contains newly-created terms in the COB namespace that may or may not correspond with existing OBO Foundry terms. To see how COB terms compare to existing terms, see the `cob-to-external.owl` file.

To suggest adding a term to COB, please submit an issue to our tracker.

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
   - [cob-examples.owl](cob-examples.owl): additional child terms as examples
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

## Editors Guide

Do not edit cob.owl directly. Instead edit cob-edit.owl

Do not edit cob-to-external.owl directly. Instead edit the tsv and run the Makefile.

 - Run `make` to build the ontology from source/edit files
 - Run `make test` to run both basic tests and integration tests.
 - Run `make main_test` to run  basic tests 

## Integration Tests

Currently we have two kinds:

- **Coherency**: testing if an ontology is coherent when combined with COB + ext
- **Coverage**: testing if an ontology has classes that are not subclasses (direct or indirect) of COB classes

See the [Makefile](Makefile) for a list of ontologies that are known to be compliant and those known to be non-compliant

## Ontology developers guide

It is too early for you to start using COB as an upper level in your ontology

But you can still participate. You can add the top level classes to
your ontology in [cob-to-external.tsv](cob-to-external.tsv) - just
make a pull request for us.

You can also clone this repo and test the integration of your ontology
by editing the Makefile and including your ontology in the COMPLIANT
list, adding your roots to cob-to-external.tsv, then running the
integration tests. If it succeeds you can make a PR for us!
