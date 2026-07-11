#!/usr/bin/env bash
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && { pwd -W 2>/dev/null || pwd; })"
GODOT_BIN="${GODOT_BIN:-godot4}"

# En Windows (git-bash/MSYS) el binario nativo de Godot no acepta rutas
# estilo /c/Users/...; hay que convertirlas a C:\Users\... con cygpath.
if command -v cygpath >/dev/null 2>&1; then
  PROJECT_DIR="$(cygpath -m "$PROJECT_DIR")"
fi

TEST_SCENES=(
  "res://tests/save_load_test.tscn"
  "res://tests/save_version_mismatch_test.tscn"
  "res://tests/save_collectible_test.tscn"
  "res://tests/ui_save_load_test.tscn"
  "res://tests/save_medal_world_test.tscn"
  "res://tests/pause_menu_test.tscn"
  "res://tests/onboarding_test.tscn"
  "res://tests/victory_summary_test.tscn"
  "res://tests/bike_test.tscn"
  "res://tests/boss_test.tscn"
  "res://tests/diary_test.tscn"
  "res://tests/audio_test.tscn"
)

printf 'Running Firipu Adventure tests with %s\n' "$GODOT_BIN"
printf 'Project: %s\n\n' "$PROJECT_DIR"

overall=0
for scene in "${TEST_SCENES[@]}"; do
  printf 'test: %s\n' "$scene"
  "$GODOT_BIN" --headless --path "$PROJECT_DIR" "$scene" >/tmp/firipu_test_out.log 2>&1
  # Godot headless: los tests hacen quit(0) e imprimen "<NAME>: PASS".
  # Los errores de dummy-renderer ("Parameter m is null") no son fallos de logica.
  if grep -qiE "FAIL|not found|Parse Error|SCRIPT ERROR" /tmp/firipu_test_out.log; then
    printf '  RESULT: FAIL\n\n'
    overall=1
  elif grep -qE ": PASS" /tmp/firipu_test_out.log; then
    printf '  RESULT: PASS\n\n'
  else
    printf '  RESULT: FAIL (no PASS marker — posible cuelgue/timeout)\n\n'
    overall=1
  fi
done

if [ "$overall" -eq 0 ]; then
  printf 'All Firipu Adventure tests passed.\n'
else
  printf 'Some Firipu Adventure tests FAILED.\n'
fi
exit $overall
