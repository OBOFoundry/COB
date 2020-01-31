# Core Open Biological Ontology (COB)

This project is an experiment that brings together key terms from a wide range of [Open Biological and Biomedical Ontology (OBO)](http://obofoundry.org) projects into a single, small ontology. The goal is to improve interoperabilty and reuse across the OBO community through better coordination of key terms. Our plan is to keep this ontology small, but ensure that one or more COB terms can be used as the root of any given OBO library ontology.

The current version of COB (`cob-edit.owl`) contains newly-created terms in the COB namespace that may or may not correspond with existing OBO Foundry terms. To see how COB terms compare to existing terms, see the `cob-to-external.owl` file.

To suggest adding a term to COB, please submit an issue to our tracker.

## Files

- `cob-edit.owl`: the *current version* of COB containing new terms in the COB namespace
- `cob-to-external.owl`: COB terms and OBO Foundry counterparts with proposed equivalencies
- `cob-example.owl`: examples of usages for COB terms