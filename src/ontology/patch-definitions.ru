PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

DELETE {
	?subject obo:IAO_0000115 ?object .
}

INSERT {
	?subject obo:IAO_0000115 ?object_str .
}

WHERE {
	VALUES ?subject {
		# These terms use xsd:string literals not @en
		obo:CHEBI_10545
		obo:CHEBI_24636
		obo:CHEBI_30222
		obo:CHEBI_33252
		obo:CHEBI_36342
		obo:CL_0000000
		obo:CL_0001034
		obo:ENVO_01000813
		obo:ENVO_01001110
		obo:ENVO_02500000
		obo:GO_0003674
		obo:GO_0005575
		obo:GO_0008150
		obo:GO_0032991
		obo:GO_0044423
		obo:GO_0110165
		obo:IAO_0000115
		obo:MOP_0000543
		obo:NCBITaxon_131567
		obo:PATO_0000125
		obo:PATO_0002193
		obo:PO_0009002
		obo:PO_0025131
		obo:PR_000000001
		obo:PR_000018263
		obo:SO_0000110
		obo:SO_0001060
		obo:SO_0001260
		obo:UBERON_0000465
		obo:UBERON_0000466
		obo:UBERON_0001062
		obo:VO_0000001
        obo:GO_0110165
        obo:IAO_0000115
        obo:OBI_0000293
        obo:OBI_0000295
        obo:OBI_0000299
        obo:OBI_0000659
        obo:OBI_0100051
        obo:RO_0002215
        obo:RO_0002219
        obo:RO_0002221
        obo:RO_0002233
        obo:RO_0002234
        obo:RO_0002333
	}
	?subject obo:IAO_0000115 ?object	.
	BIND(STR(?object) AS ?object_str)
}
