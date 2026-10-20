#!/usr/bin/env python3
# Met à la corbeille (jamais une suppression définitive) tout ce qui existe
# sous un dossier distant donné mais plus en local au même endroit — sans
# ça, un renommage ou une suppression locale laisse un doublon/orphelin
# distant (push.py ne fait qu'ajouter/mettre à jour, jamais supprimer).
#
# Prend en entrée (stdin) la liste des dossiers locaux à vérifier — pas tout
# l'arbre : sync.sh ne passe que les dossiers modifiés depuis le dernier
# passage (comparaison de date de modification), pour éviter de rescanner
# des centaines de dossiers inchangés à chaque exécution horaire. Chaque
# dossier listé = un aller-retour réseau, d'où aussi le pool de threads
# (I/O-bound, le GIL ne gêne pas ici).
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

MAX_WORKERS = 16


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


def remote_path_for(local_root, remote_root, local_dir):
    rel = os.path.relpath(local_dir, local_root)
    if rel == ".":
        return remote_root
    parts = [escape(p) for p in rel.split(os.sep)]
    return remote_root + "/" + "/".join(parts)


def check_dir(local_root, remote_root, local_dir):
    remote_dir = remote_path_for(local_root, remote_root, local_dir)
    to_delete = []
    for item in remote_list(remote_dir):
        name = item["name"]["value"]
        if not os.path.exists(os.path.join(local_dir, name)):
            to_delete.append(f"{remote_dir}/{escape(name)}")
    return to_delete


def main():
    local_root, remote_root = sys.argv[1], sys.argv[2]
    dirs = [line.strip() for line in sys.stdin if line.strip()]
    if not dirs:
        return

    to_delete = []
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        for result in executor.map(lambda d: check_dir(local_root, remote_root, d), dirs):
            to_delete.extend(result)

    for path in to_delete:
        print(f"Trash: {path}")
        subprocess.run(["proton-drive", "filesystem", "trash", path])


if __name__ == "__main__":
    main()
