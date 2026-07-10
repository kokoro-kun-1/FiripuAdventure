#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot4}"

TEST_SCENES=(
  "res://tests/save_load_test.tscn"
  "res://tests/save_version_mismatch_test.tscn"
  "res://tests/save_collectible_test.tscn"
  "res://tests/ui_save_load_test.tscn"
  "res://tests/save_medal_world_test.tscn"
)

printf 'Running Firipu Adventure tests with %s\n' "$GODOT_BIN"
printf 'Project: %s\n\n' "$PROJECT_DIR"

for scene in "${TEST_SCENES[@]}"; do
  printf '%s\n' "--- $scene"
  "$GODOT_BIN" --headless --path "$PROJECT_DIR" "$scene"
  printf '\n'
done

printf 'All Firipu Adventure tests passed.\n'
