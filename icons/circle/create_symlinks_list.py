#!/usr/bin/env python

import os
import subprocess

LINKS_DIR = "links"
LINKS_LIST_DIR = "symlink list"

file_path = os.path.abspath(os.path.dirname(__file__))
links_dir_path = os.path.join(file_path, LINKS_DIR) 

dirs = [directory[0] for directory in os.walk(links_dir_path)]

dont_use = "links"
categories = ["actions", "apps", "devices", "emblems", "mimes", "places", "status"]

for dir in dirs:
    dir_name = dir.split("/")[-1]
    upper_dirname = dir.split("/")[-2]

    if dir_name == dont_use:
        continue

    if dir_name in categories:
        mkpath = os.path.join(file_path, LINKS_LIST_DIR, dir_name)
        subprocess.call(f"mkdir -p \"{mkpath}\"", shell=True)
        continue

    lspath = os.path.join(mkpath, f"{dir_name}.list")
    subprocess.call(f"ls \"{dir}\" -lhaF | grep ^l | grep -v \"\#\" | cut -c62- | sed 's/ ->//g' > \"{lspath}\"", shell=True)
    
    with open(f"{lspath}", "r") as file:
        content = file.readlines()
    
    for index, line in enumerate(content):
        line = line.split()
        line[0], line[1] = line[1], line[0] + "\n"
        line = " ".join(line)
        content[index] = line

    with open(f"{lspath}", "w+") as file:
        file.writelines(sorted(content))
