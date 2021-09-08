# Core Ontology for Biology and Biomedicine (COB)
[![License: CC0-1.0](https://img.shields.io/badge/License-CC0%201.0-green.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

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

## Issue Tracker

If you are responsible for an OBO ontology you can see any tickets that pertain to your ontology by looking for the label with your ontology ID.

For example:

 * **GO**: https://github.com/OBOFoundry/COB/labels/GO
 * **OBI**: https://github.com/OBOFoundry/COB/labels/OBI

## Editors Guide

Do not edit cob.owl directly. Instead edit cob-edit.owl

Do not edit cob-to-external.owl directly. Instead edit the tsv and run the Makefile.

 - Run `sh run.sh make prepare_release` to build the ontology from source/edit files
 - Run `sh run.sh make cob_test` to run both basic tests and integration tests.
 - Run `sh run.sh make main_test` to run  basic tests 

## Integration Tests

Currently we have two kinds:

- **Coherency**: testing if an ontology is coherent when combined with COB + ext
- **Coverage**: testing if an ontology has classes that are not subclasses (direct or indirect) of COB classes

For coherency test results, see the files status-*.txt in [build](build)

For coverage test results, see the files root-orphans-*.txt in [build](build)

See the [Makefile](Makefile) for a list of ontologies that are known to be compliant and those known to be non-compliant

## External Ontology developers guide

It is too early for you to start using COB as an upper level in your ontology

 1. Create a [*base* file](https://github.com/INCATools/ontology-development-kit/blob/master/docs/ReleaseArtefacts.md#release-artefact-1-base-required)
 2. Add bridging axioms to your root to [cob-to-external.tsv](cob-to-external.tsv)
 3. Add your ontology to the Makefile under integration tests


