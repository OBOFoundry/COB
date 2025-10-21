# Core Ontology for Biology and Biomedicine (COB)
[![License: CC0-1.0](https://img.shields.io/badge/License-CC0%201.0-green.svg)](http://creativecommons.org/publicdomain/zero/1.0/) ![Build Status](https://github.com/OBOFoundry/COB/workflows/CI/badge.svg)


This project is an attempt to bring together key terms from a wide range of [Open Biological and Biomedical Ontology (OBO)](http://obofoundry.org) projects into a single, small ontology. The goal is to improve interoperabilty and reuse across the OBO community through better coordination of key terms. Our plan is to keep this ontology small, but ensure that one or more COB terms can be used as the root of any given OBO library ontology.
## Using COB
COB is split into three "modules" that contain distinct sets of terms:
* [BASE](src/ontology/cob-base.owl) has only terms in the COB ID space.
* [FULL](src/ontology/cob.owl) has all the terms in BASE, plus other OBO terms used in the axioms of those terms.
* [ROOT](src/ontology/cob-root.owl) has all the terms in FULL, plus "root" terms from various OBO ontologies, which anchor those ontologies in COB and provide points from which other ontologies can expand.

Most ontologies that import COB will want to use [`cob-root.owl`](src/ontology/cob-root.owl).
## How to Edit COB
COB makes use of the [ODK workflows](docs/odk-workflows/ReleaseWorkflow.md), but with a few additional steps that are unique to COB. Unlike most OBO ontologies, all of the terms in COB are housed in a single ROBOT template: [`cob-edit.tsv`](src/ontology/cob-edit.tsv). All changes should be made in this template. 

After making changes to [`cob-edit.tsv`](src/ontology/cob-edit.tsv), run the following command in [`src/ontology/`](src/ontology/) to update the files:
```
sh run.sh make prepare_release -B
```
This command:
* Runs the script [`split-cob-edit.py`](src/scripts/split-cob-edit.py), which separates [`cob-edit.tsv`](src/ontology/cob-edit.tsv) into templates for each module.
* Builds the base, full, and root modules using ROBOT.
* Annotates the resulting files with an updated release date.
* Reports on any violations found by `robot report`.
* Sets literals to use `@en` (preferred) or `xsd:string` (if used by the source ontology) (see [PR #295](https://github.com/OBOFoundry/COB/pull/295) for more info).

Once the release files have been updated, run the following command to check imported terms against their source ontology:
```
make crosscheck
```
The `crosscheck` process compares imported terms to OntoFox import files (see [PR #295](https://github.com/OBOFoundry/COB/pull/295) for more info). If the results from `crosscheck` look good, commit the changes and open a PR.
