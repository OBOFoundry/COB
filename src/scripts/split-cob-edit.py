#!/usr/bin/env python3
#
# Split the cob-edit.tsv file into three ROBOT templates:
# cob-base.tsv cob-full.tsv cob-root.tsv

import argparse
import csv
import os
import re


def initialize_tsv(output_dir, filename, fieldnames, robot_row):
    '''Initialize and return a DictWriter for a ROBOT template.'''
    path = os.path.join(output_dir, filename)
    path_fh = open(path, 'w')
    writer = csv.DictWriter(path_fh, fieldnames, delimiter='\t', lineterminator='\n', extrasaction='ignore')
    writer.writeheader()
    writer.writerow(robot_row)
    return writer


def split(input_path, output_dir):
    '''Split the COB term template into base, full, and root templates.'''
    header_row = None
    robot_row, terms, replacements = {}, {}, {}

    with open(input_path) as f:
        rows = csv.DictReader(f, delimiter='\t')
        for row in rows:
            if not header_row:
                header_row = list(row.keys())
            id = row['Ontology ID'].strip()
            if id == '':
                continue
            if id == 'ID':
                robot_row = row
                continue

            # Handle the Replacement columns
            # by collecting a dictionary of replacements.
            replacement_id = row['Replacement ID'].strip()
            replacement_label = row['Replacement Label'].strip()
            if replacement_label and replacement_label != '':
                # removed exception for non-base IDs... TBD if needed/wanted
                replacements[row['Label'].strip()] = {
                    'ID': id,
                    'Replacement Label': replacement_label,
                    'Replacement ID': replacement_id,
                }
            # Otherwise just add this row to 'terms'.
            else:
                terms[id] = row

    ignore = [
        'COB Module', 'COB Module Reason',
        'Replacement ID', 'Replacement Label',
        'Comment'
    ]
    fieldnames = [x for x in header_row if x not in ignore]

    # Apply replacements to the axioms in all the logical columns
    axiom_cols = [
        'Parent Class', 'Subclass Axiom', 'Equivalent Class Axiom',
        'Disjoint Class', 'Parent Property', 'Domain', 'Range',
        'Inverse Property'
    ]
    for id, row in terms.items():
        for repl_label, repl_dict in replacements.items():
            for col in axiom_cols:
                if col not in row:
                    continue
                row[col] = re.sub(repl_label, repl_dict['Replacement Label'], row[col])

    base_writer = initialize_tsv(output_dir, 'cob-base.tsv', fieldnames, robot_row)
    full_writer = initialize_tsv(output_dir, 'cob-full.tsv', fieldnames, robot_row)
    root_writer = initialize_tsv(output_dir, 'cob-root.tsv', fieldnames, robot_row)

    for id, row in terms.items():
        module = row['COB Module'].strip()
        if module == 'BASE':
            base_writer.writerow(row)
        if module not in ['', 'ROOT']:
            full_writer.writerow(row)
        if module != '':
            root_writer.writerow(row)


def main():
    parser = argparse.ArgumentParser(description='Split the main COB term template into multiple module templates')
    parser.add_argument('input', type=str, help='The input COB term template')
    parser.add_argument('outdir', type=str, help='The output directory')
    args = parser.parse_args()

    split(args.input, args.outdir)


if __name__ == '__main__':
    main()
