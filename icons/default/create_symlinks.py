#!/usr/bin/env python

import os
import subprocess

SYMLINK_LIST_DIR = "symlink list"
SYMLINK_DIR = 'links'

file_path = os.path.abspath(os.path.dirname(__file__))
symlink_list_directory = os.path.join(file_path, SYMLINK_LIST_DIR)
symlink_directory = os.path.join(file_path, SYMLINK_DIR)

categories = ["actions", "apps", "devices", "emblems", "mimes", "places", "status"]

category_list_dirs = [os.path.join(symlink_list_directory, category) for category in categories]
category_dirs = { category : os.path.join(symlink_directory, category) for category in categories }

subprocess.call(f"rm -rf \"{symlink_directory}\"", shell=True)
subprocess.call(f"mkdir -p \"{symlink_directory}\"", shell=True)

for category in categories:
    subprocess.call(f"mkdir -p \"{category_dirs[category]}\"", shell=True)

for dir in category_list_dirs:
    files = [os.path.join(dir, file) for file in os.listdir(dir) if os.path.isfile(os.path.join(dir, file))]

    for file in files:
        category_path = category_dirs[os.path.basename(os.path.dirname(file))]
        variant_dir = os.path.basename(file).split(".list")[0]
        final_path = os.path.join(category_path, variant_dir)
        subprocess.call(f"mkdir -p \"{final_path}\"", shell=True)

        with open(file, "r") as sym_list_file:
            sym_list = sym_list_file.readlines()
        
        for line in sym_list:
            line = " ".join(line.split())
            subprocess.call(f"cd \"{final_path}\" && ln -sf {line}", shell=True)





