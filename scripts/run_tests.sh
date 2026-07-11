#!/usr/bin/env bash
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot4}"

TEST_SCENES=(
  "res://tests/save_load_test.tscn"
  "res://tests/save_version_mismatch_test.tscn"
  "res://tests/save_collectible_test.tscn"
  "res://tests/ui_save_load_test.tscn"
  "res://tests/save_medal_world_test.tscn"
  "res://tests/pause_menu_test.tscn"
  "res://tests/onboarding_test.tscn"
  "res://tests/victory_summary_test.tscn"
)

printf 'Running Firipu Adventure tests with %s\n' "$GODOT_BIN"
printf 'Project: %s\n\n' "$PROJECT_DIR"

overall=0
for scene in "${TEST_SCENES[@]}"; do
  printf '--- %s\n' "$scene"
  "$GODOT_BIN" --headless --path "$PROJECT_DIR" "$scene" >/tmp/firipu_test_out.log 2>&1
  rc=$?
  # Godot headless devuelve 0 en exito logico (tests hacen quit(0)).
  # Los errores de dummy-renderer ("Parameter m is null") no son fallos de logica.
  if grep -qiE "FAIL|not found|Parse Error|SCRIPT ERROR" /tmp/firipu_test_out.log; then
    printf '  RESULT: FAIL (rc=%s)\n' "$rc"
    overall=1
  else
    printf '  RESULT: PASS (rc=%s)\n' "$rc"
  fi
  printf '\n'
done

if [ "$overall" -eq 0 ]; then
  printf 'All Firipu Adventure tests passed.\n'
else
  printf 'Some Firipu Adventure tests FAILED.\n'
fi
exit $overall
