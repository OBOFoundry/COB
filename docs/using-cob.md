# Using COB: An ontology developers guide

Intended audience: technical leads for individual OBO ontology projects

This is a draft guide. There are many technical issues that need to be
worked out to transition to COB. We strongly recommend you do work
here on a branch, and if you have problems, make an issue in the COB
tracker and link to your PR

## 1. Add your roots to the OBO bridge

See [Bridging COB to OBO](obo-bridge.md) for instructions on how to make sure your ontology's root terms are mapped to COB.

If you are not bridged to COB, or don't understand the bridge file, then you are not ready to use it in the production releases of your ontology.

## 2. Use a COB import

Here we assume you are familiar with standard OBO tools such as [ROBOT](http://robot.obolibrary.org/) and the [ROBOT extract](http://robot.obolibrary.org/extract) command, or you are using the [ODK](https://github.com/INCATools/ontology-development-kit) to make releases.

We assume here that all of your imports are to modules extracted from Base files. If you are not doing this, or don't know what a Base file is, then we recommend waiting until the documentation around these is more mature before you attempt to switch to COB.

If you are already using a BFO import, then you should modify your build process to instead use COB.

If you are configuring an ontology for the first time using the ODK, then all you need to is declare `cob` as one of your input ontologies. You should do this in place of bfo-classes (don't worry, you will still get most back via COB).

## Troubleshooting

### Dangling BFO class IDs

The most likely problem will be dangling BFO class IDs. These may come from two sources:

1. subClassOf axioms in a base module from root nodes
2. domain, range, or similar constraining axioms in RO

The first case should be rare, because most ontologies are rooted in a COB class with a BFO equivalent. However, in some cases, ontologies will be rooted in either:

- a class in BFO that is beneath the shoreline in COB, e.g. fiat object part is used as a root in ENVO (for now; see https://github.com/EnvironmentOntology/envo/pull/1252)
- a class in BFO that is above the shoreline in COB, e.g. a domain ontology class that directly subclasses a high level BFO class like continuant. These should be rare to non-existent

The second category is harder. See https://github.com/OBOFoundry/COB/issues/213

## Using COB for end-users

If you are not an ontology developer or directly involved in the construction of one more ontologies, then there is not much opportunity to "use" COB.


