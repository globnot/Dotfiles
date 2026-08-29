#!/usr/bin/env python3
"""Positionne un écran par rapport à un autre, via un menu Rofi.
Applique le changement immédiatement (hyprctl eval). Ne modifie pas
hyprland.lua : pour un écran utilisé durablement, demander d'ajouter
un bloc hl.monitor({...}) permanent en plus de ce script."""

import json
import subprocess
import sys


def hyprctl_json(args):
    out = subprocess.check_output(["hyprctl", "-j"] + args)
    return json.loads(out)


def rofi_choice(prompt, options):
    proc = subprocess.run(
        ["rofi", "-dmenu", "-p", prompt],
        input="\n".join(options),
        capture_output=True,
        text=True,
    )
    return proc.stdout.strip()


def notify(msg):
    subprocess.run(["notify-send", "Arrangement écrans", msg])


def logical_size(mon):
    return mon["width"] / mon["scale"], mon["height"] / mon["scale"]


def main():
    try:
        monitors = hyprctl_json(["monitors"])
    except (subprocess.CalledProcessError, json.JSONDecodeError, FileNotFoundError) as e:
        notify(f"hyprctl indisponible : {e}")
        return

    if len(monitors) < 2:
        notify("Un seul écran détecté, rien à faire.")
        return

    names = [m["name"] for m in monitors]
    target_name = rofi_choice("Quel écran positionner ?", names)
    if target_name not in names:
        return

    ref_candidates = [n for n in names if n != target_name]
    ref_name = (
        ref_candidates[0]
        if len(ref_candidates) == 1
        else rofi_choice("Par rapport à quel écran ?", ref_candidates)
    )
    if ref_name not in ref_candidates:
        return

    target = next(m for m in monitors if m["name"] == target_name)
    ref = next(m for m in monitors if m["name"] == ref_name)

    t_w, t_h = logical_size(target)
    r_w, r_h = logical_size(ref)

    direction = rofi_choice(
        f"Positionner {target_name} où par rapport à {ref_name} ?",
        ["Droite", "Gauche", "Au-dessus", "En-dessous"],
    )

    rx, ry = ref["x"], ref["y"]
    if direction == "Droite":
        x, y = rx + r_w, ry
    elif direction == "Gauche":
        x, y = rx - t_w, ry
    elif direction == "Au-dessus":
        x, y = rx, ry - t_h
    elif direction == "En-dessous":
        x, y = rx, ry + r_h
    else:
        return

    x, y = int(round(x)), int(round(y))
    mode = f'{target["width"]}x{target["height"]}@{target["refreshRate"]:.2f}'
    scale = target["scale"]

    expr = (
        f'hl.monitor({{output="{target_name}", mode="{mode}", '
        f'position="{x}x{y}", scale={scale}}})'
    )
    try:
        subprocess.run(["hyprctl", "eval", expr], check=True)
    except subprocess.CalledProcessError as e:
        notify(f"Échec de l'application : {e}")
        return
    notify(f"{target_name} placé à côté de {ref_name} ({direction.lower()})")


if __name__ == "__main__":
    main()
