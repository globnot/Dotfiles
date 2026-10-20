#!/usr/bin/env python3
# Met à la corbeille (jamais une suppression définitive) tout ce qui existe
# sous remote_root sur Proton Drive mais plus sous local_root en local —
# sans ça, un renommage ou une suppression locale laisse un doublon/orphelin
# distant (le reste de sync.sh ne fait qu'ajouter/mettre à jour, jamais
# supprimer). Appelé par sync.sh avant l'upload.
import json
import os
import subprocess
import sys


def remote_list(path):
    result = subprocess.run(
        ["proton-drive", "filesystem", "list", path, "-j"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        return []
    return json.loads(result.stdout)


def escape(name):
    return name.replace("/", "\\/")


EXCLUDE_NAMES = {".obsidian"}


def walk_remote(remote_path, local_path, to_delete):
    for item in remote_list(remote_path):
        name = item["name"]["value"]
        if name in EXCLUDE_NAMES:
            continue
        remote_child = f"{remote_path}/{escape(name)}"
        local_child = os.path.join(local_path, name)
        if not os.path.exists(local_child):
            to_delete.append(remote_child)
        elif item["type"] == "folder":
            walk_remote(remote_child, local_child, to_delete)


def main():
    local_root, remote_root = sys.argv[1], sys.argv[2]
    to_delete = []
    walk_remote(remote_root, local_root, to_delete)
    for path in to_delete:
        print(f"Trash: {path}")
        subprocess.run(["proton-drive", "filesystem", "trash", path])


if __name__ == "__main__":
    main()
