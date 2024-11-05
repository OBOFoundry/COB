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

.PHONY: prepare_release
prepare_release: $(ASSETS) $(PATTERN_RELEASE_FILES)
	rsync -R $(RELEASE_ASSETS) $(RELEASEDIR) &&\
	rm -f $(CLEANFILES) &&\
	echo "Release files are now in $(RELEASEDIR) - now you should commit, push and make a release on your git hosting site such as GitHub or GitLab"

.PHONY: prepare_cob_products
prepare_cob_products: test
	cp -r products/* $(RELEASEDIR)/products

.PHONY: all
all: prepare_release prepare_cob_products

ROBOT_DOWNLOAD=true

products/:
	mkdir -p $@

$(TMPDIR)/robot.jar: | $(TMPDIR)
	if [ $(ROBOT_DOWNLOAD) = true ]; then curl -L -o $@ https://build.obolibrary.io/job/ontodev/job/robot/job/master/lastSuccessfulBuild/artifact/bin/robot.jar; fi


########################################
# -- TEMPLATES --
########################################

$(TMPDIR)/cob-%.tsv: $(SCRIPTSDIR)/split-cob-edit.py cob-edit.tsv
	$^ $(TMPDIR)


########################################
# -- MAIN RELEASE PRODUCTS --
########################################

$(ONT)-edit.owl: $(TMPDIR)/cob-root.tsv $(COMPONENTSDIR)/obsolete.tsv
	$(ROBOT) template \
	$(foreach X,$(filter %.tsv,$^),--template $(X)) \
	reason -r HERMIT \
	annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
	--output $@.tmp.owl && mv $@.tmp.owl $@

# COB "Full"
$(ONT).owl: $(TMPDIR)/cob-full.tsv $(COMPONENTSDIR)/obsolete.tsv
	$(ROBOT) template \
	$(foreach X,$(filter %.tsv,$^),--template $(X)) \
	reason -r HERMIT \
	annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
	--output $@.tmp.owl && mv $@.tmp.owl $@

$(ONT)-base.owl: $(ONT).owl $(TMPDIR)/cob-base.tsv $(COMPONENTSDIR)/obsolete.tsv
	$(ROBOT) template --input $< \
	$(foreach X,$(filter %.tsv,$^),--template $(X)) \
	annotate --link-annotation http://purl.org/dc/elements/1.1/type http://purl.obolibrary.org/obo/IAO_8000001 \
	--ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
	--output $@.tmp.owl && mv $@.tmp.owl $@

$(ONT)-root.owl: $(TMPDIR)/cob-root.tsv $(COMPONENTSDIR)/obsolete.tsv
	$(ROBOT) template \
	$(foreach X,$^,--template $(X)) \
	reason -r HERMIT \
	annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
	--output $@.tmp.owl && mv $@.tmp.owl $@


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

.PHONY: cob_test
cob_test: main_test itest


# main test: should be run via CI on every PR
# this tests COB's internal consistency
.PHONY: main_test
main_test: $(REPORTDIR)/$(SRC)-obo-report.tsv $(RELEASEDIR)/cob-root.owl
test: main_test

# integration tests: for now, run these on commmand line
.PHONY: itest
itest: itest_compliant itest_noncompliant #superclass_test
	make products/SUMMARY.txt

itest_compliant: $(patsubst %, $(TMPDIR)/reasoned-%.owl, $(ALL_ONTS))
itest_noncompliant: $(patsubst %, $(TMPDIR)/incoherent-%.txt, $(COB_NONCOMPLIANT))

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
$(TMPDIR)/merged-%.owl: $(TMPDIR)/relaxed-%.owl cob.owl $(COB_TO_EXTERNAL) | $(TMPDIR)
	$(ROBOT) merge -i $< -i cob.owl -i $(COB_TO_EXTERNAL) --collapse-import-closure true -o $@
.PRECIOUS: $(TMPDIR)/merged-%.owl

$(TMPDIR)/reasoned-%.owl $(TMPDIR)/status-%.txt: $(TMPDIR)/merged-%.owl | $(TMPDIR)
	(test -f $(TMPDIR)/debug-$*.owl && rm $(TMPDIR)/debug-$*.owl || echo) && \
	$(ROBOT) reason --reasoner ELK -i $< -D $(TMPDIR)/debug-$*.owl -o $(TMPDIR)/reasoned-$*.owl && echo SUCCESS > $(TMPDIR)/status-$*.txt || echo FAIL > $(TMPDIR)/status-$*.txt
.PRECIOUS: $(TMPDIR)/reasoned-%.owl

# TODO: implement https://github.com/ontodev/robot/issues/686
# then explain all incoherencies. use owltools for now
#$(TMPDIR)/incoherent-%.md: $(TMPDIR)/incoherent-%.owl
#	$(ROBOT) explain --reasoner ELK -i $< -o $@
$(TMPDIR)/incoherent-%.txt: $(TMPDIR)/reasoned-%.owl | $(TMPDIR)
	test -f $(TMPDIR)/debug-$*.owl && (owltools $(TMPDIR)/debug-$*.owl --run-reasoner -r elk -u -e | grep ^UNSAT | head -100 > $@) || echo COHERENT > $@

# test to see if the ontology has any classes that are not inferred subclasses of a COB
# class. Exceptions made for BFO which largely sits above COB.
# note that for 'reasoning' we use only subClassOf and equivalentClasses;
# this should be sufficient if input ontologies are pre-reasoned, and cob-to-external
# is all sub/equiv axioms
products/orphans-%.tsv: $(TMPDIR)/merged-%.owl | products/
	robot query -f tsv -i $< -q $(SPARQLDIR)/no-cob-ancestor.rq $@.tmp && egrep -i '(^\?|/$*_)' $@.tmp | head -1000 > $@

all_orphans: $(patsubst %, products/root-orphans-%.txt, $(ALL_ONTS))
products/root-orphans-%.tsv: $(TMPDIR)/merged-%.owl | products/
	robot query -f tsv -i $< -q $(SPARQLDIR)/cob-orphans.rq $@

products/SUMMARY.txt: | products/
	(head $(TMPDIR)/status-*txt && head -1 $(TMPDIR)/incoherent-*txt) > $@

########################################
## -- Fetch Source Ontologies --
########################################
# cache ontology locally; by default we use main product...
$(TMPDIR)/source-%.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/$*.owl > $@.tmp && mv $@.tmp $@
.PRECIOUS: $(TMPDIR)/source-%.owl

# overrides for ontologies with bases
# TODO: we should use the registry for this
# see https://github.com/OBOFoundry/OBO-Dashboard/issues/20
$(TMPDIR)/source-go.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/go/go-base.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-pato.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/pato/pato-base.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-uberon.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/uberon/uberon-base.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-cl.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/cl/cl-base.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-envo.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/envo/envo-base.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-hp.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/hp/hp-base.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-mp.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/mp/mp-base.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-ncbitaxon.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/ncbitaxon/taxslim.owl > $@.tmp && mv $@.tmp $@
$(TMPDIR)/source-obi.owl: | $(TMPDIR)
	curl -L -s $(URIBASE)/obi/obi-base.owl > $@.tmp && mv $@.tmp $@

# special cases
$(TMPDIR)/source-uberon+cl.owl: $(TMPDIR)/source-cl.owl $(TMPDIR)/source-uberon.owl | $(TMPDIR)
	$(ROBOT) merge $(patsubst %, -i %, $^) -o $@

# See: https://github.com/OBOFoundry/COB/issues/151
$(TMPDIR)/relaxed-%.owl: $(TMPDIR)/source-%.owl | $(TMPDIR)
	$(ROBOT) relax -i $< reason -r ELK -o $@

########################################
# -- EXEMPLAR ONTOLOGY --
########################################

DEMO_ONTS = go chebi envo ncbitaxon cl geo obi

DEMO_ONT_FILES = $(patsubst %,$(TMPDIR)/subset-%.owl,$(DEMO_ONTS))

# merge subsets together with cob;
# remove disjointness, for now we want to 'pass' ontologies for demo purposes
$(TMPDIR)/demo-cob-init.owl: $(DEMO_ONT_FILES) | $(TMPDIR)
	$(ROBOT) merge $(patsubst %, -i $(TMPDIR)/subset-%.owl,$(DEMO_ONTS)) \
              remove --axioms disjoint \
	      -o $@
.PRECIOUS: $(TMPDIR)/demo-cob-init.owl

# TODO: do this with robot somehow.
# equivalence pairs ugly for browsing; merge into COB
$(TMPDIR)/demo-cob-merged.owl: $(TMPDIR)/demo-cob-init.owl | $(TMPDIR)
	owltools $< --reasoner elk --merge-equivalence-sets -s COB 10 -l COB 10 -d COB 10  -o $@

# remove redundancy
# todo: remove danglers in fiinal release (use a SPARQL update), but produce a report
products/demo-cob.owl: $(TMPDIR)/demo-cob-merged.owl | products/
	$(ROBOT) reason -r ELK -s true -i $< annotate -O $(URIBASE)/cob/demo-cob.owl -o products/demo-cob-d.owl && owltools products/demo-cob-d.owl --remove-dangling -o products/demo-cob.owl

$(TMPDIR)/subset-%.owl: $(TMPDIR)/merged-%.owl subsets/terms_%.txt | $(TMPDIR)
	$(ROBOT) extract -m BOT -i $< -T subsets/terms_$*.txt -o $@
