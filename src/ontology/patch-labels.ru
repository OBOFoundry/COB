PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

DELETE {
    ?subject rdfs:label ?object .
}

INSERT {
    ?subject rdfs:label ?object_str .
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
		obo:GO_0005575
		obo:GO_0032991
		obo:GO_0044423
		obo:GO_0110165
		obo:IAO_0000115
		obo:MOP_0000543
		obo:NCBITaxon_131567
		obo:OBI_0000659
		obo:OBI_0001479
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
    }
    ?subject rdfs:label ?object .
    BIND(STR(?object) AS ?object_str)
}
