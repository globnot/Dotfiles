#!/usr/bin/env python3
# Pousse les fichiers des dossiers donnés en entrée (stdin, voir prune.py
# pour pourquoi ce n'est pas tout l'arbre) vers Proton Drive. Crée le
# dossier distant correspondant s'il n'existe pas encore (erreur ignorée
# sinon), puis upload tous les fichiers directement dedans (pas les
# sous-dossiers : chaque sous-dossier modifié apparaît séparément dans la
# liste reçue, avec son propre appel).
import os
import subprocess
import sys


def escape(name):
    return name.replace("/", "\\/")


def remote_path_for(local_root, remote_root, local_dir):
    rel = os.path.relpath(local_dir, local_root)
    if rel == ".":
        return remote_root
    parts = [escape(p) for p in rel.split(os.sep)]
    return remote_root + "/" + "/".join(parts)


def push_dir(local_root, remote_root, local_dir):
    remote_dir = remote_path_for(local_root, remote_root, local_dir)
    if remote_dir != remote_root:
        parent, name = remote_dir.rsplit("/", 1)
        subprocess.run(["proton-drive", "filesystem", "create-folder", parent, name])

    files = [
        os.path.join(local_dir, e) for e in os.listdir(local_dir)
        if os.path.isfile(os.path.join(local_dir, e))
    ]
    if not files:
        return

    subprocess.run(
        ["proton-drive", "filesystem", "upload",
         "-f", "create-new-revision", "-d", "merge",
         *files, remote_dir],
        check=True,
    )


def main():
    local_root, remote_root = sys.argv[1], sys.argv[2]
    dirs = [line.strip() for line in sys.stdin if line.strip()]
    for d in dirs:
        push_dir(local_root, remote_root, d)


if __name__ == "__main__":
    main()
