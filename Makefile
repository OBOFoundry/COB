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

DATE = $(shell date +'%Y-%m-%d')
ROBOT := java -jar build/robot.jar

all: test build/report.tsv cob.owl cob.tsv

build:
	mkdir $@

build/robot.jar: | build
	curl -L -o $@ https://github.com/ontodev/robot/releases/download/v1.5.0/robot.jar

# -- MAIN RELEASE PRODUCTS --

# create report and fail if errors introduced
build/report.tsv: cob-edit.owl | build/robot.jar
	$(ROBOT) report \
	--input $^ \
	--labels true \
	--output $@

# build main release product
cob.owl: cob-edit.owl | build/robot.jar
	$(ROBOT) reason --input $< --reasoner hermit \
	annotate \
	--ontology-iri "http://purl.obolibrary.org/obo/$@" \
	--version-iri "http://purl.obolibrary.org/obo/cob/$(DATE)/$@" \
	--output $@

# base file is main cob plus linking axioms
cob-base.owl: cob.owl cob-to-external.owl
	robot merge $(patsubst %, -i %, $^) -o $@

# TSV export (may depend on dev version of robot export)
cob.tsv: cob.owl
	robot export -i $< -c "ID|ID [label]|definition|subClassOf [ID]|subClassOf [label]" -e $@

# -- MAPPINGS TO OBO --
#
#  the source file is cob-to-external.tsv
#
#  OWL is generated from this
#
# this is a really hacky way to do this, replace with robot report?
cob-to-external.ttl: cob-to-external.tsv
	./util/tsv2rdf.pl $< > $@.tmp && mv $@.tmp $@
cob-to-external.owl: cob-to-external.ttl
	robot convert -i $< -o $@

# -- TESTING --

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

COB_COMPLIANT = pato go cl uberon po uberon+cl ro envo  ogms hp mp caro
COB_NONCOMPLIANT =  doid chebi obi mondo

test: main_test itest
main_test: build/report.tsv cob.owl

# integration tests
itest: itest_compliant itest_noncompliant

itest_compliant: $(patsubst %, build/reasoned-%.owl, $(COB_COMPLIANT))
itest_noncompliant: $(patsubst %, build/incoherent-%.owl, $(COB_COMPLIANT))

# cache ontology locally; by default we use main product...
build/source-%.owl:
	curl -L -s $(OBO)/$*.owl > $@.tmp && mv $@.tmp $@
.PRECIOUS: build/source-%.owl

# overrides for ontologies with bases
# TODO: we should use the registry for this
# see https://github.com/OBOFoundry/OBO-Dashboard/issues/20
build/source-go.owl:
	curl -L -s $(OBO)/go/go-base.owl > $@.tmp && mv $@.tmp $@
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

# special cases
build/source-uberon+cl.owl: build/source-cl.owl build/source-uberon.owl
	robot merge $(patsubst %, -i %, $^) -o $@

# merged product to be tested
build/merged-%.owl: build/source-%.owl cob.owl cob-to-external.owl
	robot merge -i $< -i cob.owl -i cob-to-external.owl --collapse-import-closure true -o $@
.PRECIOUS: build/merged-%.owl

# reasoned product; this will FAIL if incoherent
build/reasoned-%.owl: build/merged-%.owl
	touch $@.RUN && robot reason --reasoner ELK -i $< -o $@ && rm $@.RUN

# incoherent product; we EXPECT to be incoherent. If it is not, then we FAIL
build/incoherent-%.owl: build/merged-%.owl
	touch $@.RUN && robot reason --reasoner ELK -D $@ -i $< -o $@ || rm $@.RUN

# TODO: implement https://github.com/ontodev/robot/issues/686
# then explain all incoherencies. use owltools for now
#build/incoherent-%.md: build/incoherent-%.owl
#	robot explain --reasoner ELK -i $< -o $@
build/incoherent-%.md: build/incoherent-%.owl
	owltools $< --run-reasoner -r elk -u -e | grep ^UNSAT > $@
