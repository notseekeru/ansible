#!/usr/bin/env bash
# new-role.sh — scaffold an Ansible role from a canonical house template.
#
# Design: the template lives OUTSIDE roles/ (under _role_templates/) so the
# ansible roles_path and `make molecule` auto-discovery never touch it. It is a
# real, lint-clean role whose only job is to be the starting shape. There is no
# second convention doc to keep in sync: the shape you copy IS the current house
# form (install/uninstall split, SPDX headers, empty vars stub, molecule trio).
#
# Usage:
#   scripts/new-role.sh NAME
#   scripts/new-role.sh NAME form=features     # multi-task (hardening) layout
#   make new-role NAME=...                      # wrapper target
#
# All `__role_name__` tokens in the template are replaced with NAME.
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SELF_DIR/.." && pwd)"

NAME="${1:-}"
FORM="install"
for a in "$@"; do
  case "$a" in
    form=*) FORM="${a#form=}" ;;
  esac
done

usage() {
  echo "Usage: scripts/new-role.sh NAME [form=install|features]"
  exit 1
}
[ -n "$NAME" ] || usage
case "$NAME" in
  *[!a-z0-9_]* ) echo "❌ NAME must be lowercase alnum/_ (got: $NAME)"; exit 1 ;;
esac

TPL_DIR="$ROOT_DIR/_role_templates/form-$FORM"
if [ ! -d "$TPL_DIR" ]; then
  echo "❌ No template _role_templates/form-$FORM. Available:"; ls "$ROOT_DIR"/_role_templates | sed 's/^/   form-/'; exit 1
fi
if [ -e "$ROOT_DIR/roles/$NAME" ]; then
  echo "❌ roles/$NAME already exists."; exit 1
fi

# --- clone + token-replace every __role_name__ occurrence -------------------
find "$ROOT_DIR/_role_templates/form-$FORM" -type f \
  | while read -r f; do
      rel="${f#"$ROOT_DIR/_role_templates/form-$FORM"/}"
      mkdir -p "$ROOT_DIR/roles/$NAME/$(dirname "$rel")"
      sed "s/__role_name__/$NAME/g" "$f" > "$ROOT_DIR/roles/$NAME/$rel"
    done

echo "✅ Generated roles/$NAME from _role_templates/form-$FORM"
echo
echo "Next steps:"
echo "  1. Fill in tasks/ — keep real toggles (e.g. ${NAME}_remove) in defaults."
echo "     Delete unused example feature/remove files you don't need."
echo "  2. defaults/main.yml — keep toggles, drop unused examples."
echo "  3. meta/main.yml — set galaxy description + tags."
echo "  4. molecule/default/{converge,verify}.yml — assert YOUR role's real effect."
echo "  5. README.md — rewrite role table."
echo
echo "Verify:"
echo "  make lint"
echo "  (cd roles/$NAME && molecule test -s default)"
