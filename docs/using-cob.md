# Using COB: An ontology developers guide

If you are part of a team that is responsible for creating or maintaining an OBO ontology, then read on for a description of how you can use COB with your ontology

## Add yourself to the OBO bridge

See [Bridging COB to OBO](obo-bridge) for instructions on how to make sure your ontology's root terms are mapped to COB

## Use a COB import

Here we assume you are familiar with standard OBO tools such as [ROBOT](http://robot.obolibrary.org/) and the [ROBOT extract](http://robot.obolibrary.org/extract) command, or you are using the [ODK]((https://github.com/INCATools/ontology-development-kit) to make releases.

If you are already using a BFO import modify your build process to instead use COB

If you are configuring an ontology for the first time using the ODK, then all you need to is declare `cob` as one of your input ontologies. You should do this in place of bfo-classes (don't worry, you will still get bfo-classes via COB).


## Using COB for end-users

If you are not an ontology developer or directly involved in the construction of one more ontologies, then there is not much opportunity to "use" COB.

We are hoping that we can manage a roll-out of COB to 
