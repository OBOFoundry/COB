# Editors documentation


- Do not edit cob.owl directly. Instead edit cob-edit.owl
- Do not edit cob-to-external.owl directly. Instead edit the tsv and run the Makefile.

## Run a COB release:

See standard ODK release docs [here](odk-workflows/ReleaseWorkflow.md).

## Run COB integration tests:

### All COB tests:
```
cd src/ontology
sh run.sh make cob_test
```

### Basic COB tests:
```
cd src/ontology
sh run.sh make main_test
```

## Run regular ontology QC tests:

```
cd src/ontology
sh run.sh make IMP=false test
```

