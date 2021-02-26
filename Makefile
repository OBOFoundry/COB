### Configuration
#
# These are standard options to make Make sane:
# <http://clarkgrubb.com/makefile-style-guide#toc2>
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

OBO := http://purl.obolibrary.org/obo
DATE = $(shell date +'%Y-%m-%d')
ROBOT := java -jar build/robot.jar

all: test build/report.tsv cob.owl cob.tsv

build:
	mkdir -p $@

ROBOT_DOWNLOAD=true

build/robot.jar: | build
	if [ $(ROBOT_DOWNLOAD) = true ]; then curl -L -o $@ https://build.obolibrary.io/job/ontodev/job/robot/job/master/lastSuccessfulBuild/artifact/bin/robot.jar; fi

########################################
# -- MAIN RELEASE PRODUCTS --
########################################

# create report and fail if errors introduced
.PRECIOUS: build/report.tsv
build/report.tsv: cob-edit.owl | build/robot.jar
	$(ROBOT) report \
	--input $^ \
	--labels true \
	--output $@

# build main release product
cob.owl: cob-edit.owl | build/robot.jar
	$(ROBOT) remove --input $< \
	--select imports \
	reason --reasoner hermit \
	annotate \
	--ontology-iri "http://purl.obolibrary.org/obo/$@" \
	--annotation owl:versionInfo $(DATE) \
	--output $@

# base file is main cob plus linking axioms
cob-base.owl: cob.owl cob-to-external.owl | build/robot.jar
	$(ROBOT) merge $(patsubst %, -i %, $^) -o $@

cob-base-reasoned.owl: cob-base.owl | build/robot.jar
	$(ROBOT) reason -i $< -r HERMIT -o $@

cob-examples-reasoned.owl: cob-base.owl cob-examples.owl | build/robot.jar
	$(ROBOT) merge -i cob-base.owl -i cob-examples.owl \
	reason -r HERMIT -o $@


# TSV export (may depend on dev version of robot export)
cob.tsv: cob.owl | build/robot.jar
	$(ROBOT) export -i $<  -c "ID|ID [LABEL]|definition|subClassOf [ID NAMED]|subClassOf [LABEL NAMED]|subClassOf [ID ANON]|subClassOf [LABEL ANON]" -e $@
#	$(ROBOT) export -i $< --entity-select NAMED -c "ID|ID [LABEL]|definition|subClassOf [ID]|subClassOf [LABEL]|subClassOf [ID ANON]|subClassOf [LABEL ANON]" -e $@

# -- BRIDGING AXIOMS TO OBO ROOTS --
#
#  the source file is cob-to-external.tsv
#
#  OWL is generated from this
#
# this is a really hacky way to do this, replace with robot report?
.PHONY: sssom
sssom:
	pip install sssom
	pip install --upgrade --no-deps --force-reinstall sssom==0.14.14.dev0

cob-to-external.sssom.owl: cob-to-external.tsv | sssom
	sssom convert -i $< -o $@

cob-to-external.owl: cob-to-external.sssom.owl | build/robot.jar
	$(ROBOT) remove -i $< \
	--term "http://w3id.org/sssom/MappingSet" \
	--term "http://w3id.org/sssom/mappings" \
	convert -o $@

build/cob-annotations.ttl: cob-to-external.owl sparql/external-links.rq | build/robot.jar
	$(ROBOT) query --input $< --query $(word 2,$^) $@

cob-annotations.owl: build/cob-annotations.ttl | build/robot.jar
	$(ROBOT) annotate --input $< \
	--ontology-iri "http://purl.obolibrary.org/obo/cob/$@" \
	--annotation owl:versionInfo $(DATE) \
	--output $@

########################################
# -- TESTING --
########################################

# in addition to standard testing, we also perform integration tests.
#
# here we join cob, cob-to-external (bridge ontology) and OBO ontology O;
# we then test this merged product for coherency.
#
# these tests are divided in two:
#
#  if an ontology that is known to be compliant is INCOHERENT, this is a failure
#  if an ontology that is known to be NON-compliant is unexpectedly COHERENT, this is a failure
#
# See https://github.com/OBOFoundry/COB/issues/71 for discussion
#
# Note that in addition to coherency testing, we also want to do orphan testing.
# No ontologies should have orphans - classes should have subClass ancestry to a COB class
#
# these list are incomplete: it can easily be added to:

COB_COMPLIANT = obi pato go cl uberon po uberon+cl ro envo ogms hp mp caro ido zfa xao bco fbbt doid so
COB_NONCOMPLIANT =  iao mondo  eco  maxo  mco  nbo peco ecto chebi
ALL_ONTS = $(COB_COMPLIANT) $(COB_NONCOMPLIANT)

test: main_test itest

# main test: should be run via CI on every PR
# this tests COB's internal consistency
main_test: build/report.tsv cob.owl cob-base-reasoned.owl cob-examples-reasoned.owl

# integration tests: for now, run these on commmand line
itest: itest_compliant itest_noncompliant #superclass_test

itest_compliant: $(patsubst %, build/reasoned-%.owl, $(ALL_ONTS))
itest_noncompliant: $(patsubst %, build/incoherent-%.txt, $(COB_NONCOMPLIANT))

# --
# orphan reports
# --
#
# PASSES: ENVO
# FAILS: anything with stages (PO, UBERON, ...): https://github.com/OBOFoundry/COB/issues/40
# FAILS: PATO we need characteristic https://github.com/OBOFoundry/COB/issues/65
orphans: $(patsubst %, products/orphans-%.tsv, $(ALL_ONTS))
root_orphans: $(patsubst %, products/root-orphans-%.tsv, $(ALL_ONTS))
superclass_test: orphans
	echo TODO: currently this test always passes

