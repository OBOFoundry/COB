# The Core Ontology for Biology and Biomedicine

[//]: # "This file is meant to be edited by the ontology maintainer."

\[ [Browse COB on Ontobee](https://ontobee.org/ontology/COB) \] \[ [View COB on GitHub](https://github.com/OBOFoundry/COB/) \]

The Core Ontology for Biology and Biomedicine (COB) aims to bring together key terms from a wide range of [Open Biological and Biomedical Ontologies (OBO)](http://obofoundry.org) Foundry projects into a single, small ontology. COB anchors these terms in the Basic Formal Ontology (BFO) which ensures that COB based ontologies are compatible with BFO, but COB elects to omit some of the complexities of BFO that have proven confusing to users in the biomedical domain. Our goal is to improve interoperability and term reuse across the OBO community through better coordination of widely-used terms. We intend to keep this ontology small while ensuring that one or more COB terms can be used as the root of any given OBO Foundry ontology.

**The 2024 COB Workshop will be hosted on September 23–24, 2024 at the La Jolla Institute for Immunology in La Jolla, CA. Please see the [Workshop](workshop2024.md) page for more information.**

## Why Use COB?
COB is designed to serve as a bridge between domain ontologies. COB ensures interoperability between the ontologies that extend from it, many of which were developed independently of each other and would otherwise be difficult to use together. COB is also designed to be small and concise in order to minimize clutter and promote ease of use by non-ontologists.

## What Does COB Do?
COB is unique among upper-level ontologies because it primarily gathers existing terms from other ontologies. This feature of COB is a product of the history of development of OBO Foundry ontologies.

COB was predated by several well-established and widely-reused biomedical ontologies, like the Gene Ontology (GO), the Ontology for Biomedical Investigations (OBI), and the Cell Ontology (CL). Many major biomedical ontologies that came before COB contained some terms that were outside of that ontology’s scope but which that ontology created because those necessary terms existed nowhere else at the time. For instance, OBI defined the class “organism” because OBI needed it, and there were no more general ontologies that defined “organism,” but it is obvious that the use case of the term “organism” is far broader than OBI’s intended scope of biomedical investigations. As a result, the most general, important, and widely-useful terms have historically been scattered throughout various long-standing OBO Foundry ontologies.

This presents a few problems. Firstly, it is not always obvious even to ontologists where these high-importance general terms are hosted. An ontology that needs the term “organism” but otherwise has no need for terms within the domain of biomedical investigations should not have to go to OBI for that term. When the placement of these general terms seems arbitrary and obscure to ontologists, it is even more difficult for non-ontologists to find the terms they need. Additionally, the scattered and decentralized development of highly general terms has led to unnecessary duplication of effort, as some general terms appear with different definitions in multiple ontologies. Sometimes these differing definitions are tailored to the domain of the ontology that created the term, despite its use-case being theoretically much wider, obfuscating which apparently general terms are actually intended for general use. This situation complicates the import dependencies of OBO domain ontologies; when nearly every biomedical ontology needs a very similar set of basic terms (such as “cell,” “organism,” and “protein”), it should not require a complex web of imports to get those terms into all the ontologies that need them.

COB seeks to solve these problems. Many of the basic terms created by long-standing OBO Foundry ontologies have good definitions, reliable logical connections, and a long history of use and development. COB brings together these high-quality general terms into a single ontology to improve the findability and interoperability of these terms. Accordingly, unlike many other OBO ontologies, COB is primarily made up of terms imported from other ontologies, rather than terms created by COB.

## Contact Us
To report a problem with COB, request the addition of a term, or open a discussion, please use our [GitHub Issue Tracker](https://github.com/OBOFoundry/COB/issues).

If you are responsible for an OBO ontology you can see any tickets that pertain to your ontology by looking for the label with your ontology ID.

For example:

 * **GO**: [https://github.com/OBOFoundry/COB/labels/GO](https://github.com/OBOFoundry/COB/labels/GO)
 * **OBI**: [https://github.com/OBOFoundry/COB/labels/OBI](https://github.com/OBOFoundry/COB/labels/OBI)

## Editors' Guide

You can find descriptions of the standard ontology engineering workflows [here](odk-workflows/index.md).

