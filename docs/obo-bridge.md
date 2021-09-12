# Placing OBO ontologies under COB

COB is intended as a central place where different ontologies within
OBO can discuss and agree where the different root terms across OBO
belong in the COB hierarchy.

The source of truth for this is a file "COB to External"

## COB to External

The source for the file is in the [src/ontology/components](https://github.com/OBOFoundry/COB/blob/master/src/ontology/components) folder in GitHub:

 * [cob-to-external.tsv](https://github.com/OBOFoundry/COB/blob/master/src/ontology/components/cob-to-external.tsv)

The file is in [SSSOM tsv](https://github.com/mapping-commons/SSSOM) format.

## Example entries

The following entries use the owl:equivalentClass predicate to indicate that the COB IDs are equivalent to the the corresponding OBO concept.

|subject_id|subject_label|predicate_id|object_id|object_label|notes|
|---|---|---|---|---|---|
|COB:0000003|mass|owl:equivalentClass|PATO:0000125|mass|.|
|COB:0000004|charge|owl:equivalentClass|PATO:0002193|electric|.|
|COB:0000006|material entity|owl:equivalentClass|BFO:0000040|material entity|.|
|COB:0000008|proton|owl:equivalentClass|CHEBI:24636|proton|.|
|COB:0000017|cell|owl:equivalentClass|CL:0000000|cell|.|
|COB:0000026|processed material entity|owl:equivalentClass|OBI:0000047|processed material|.|
|COB:0000031|immaterial entity|owl:equivalentClass|BFO:0000041|immaterial entity|.|
|COB:0000033|realizable|owl:equivalentClass|BFO:0000017|realizable entity|.|

## Multiple OBO IDs for one COB ID

Ideally no COB ID is equivalent to more than one OBO ID, but in
practice different ontologies have minted IDs for what turned out to
be the same concept. COB serves as a useful clearinghouse for making
these lack of orthogonality transparent.

For example, the COB concept of "organism" (which includes viruses):

|subject_id|subject_label|predicate_id|object_id|object_label|notes|
|---|---|---|---|---|---|
|COB:0000022|organism|owl:equivalentClass|NCBITaxon:1|root|.|
|COB:0000022|organism|owl:equivalentClass|OBI:0100026|organism|.|
|COB:0000022|organism|owl:equivalentClass|CARO:0001010|organism or virus or viroid|.|

## subClass links

we can also declare the OBO class to be a subclass of the COB class. For example, the concept of a cell in the plant ontology is the species equivalent of the species-generic COB cell, so formally it is a subclass:

|subject_id|subject_label|predicate_id|object_id|object_label|notes|
|---|---|---|---|---|---|
|COB:0000017|cell|owl:equivalentClass|CL:0000000|cell|.|
|COB:0000017|cell|sssom:superClassOf|PO:0009002|plant cell|.|
|COB:0000018|native cell|owl:equivalentClass|CL:0000003|native cell|.|
|COB:0000018|native cell|sssom:superClassOf|XAO:0003012|xenopus cell|.|
|COB:0000018|native cell|sssom:superClassOf|ZFA:0009000|zebrafish cell|.|
|COB:0000018|native cell|sssom:superClassOf|PO:0025606|native plant cell|.|
|COB:0000019|cell in vitro|owl:equivalentClass|CL:0001034|cell in vitro|.|

Similarly, we can record the fact that we are committing to group SO entities as material entities

|subject_id|subject_label|predicate_id|object_id|object_label|notes|
|---|---|---|---|---|---|
|COB:0000006|material entity|sssom:superClassOf|SO:0000110|sequence_feature|.|
|COB:0000006|material entity|sssom:superClassOf|SO:0001060|sequence_variant|.|
|COB:0000006|material entity|sssom:superClassOf|SO:0001260|sequence_collection|.|

## Formal lack of commitment

We can record a formal lack of commitment in cob-to-external:

|subject_id|subject_label|predicate_id|object_id|object_label|notes|
|---|---|---|---|---|---|
|COB:0000011|atom|skos:closeMatch|CHEBI:33250|atom|.|
|COB:0000013|molecular entity|skos:closeMatch|CHEBI:23367|molecular entity|No exact match in CHEBI|
|COB:0000013|molecular entity|skos:closeMatch|CHEBI:25367|molecule|This is electrically neutral in CHEBI but in COB it is generic. We should make it union of molecule and polyatomic ion|

We cannot make these equivalent because we would end up with incoherencies in COB

## Proposing changes to cob-to-external

Anyone is welcome to make Pull Requests on the cob-to-external file. The pull request will be discussed openly and transparently, and anyone can make comments on the GitHub PR
