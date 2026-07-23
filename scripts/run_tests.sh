#!/usr/bin/env bash
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && { pwd -W 2>/dev/null || pwd; })"

# Auto-detect Godot binary on Windows if not explicitly set
if [ -z "${GODOT_BIN:-}" ]; then
    if command -v cygpath >/dev/null 2>&1; then
        # Windows (git-bash/MSYS) - try common install locations
        # Get username from HOME path since $USER may be unbound
        _home_user="$(basename "$HOME" 2>/dev/null || echo "$USERNAME")"
        for candidate in \
            "C:/Program Files/Godot/Godot_v4.2.2-stable_win64.exe" \
            "C:/Program Files/Godot/Godot_v4.3-stable_win64.exe" \
            "C:/Users/$_home_user/Godot/Godot_v4.2.2-stable_win64.exe" \
            "C:/Users/$_home_user/Godot/Godot_v4.3-stable_win64.exe" \
            "/c/Program Files/Godot/Godot_v4.2.2-stable_win64.exe" \
            "/c/Program Files/Godot/Godot_v4.3-stable_win64.exe" \
            "/c/Users/$_home_user/Godot/Godot_v4.2.2-stable_win64.exe" \
            "/c/Users/$_home_user/Godot/Godot_v4.3-stable_win64.exe"; do
            if [ -f "$candidate" ]; then
                GODOT_BIN="$candidate"
                break
            fi
        done
        # Fallback to godot4 if in PATH
        GODOT_BIN="${GODOT_BIN:-godot4}"
    else
        # Linux/Mac - use godot4 from PATH
        GODOT_BIN="${GODOT_BIN:-godot4}"
    fi
fi

# En Windows (git-bash/MSYS) el binario nativo de Godot no acepta rutas
# estilo /c/Users/...; hay que convertirlas a C:\\Users\\... con cygpath.
if command -v cygpath >/dev/null 2>&1; then
  PROJECT_DIR="$(cygpath -m "$PROJECT_DIR")"
fi

TEST_SCENES=(
  "res://tests/biobio_structure_test.tscn"
  "res://tests/main_menu_flow_test.tscn"
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
  "res://tests/nuble_test.tscn"
  "res://tests/araucania_test.tscn"
  "res://tests/los_rios_test.tscn"
  "res://tests/los_lagos_test.tscn"
  "res://tests/aysen_test.tscn"
  "res://tests/magallanes_test.tscn"
  "res://tests/maule_test.tscn"
  "res://tests/ohiggins_test.tscn"
  "res://tests/metropolitana_test.tscn"
  "res://tests/valparaiso_test.tscn"
  "res://tests/coquimbo_test.tscn"
  "res://tests/atacama_test.tscn"
  "res://tests/antofagasta_test.tscn"
  "res://tests/tarapaca_test.tscn"
  "res://tests/arica_test.tscn"
)

printf 'Running Firipu Adventure tests with %s\n' "$GODOT_BIN"
printf 'Project: %s\n\n' "$PROJECT_DIR"

# En Windows, Godot headless bajo MSYS a veces queda como proceso zombi
# (el dummy-renderer se cuelga). Acumular procesos colgados satura recursos
# y los tests subsiguientes hacen timeout ("no PASS marker"). Matamos cualquier
# instancia previa antes de arrancar la suite y entre cada test.
_kill_godot() {
  if command -v taskkill >/dev/null 2>&1; then
    taskkill /F /IM "Godot_v4.2.2-stable_win64.exe" >/dev/null 2>&1 || true
    taskkill /F /IM "Godot_v4.3-stable_win64.exe" >/dev/null 2>&1 || true
  else
    pkill -9 -f "Godot.*--headless" >/dev/null 2>&1 || true
  fi
}

_kill_godot
sleep 1

overall=0
for scene in "${TEST_SCENES[@]}"; do
  printf 'test: %s\n' "$scene"
  # Cada escena debe terminar por sí sola; el timeout evita que un test
  # defectuoso congele toda la suite.
  timeout 90 "$GODOT_BIN" --headless --path "$PROJECT_DIR" "$scene" >/tmp/firipu_test_out.log 2>&1
  test_rc=$?
  # Godot headless: los tests hacen quit(0) e imprimen "<NAME>: PASS".
  # Los errores de dummy-renderer ("Parameter m is null") no son fallos de logica.
  if [ "$test_rc" -eq 124 ]; then
    printf '  RESULT: FAIL (timeout)\n\n'
    overall=1
  elif grep -qiE "FAIL|not found|Parse Error|SCRIPT ERROR" /tmp/firipu_test_out.log; then
    printf '  RESULT: FAIL\n\n'
    overall=1
  elif grep -qE ": PASS" /tmp/firipu_test_out.log; then
    printf '  RESULT: PASS\n\n'
  else
    # Sin marcador: en Windows headless el dummy-renderer a veces no alcanza a
    # volcar ": PASS" antes del quit(). Reintentamos una vez para absorber el
    # flaky del entorno (un fallo real con FAIL/Parse Error NO llega aqui).
    _kill_godot
    sleep 1
    timeout 90 "$GODOT_BIN" --headless --path "$PROJECT_DIR" "$scene" >/tmp/firipu_test_out.log 2>&1
    retry_rc=$?
    if [ "$retry_rc" -ne 124 ] && grep -qE ": PASS" /tmp/firipu_test_out.log; then
      printf '  RESULT: PASS (retry)\n\n'
    else
      printf '  RESULT: FAIL (no PASS marker tras reintento — posible cuelgue/timeout)\n\n'
      overall=1
    fi
  fi
  _kill_godot
  sleep 1
done

if [ "$overall" -eq 0 ]; then
  printf 'All Firipu Adventure tests passed.\n'
else
  printf 'Some Firipu Adventure tests FAILED.\n'
fi
exit $overall
