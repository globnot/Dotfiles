#!/bin/bash
# Génère ~/.config/clangd/config.yaml en scannant $HOME/Code : pour chaque
# projet (racine contenant un Makefile), génère un compile_commands.json
# (dans un cache local, hors du repo du projet) listant chaque .c avec ses
# -I, puis référence ce cache dans un fragment clangd conditionné par
# PathMatch. Le compile_commands.json permet à clangd d'indexer tout le
# projet en arrière-plan, donc "go to definition" (gd) saute bien dans le
# .c et pas seulement dans le prototype du .h.
#
# Regénérer après un nouveau clone via l'alias `clangd-refresh`.
set -euo pipefail

SCAN_DIR="${1:-$HOME/Code}"
OUT="$HOME/.config/clangd/config.yaml"
DB_ROOT="$HOME/.cache/clangd-db"

mkdir -p "$(dirname "$OUT")"

if [ ! -d "$SCAN_DIR" ]; then
  echo "Dossier introuvable : $SCAN_DIR (rien à scanner, relance clangd-refresh plus tard)" >&2
  exit 0
fi

# Cache regénéré en entier à chaque run pour ne pas garder de projets renommés/supprimés.
rm -rf "$DB_ROOT"
mkdir -p "$DB_ROOT"

# Racines de projets = dossiers avec Makefile qui n'ont pas d'ancêtre
# lui-même racine (pour ignorer libft/minilibx embarqués comme sous-projets,
# tout en gardant les libft/minilibx clonés en standalone).
mapfile -t all_dirs < <(
  find "$SCAN_DIR" -maxdepth 8 -type f -iname 'Makefile' -not -path '*/.git/*' 2>/dev/null \
    | xargs -r -n1 dirname \
    | sort -u
)

roots=()
for d in "${all_dirs[@]}"; do
  nested=0
  for other in "${all_dirs[@]}"; do
    [ "$d" = "$other" ] && continue
    case "$d" in
      "$other"/*) nested=1; break ;;
    esac
  done
  [ "$nested" -eq 0 ] && roots+=("$d")
done

{
  echo "# Fichier généré par Dotfiles/clangd/gen-config.sh — ne pas éditer à la main."
  echo "# Regénérer via l'alias clangd-refresh après un nouveau clone dans $SCAN_DIR."
  echo "---"
  echo "CompileFlags:"
  echo "  Add: [-Wall, -Wextra]"

  for root in "${roots[@]}"; do
    header_dirs=()
    while IFS= read -r d; do
      if compgen -G "$d"/*.h >/dev/null 2>&1; then
        header_dirs+=("-I$d")
      fi
    done < <(
      find "$root" -maxdepth 3 \( -name .git -o -name objs -o -name obj \) -prune -o -type d -print 2>/dev/null \
        | sort -u
    )

    [ "${#header_dirs[@]}" -eq 0 ] && continue

    mapfile -t c_files < <(
      find "$root" -maxdepth 6 \( -name .git -o -name objs -o -name obj \) -prune -o -type f -name '*.c' -print 2>/dev/null \
        | sort -u
    )

    if [ "${#c_files[@]}" -gt 0 ]; then
      db_dir="$DB_ROOT/$(echo "$root" | sed 's#^/##; s#/#__#g')"
      mkdir -p "$db_dir"

      {
        printf '['
        first=1
        for f in "${c_files[@]}"; do
          [ "$first" -eq 0 ] && printf ','
          first=0
          printf '{"directory":"%s","file":"%s","arguments":["cc","-Wall","-Wextra"' "$root" "$f"
          for inc in "${header_dirs[@]}"; do
            printf ',"%s"' "$inc"
          done
          printf ',"-c","%s","-o","/dev/null"]}' "$f"
        done
        printf ']'
      } > "$db_dir/compile_commands.json"

      echo "---"
      printf 'If:\n  PathMatch: "%s/.*"\n' "$root"
      echo "CompileFlags:"
      printf '  CompilationDatabase: "%s"\n' "$db_dir"
    else
      echo "---"
      printf 'If:\n  PathMatch: "%s/.*"\n' "$root"
      echo "CompileFlags:"
      printf '  Add: [%s]\n' "$(IFS=,; echo "${header_dirs[*]}")"
    fi
  done
} > "$OUT"

echo "Config clangd générée : $OUT (${#roots[@]} projet(s) scanné(s))"
