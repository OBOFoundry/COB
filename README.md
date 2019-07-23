# OBO CORE

This project is an experiment that brings together key terms from a wide range of [Open Biological and Biomedical Ontology (OBO)](http://obofoundry.org) projects into a single, small ontology. The goal is to improve interoperabilty and reuse across the OBO community through better coordination of key terms. Our plan is to keep this ontology small, but ensure that some OBO Core term or terms can be used as the root of any given OBO library ontology.

The original list of terms considered for CORE is availabe here: [OBO Core Term Discussion](https://docs.google.com/spreadsheets/d/1DHU6EktJKuOShV_vK-gKLK6b5RwXG021kAfpqWkcKIU/edit#gid=0) These terms can also be found in `core-external.owl` The current version of CORE (`core-edit.owl`) contains newly-created terms in a CORE namespace that may or may not correspond with existing OBO Foundry terms. To see how CORE terms compare to existing terms, see the `core-to-external.owl` file.

To suggest adding a term to OBO Core, please submit an issue to our tracker.

## Files

- `core-edit.owl`: the *current version* of CORE containing new terms in the CORE namespace.
- `core-external.owl`: the original terms considered for CORE from other OBO Foundry ontologies.
- `core-to-external.owl`: CORE terms from `core-edit.owl` and OBO Foundry counterparts in `core-external.owl` with proposed equivalencies.
- `modules/`: the existing OBO Foundry terms from `core-external.owl` split into different categories (generic, biological, human, physical, and science modules).
