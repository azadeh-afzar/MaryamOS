#!/usr/bin/env python

import os
import subprocess

LINKS_DIR = "links"
LINKS_LIST_DIR = "symlink list"

file_path = os.path.abspath(os.path.dirname(__file__))
links_dir_path = os.path.join(file_path, LINKS_DIR) 

dirs = [directory[0] for directory in os.walk(links_dir_path)]

dont_use = "links"
categories = ["apps"]

for dir in dirs:
    dir_name = os.path.basename(dir)
    upper_dirname = os.path.basename(os.path.dirname(dir))

    if dir_name == dont_use:
        continue

    if dir_name in categories:
        category_dir = os.path.join(file_path, LINKS_LIST_DIR, dir_name)
        subprocess.call(f"mkdir -p \"{category_dir}\"", shell=True)
        continue

    list_path = os.path.join(category_dir, f"{dir_name}.list")
    subprocess.call(f"ls \"{dir}\" -lhaF | grep ^l | grep -v \"\#\" | cut -c62- | sed 's/ ->//g' > \"{list_path}\"", shell=True)
    
    with open(f"{list_path}", "r") as file:
        content = file.readlines()
    
    for index, line in enumerate(content):
        line = line.split()
        line[0], line[1] = line[1], line[0] + "\n"
        line = " ".join(line)
        content[index] = line

    with open(f"{list_path}", "w+") as file:
        file.writelines(sorted(content))
