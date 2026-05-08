import csv


def generate_report(path, rows):
    lines = [
        "PREFIX owl: <http://www.w3.org/2002/07/owl#>",
        "PREFIX BFO: <http://purl.obolibrary.org/obo/BFO_>",
        "PREFIX CHEBI: <http://purl.obolibrary.org/obo/CHEBI_>",
        "PREFIX OBI: <http://purl.obolibrary.org/obo/OBI_>",
        "",
        "SELECT DISTINCT ?curie ?label ?comment ?replacement ?replacement_label ?suggestion ?suggestion_label",
        "WHERE {",
        "  VALUES (?iri ?curie ?label ?comment ?replacement ?replacement_label ?suggestion ?suggestion_label) {",
    ]
    for row in rows:
        lines.append(f"""    ({row['ID']} "{row['ID']}" "{row['Label']}" "{row['Comment']}" "{row['Replacement']}" "{row['Replacement Label']}" "{row['Suggestion']}" "{row['Suggestion Label']}")""")
    lines += [
        "  }",
        "  ?iri ?p ?o",
        "  FILTER NOT EXISTS {",
        "    ?iri owl:deprecated ?deprecated",
        "  }",
        "}",
    ]
    f = open(path, "w")
    for line in lines:
        f.write(line + '\n')


def generate_remove_annotations(path, rows):
    lines = []
    for row in rows:
        lines.append(f"{row['ID']} # {row['Label']}")
    f = open(path, "w")
    for line in lines:
        f.write(line + '\n')


def generate_remove_axioms(path, rows):
    lines = []
    signature = set()
    for row in rows:
        lines.append(f"{row['ID']} # {row['Label']}")
        if row['Signature']:
            for term in row['Signature'].split():
                signature.add(term)
    for term in signature:
        lines.append(f"{term}")
    f = open(path, "w")
    for line in lines:
        f.write(line + '\n')


def generate_strict_replacement(path, rows):
    lines = ["Old IRI\tNew IRI"]
    for row in rows:
        lines.append(f"{row['ID']}\t{row['Replacement']}")
    f = open(path, "w")
    for line in lines:
        f.write(line + '\n')


def generate_suggested_replacement(path, rows):
    lines = ["Old IRI\tNew IRI"]
    for row in rows:
        if row['Suggestion']:
            lines.append(f"{row['ID']}\t{row['Suggestion']}")
        else:
            lines.append(f"{row['ID']}\t{row['Replacement']}")
    f = open(path, "w")
    for line in lines:
        f.write(line + '\n')


if __name__ == "__main__":
    path = "migrate.tsv"
    with open(path) as f:
        rows = list(csv.DictReader(f, delimiter="\t"))
        generate_report("report.rq", rows)
        generate_remove_annotations("remove-annotations.txt", rows)
        generate_remove_axioms("remove-axioms.txt", rows)
        generate_strict_replacement("strict-replacement.tsv", rows)
        generate_suggested_replacement("suggested-replacement.tsv", rows)

