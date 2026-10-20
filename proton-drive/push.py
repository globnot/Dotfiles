#!/usr/bin/env python3
# Pousse récursivement local_root vers remote_root. N'importe quel dossier
# nommé ".obsidian" est ignoré partout dans l'arbre (config/cache/plugins
# Obsidian : régénérable, propre à cette machine, et peut contenir énormément
# de petits fichiers qui ralentissent tout pour rien). Un dossier sans aucun
# ".obsidian" en dessous est uploadé en un seul appel (plus rapide) ; sinon
# on recrée le dossier distant et on recurse dedans en excluant .obsidian.
import os
import subprocess
import sys

EXCLUDE_NAMES = {".obsidian"}


def escape(name):
    return name.replace("/", "\\/")


def has_excluded_descendant(path):
    for root, subdirs, files in os.walk(path):
        if EXCLUDE_NAMES & (set(subdirs) | set(files)):
            return True
    return False


def upload_dir(local_dir, remote_dir):
    entries = [e for e in os.listdir(local_dir) if e not in EXCLUDE_NAMES]
    if not entries:
        return

    to_upload = []
    to_recurse = []
    for e in entries:
        full = os.path.join(local_dir, e)
        if os.path.isdir(full) and has_excluded_descendant(full):
            to_recurse.append(e)
        else:
            to_upload.append(full)

    if to_upload:
        subprocess.run(
            ["proton-drive", "filesystem", "upload",
             "-f", "create-new-revision", "-d", "merge",
             *to_upload, remote_dir],
            check=True,
        )

    for e in to_recurse:
        remote_child = f"{remote_dir}/{escape(e)}"
        subprocess.run(
            ["proton-drive", "filesystem", "create-folder", remote_dir, e],
        )  # ignore l'erreur si le dossier existe déjà
        upload_dir(os.path.join(local_dir, e), remote_child)


if __name__ == "__main__":
    upload_dir(sys.argv[1], sys.argv[2])
