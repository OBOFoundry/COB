import requests

labels = {}

def expand(curie: str) -> str:
    return f"http://purl.obolibrary.org/obo/{curie.replace(':', '_')}"

def read_uris_from_file(filename):
    tuples = []
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith("ID"):
                continue
            toks = line.split("\t")
            curie = toks[0]
            label = toks[1]
            uri = expand(curie)
            labels[uri] = label
            tuples.append((uri, label))
    return tuples

def generate_sparql_query(uris):
    values_clause = "\n    ".join(f"<{uri}>" for uri in uris)
    return f"""PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT ?class (COUNT(DISTINCT ?subclass) AS ?subclassCount)
WHERE {{
  VALUES ?class {{
    {values_clause}
  }}
  ?subclass rdfs:subClassOf ?class .
  FILTER (?subclass != ?class)
}}
GROUP BY ?class
ORDER BY DESC(?subclassCount)"""

def execute_sparql_query(query):
    endpoint = "https://sparql.hegroup.org/sparql"
    headers = {
        "Accept": "application/sparql-results+json",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    data = {
        "query": query,
        "format": "json"
    }
    response = requests.post(endpoint, headers=headers, data=data)
    return response.json()

# Usage
pairs = read_uris_from_file('cob.tsv')
uris = [p[0] for p in pairs]
query = generate_sparql_query(uris)

results = execute_sparql_query(query)

# Process and print results
print("Class\tLabel\tSubclass Count")
for result in results['results']['bindings']:
    class_uri = result['class']['value']
    # label = result['label']['value']
    label = labels[class_uri]
    count = result['subclassCount']['value']
    print(f"{class_uri}\t{label}\t{count}")
    del labels[class_uri]
for class_uri, label in labels.items():
    print(f"{class_uri}\t{label}\t0")
