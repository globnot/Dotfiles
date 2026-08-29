#!/usr/bin/env python3
# Lance un nouveau kitty dans le dossier courant du terminal kitty
# actuellement focus (au lieu de toujours $HOME).
#
# Pourquoi passer par le contrôle à distance de kitty plutôt que /proc :
# le champ "cwd" propre à la fenêtre kitty ne bouge jamais après un `cd`
# (c'est le dossier de lancement). Parcourir /proc à la main pour trouver
# "le" process enfant est fragile (plusieurs onglets/enfants possibles,
# PID réutilisés). kitty, lui, connaît déjà le vrai process au premier
# plan de son pty (via foreground_processes) — c'est fiable, on s'en sert.
import json
import os
import subprocess

HOME = os.path.expanduser("~")


def focused_kitty_cwd(pid):
    out = subprocess.run(
        ["kitty", "@", "--to", f"unix:@mykitty-{pid}", "ls"],
        capture_output=True, text=True, timeout=1,
    ).stdout
    for os_window in json.loads(out):
        for tab in os_window.get("tabs", []):
            for window in tab.get("windows", []):
                if not window.get("is_focused"):
                    continue
                procs = window.get("foreground_processes") or []
                if procs:
                    return procs[-1]["cwd"]  # le plus imbriqué = le vrai premier plan
    return None


cwd = HOME
try:
    active = json.loads(
        subprocess.run(["hyprctl", "activewindow", "-j"], capture_output=True, text=True).stdout
    )
    if active and active.get("class") == "kitty":
        found = focused_kitty_cwd(active["pid"])
        if found:
            cwd = found
except (subprocess.SubprocessError, json.JSONDecodeError, KeyError, OSError):
    pass

os.execvp("kitty", ["kitty", "--directory", cwd])
