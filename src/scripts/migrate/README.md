# COB Migration

This folder contains some scripts to help migrate you OBO ontology to COB.
There is a table of terms to migrate,
and a script to convert that table into instructions for
[ROBOT](https://robot.obolibrary.org).
Using ROBOT you can

1. get a list of the relevant terms in your ontology
2. remove them from your ontology
3. replace them with either strict or suggested replacement terms

These tools are meant to help migrate to COB,
but manual review is required to ensure that no mistakes are made.

## Basics

The relevant terms are listed in `migrate.tsv`.
There are columns for

- the target term and its label
- a comment about what should be done
- the more general replacement term and its label
- the more specific suggested term and its label

Replacing a term with the more general term should always be safe.
Replacing a term with the more specific term
is the better choice in most but not all cases.
If the replacement is 'owl:Thing',
then it is better to completely remove that term
or that part of an axiom.

When the `migrate.tsv` table changes,
run the `generate.py` script to update
the SPARQL query and ROBOT instruction files.

## 1. Report

The first step is to report on which terms, if any,
need to be changed.
The `migrate.tsv` file lists them,
and the `report.rq` SPARQL query will search for them in your ontology.

It's best to run this query on your ontology's base file,
so that it only considers the terms and axioms
that your project is responsible for.
If you run the query on your ontology's full release file,
you may find problems with upstream ontologies.
In this case, the best approach is to update your import strategy
so that it is compatible with your new use of COB.

```sh
robot query --input your-base.owl --query report.rq report.tsv
```

## 2. Remove

ROBOT can help migrate to COB by removing the terms listed in `migrate.tsv`
from your OWL files.
The best approach is to remove the terms from your project's "edit",
e.g. `obi-edit.owl`,
and the ROBOT command below will help with that.
However, the ROBOT command is not aware of any templates or import definitions.
If you use the terms in `migrate.tsv` anywhere in your templates or imports,
then you will have to make those changes manually,
guided by the report.

Another option is to run the ROBOT commands on your project's release files,
including the full release and base file.
This is useful for testing or as part of a migration strategy,
where you inform your users of the upcoming changes.
However the best long-term solution is to change your source files.

We use ROBOT to remove the terms in `migrate.tsv` from an OWL file in two steps.
First we remove all the annotations on those terms,
then we remove subclass and equivalent class axioms.
The only remaining references to those terms
will be inside your other axioms.
In the next step we replace the remaining term references with the new terms.

```sh
robot remove \
  --input target.owl \
  --term-file remove-annotations.txt \
  --axioms "annotation" \
  --preserve-structure false \
  remove \
  --term-file remove-axioms.txt \
  --axioms "subclass equivalent" \
  --signature true \
  --trim false \
  --preserve-structure false \
  --output removed.owl \
```

## 3. Replace

The final step is to replace the migrated terms.
You have two choices:

1. `strict-replacement.txt` migrates to more general terms, which should always be safe
2. `suggested-replacement.txt` migrates to more specific terms, which are better replacements in most but not all cases

The best option is to use the migration report to guide you,
and manually review your ontology
to see if all the relevant suggested replacements will work.
If any suggestions do not work, then use the strict replacement instead.
Write a new `replacement.txt` file with your preferences,
then run the ROBOT command:

```sh
robot rename \
  --input removed.owl \
  --mappings strict-replacement.tsv \
  --allow-missing-entities true \
  --allow-duplicates true \
  --output renamed.owl \
```

## Next Steps

If you run the report query again after the remove and replace steps,
the result report should be empty.
Make sure to manually review changes.
The [`robot diff`](https://robot.obolibrary.org/diff)
will help to compare your OWL files before-and-after.

If you have questions or concerns,
feel free to open an issue here in the COB repository.

