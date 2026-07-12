#!/usr/bin/env bash
# build_all.sh — Exporta todos los presets de export_presets.cfg con Godot 4.2.2
# Uso: ./build_all.sh            (release)
#      ./build_all.sh debug      (build de debug)
#
# Requiere Git Bash / MSYS en Windows. El binario de Godot se invoca con
# rutas nativas de Windows (cygpath -m) porque no acepta rutas MSYS (/c/...).
#
# NOTA: bajo MSYS headless el .exe de Godot a veces cierra "sucio" y devuelve
# exit 1 sin mensaje (deja un .tmp sin renombrar). Por eso NO fiamos del exit
# code: validamos que el binario final exista y no quede como .tmp. Además
# matamos el proceso de Godot entre presets (igual que scripts/run_tests.sh)
# para evitar procesos zombi que saturan el dummy-renderer.

set -uo pipefail

# --- Rutas (nativas Windows para el .exe de Godot) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cygpath -m "$SCRIPT_DIR")"
GODOT_EXE="C:/Users/manue/Godot/Godot_v4.2.2-stable_win64.exe"

# Modo de export: release por defecto, debug si se pasa argumento
if [ "${1:-}" = "debug" ]; then
  EXPORT_MODE="--export-debug"
  MODE_LABEL="DEBUG"
else
  EXPORT_MODE="--export-release"
  MODE_LABEL="RELEASE"
fi

# Presets runnable definidos en export_presets.cfg (debe coincidir con el archivo)
PRESETS=(
  "Linux ARM64"
  "Windows x86_64"
  "Linux x86_64"
  "macOS"
)

# Mata cualquier instancia previa de Godot (evita zombis bajo MSYS headless)
_kill_godot() {
  if command -v taskkill >/dev/null 2>&1; then
    taskkill /F /IM "Godot_v4.2.2-stable_win64.exe" >/dev/null 2>&1 || true
  else
    pkill -9 -f "Godot.*--headless" >/dev/null 2>&1 || true
  fi
  # El .tmp residual de un export que no renombró hay que limpiarlo
  sleep 1
}

echo "=========================================================="
echo " Firipu Adventure — Build $MODE_LABEL"
echo " Godot : $GODOT_EXE"
echo " Proyecto: $PROJECT_DIR"
echo "=========================================================="

if [ ! -f "$GODOT_EXE" ]; then
  echo "ERROR: no encontre Godot en $GODOT_EXE" >&2
  exit 1
fi

if [ ! -f "$SCRIPT_DIR/export_presets.cfg" ]; then
  echo "ERROR: falta export_presets.cfg en $SCRIPT_DIR" >&2
  exit 1
fi

_kill_godot

FAIL=0
for p in "${PRESETS[@]}"; do
  echo ""
  echo ">> Exportando preset: $p"
  # Sin ruta final: usa export_path del preset (relativo al proyecto)
  "$GODOT_EXE" --headless --quiet "$EXPORT_MODE" "$p" >/tmp/firipu_build_out.log 2>&1 &
  godot_pid=$!
  wait "$godot_pid" 2>/dev/null || true
  # Bajo MSYS el exit suele ser 1 aunque haya escrito el binario; matamos y
  # validamos por el archivo de salida real (no confiamos en el exit code).
  _kill_godot

  # Determinamos la ruta de salida esperada desde el export_path del preset
  out_rel="$(grep -A12 "^\[preset\." "$SCRIPT_DIR/export_presets.cfg" \
              | awk -v RS="\n\n" -v preset="$p" '
                  $0 ~ "name=\""preset"\"" {
                    for (i=1;i<=NF;i++) if ($i ~ /^export_path=/) {
                      gsub(/export_path="/,"",$i); gsub(/"$/,"",$i); print $i
                    }
                  }')"
  if [ -z "$out_rel" ]; then
    echo "   FALLO: no pude leer export_path para '$p'" >&2
    FAIL=1
    continue
  fi
  out_file="$SCRIPT_DIR/$out_rel"
  # Si quedo un .tmp sin renombrar, lo consideramos fallo de cierre sucio
  tmp_file="${out_file%.*}.tmp"
  if [ -f "$tmp_file" ] && [ ! -f "$out_file" ]; then
    echo "   FALLO: Godot dejo .tmp sin renombrar (cierre sucio bajo MSYS)" >&2
    FAIL=1
    continue
  fi
  if [ -f "$out_file" ]; then
    echo "   OK: $p  ->  $out_file ($(wc -c < "$out_file") bytes)"
  else
    echo "   FALLO: no se genero $out_file" >&2
    echo "   (log: $(tail -n 3 /tmp/firipu_build_out.log | tr '\n' ' '))" >&2
    FAIL=1
  fi
done

echo ""
echo "=========================================================="
if [ "$FAIL" -eq 0 ]; then
  echo " Build $MODE_LABEL completado. Salidas en $PROJECT_DIR/builds/"
else
  echo " Build $MODE_LABEL TERMINO CON ERRORES." >&2
fi
echo "=========================================================="

exit $FAIL