# merged product to be tested
build/merged-%.owl: build/relaxed-%.owl cob.owl cob-to-external.owl | build/robot.jar
	$(ROBOT) merge -i $< -i cob.owl -i cob-to-external.owl --collapse-import-closure true -o $@
.PRECIOUS: build/merged-%.owl

build/reasoned-%.owl build/status-%.txt: build/merged-%.owl | build/robot.jar
	(test -f build/debug-$*.owl && rm build/debug-$*.owl || echo) && \
	$(ROBOT) reason --reasoner ELK -i $< -D build/debug-$*.owl -o build/reasoned-$*.owl && echo SUCCESS > build/status-$*.txt || echo FAIL > build/status-$*.txt
.PRECIOUS: build/reasoned-%.owl

# TODO: implement https://github.com/ontodev/robot/issues/686
# then explain all incoherencies. use owltools for now
#build/incoherent-%.md: build/incoherent-%.owl
#	$(ROBOT) explain --reasoner ELK -i $< -o $@
build/incoherent-%.txt: build/reasoned-%.owl
	test -f build/debug-$*.owl && (owltools build/debug-$*.owl --run-reasoner -r elk -u -e | grep ^UNSAT | head -100 > $@) || echo COHERENT > $@

# test to see if the ontology has any classes that are not inferred subclasses of a COB
# class. Exceptions made for BFO which largely sits above COB.
# note that for 'reasoning' we use only subClassOf and equivalentClasses;
# this should be sufficient if input ontologies are pre-reasoned, and cob-to-external
# is all sub/equiv axioms
products/orphans-%.tsv: build/merged-%.owl
	robot query -f tsv -i $< -q sparql/no-cob-ancestor.rq $@.tmp && egrep -i '(^\?|/$*_)' $@.tmp | head -1000 > $@

all_orphans: $(patsubst %, products/root-orphans-%.txt, $(ALL_ONTS))
products/root-orphans-%.tsv: build/merged-%.owl
	robot query -f tsv -i $< -q sparql/cob-orphans.rq $@

build/SUMMARY.txt:
	(head build/status-*txt && head -1 build/incoherent-*txt) > $@

########################################
## -- Fetch Source Ontologies --
########################################
# cache ontology locally; by default we use main product...
build/source-%.owl:
	curl -L -s $(OBO)/$*.owl > $@.tmp && mv $@.tmp $@
.PRECIOUS: build/source-%.owl

# overrides for ontologies with bases
# TODO: we should use the registry for this
# see https://github.com/OBOFoundry/OBO-Dashboard/issues/20
build/source-go.owl:
	curl -L -s $(OBO)/go/go-base.owl > $@.tmp && mv $@.tmp $@
build/source-pato.owl:
	curl -L -s $(OBO)/pato/pato-base.owl > $@.tmp && mv $@.tmp $@
build/source-uberon.owl:
	curl -L -s $(OBO)/uberon/uberon-base.owl > $@.tmp && mv $@.tmp $@
build/source-cl.owl:
	curl -L -s $(OBO)/cl/cl-base.owl > $@.tmp && mv $@.tmp $@
build/source-envo.owl:
	curl -L -s $(OBO)/envo/envo-base.owl > $@.tmp && mv $@.tmp $@
build/source-hp.owl:
	curl -L -s $(OBO)/hp/hp-base.owl > $@.tmp && mv $@.tmp $@
build/source-mp.owl:
	curl -L -s $(OBO)/mp/mp-base.owl > $@.tmp && mv $@.tmp $@
build/source-ncbitaxon.owl:
	curl -L -s $(OBO)/ncbitaxon/taxslim.owl > $@.tmp && mv $@.tmp $@
build/source-obi.owl:
	curl -L -s $(OBO)/obi/obi-base.owl > $@.tmp && mv $@.tmp $@

# special cases
build/source-uberon+cl.owl: build/source-cl.owl build/source-uberon.owl | build/robot.jar
	$(ROBOT) merge $(patsubst %, -i %, $^) -o $@

# See: https://github.com/OBOFoundry/COB/issues/151
build/relaxed-%.owl: build/source-%.owl
	$(ROBOT) relax -i $< reason -r ELK -o $@

########################################
# -- EXEMPLAR ONTOLOGY --
########################################

DEMO_ONTS = go chebi envo ncbitaxon cl geo obi

DEMO_ONT_FILES = $(patsubst %,build/subset-%.owl,$(DEMO_ONTS))

# merge subsets together with cob;
# remove disjointness, for now we want to 'pass' ontologies for demo purposes
build/demo-cob-init.owl: $(DEMO_ONT_FILES) | build/robot.jar
	$(ROBOT) merge $(patsubst %, -i build/subset-%.owl,$(DEMO_ONTS)) \
              remove --axioms disjoint \
	      -o $@
.PRECIOUS: build/demo-cob-init.owl

# TODO: do this with robot somehow.
# equivalence pairs ugly for browsing; merge into COB
build/demo-cob-merged.owl: build/demo-cob-init.owl
	owltools $< --reasoner elk --merge-equivalence-sets -s COB 10 -l COB 10 -d COB 10  -o $@

# remove redundancy
# todo: remove danglers in fiinal release (use a SPARQL update), but produce a report
products/demo-cob.owl: build/demo-cob-merged.owl | build/robot.jar
	$(ROBOT) reason -r ELK -s true -i $< annotate -O $(OBO)/cob/demo-cob.owl -o products/demo-cob-d.owl && owltools products/demo-cob-d.owl --remove-dangling -o products/demo-cob.owl

build/subset-%.owl: build/merged-%.owl subsets/terms_%.txt | build/robot.jar
	$(ROBOT) extract -m BOT -i $< -T subsets/terms_$*.txt -o $@
