# Firipu Adventure — Handoff para Hermes Notebook Windows

Fecha de recopilación: 2026-07-10
Origen: Oracle `/home/ubuntu/FiripuAdventure`
Destino previsto: Hermes Agent en notebook Windows

## 1. Resumen ejecutivo

Firipu Adventure es un prototipo en Godot 4 de un juego familiar chileno, estilo plataformas 3D lineal 2.5D lateral. El protagonista es Firipu, un niño de 5 a 6 años que explora regiones de Chile junto a dos perritas: Yuki y Kira. El primer mundo implementado/prototipado es la Región del Biobío: `Biobío Silvestre`.

Estado actual importante:

- Repositorio local: `/home/ubuntu/FiripuAdventure`
- Remoto GitHub configurado: `https://github.com/kokoro-kun-1/FiripuAdventure.git`
- Rama local: `master`
- Estado Git al recopilar: `master...origin/master [ahead 1]`
- Último commit local: `55f02b5 update: various fixes and audio manager`
- Advertencia crítica: el último estado local tiene errores de parseo GDScript; los tests no pasan. Antes de continuar diseño o features, arreglar compilación.

## 2. Identidad del proyecto

- Nombre de proyecto: `Firipu Adventure`
- En `project.godot` aparece actualmente como `Firipu Adventur` sin la letra final `e`; revisar si se debe corregir.
- Motor: Godot 4.
- Configuración detectada: Godot `4.2` en features, pero las pruebas locales corrieron con `Godot Engine v4.7.stable.official.5b4e0cb0f`.
- Escena principal: `res://scenes/levels/level_biobio_prototype.tscn`
- Estilo: 3D cartoon low-poly suave, familiar, colorido, tierno, legible desde cámara lateral 2.5D.
- Género: plataformas 3D lineal 2.5D lateral, aventura, exploración y registro de naturaleza.
- Tono: familiar, chileno, educativo suave, no violento con fauna real.

## 3. Reglas de diseño principales

1. Cada región de Chile es un mundo jugable.
2. Progresión lineal.
3. Cada mundo debe durar máximo 15 minutos si el jugador avanza bien.
4. Cada región tiene exactamente 4 coleccionables principales.
5. Los coleccionables son fauna local pequeña, insectos, arácnidos, anfibios/reptiles pequeños o registros naturales.
6. La fauna real no es enemiga: se observa, registra, rescata o protege.
7. Los enemigos son fauna robot espacial, no animales reales.
8. Combate no violento: esquivar y usar elementos del entorno para aturdir, empujar, desviar o desactivar robots.
9. Elementos permitidos del entorno: palos, piedras, ramas, tierra, agua.
10. Las perritas no son decorativas: Yuki detecta secretos/fauna y Kira apoya ante mecanismos/robots.

## 4. Personajes principales

### Firipu

- Niño protagonista jugable.
- Edad: 5 a 6 años.
- Personalidad: alegre, aventurero, valiente, protector con animales, curioso, inocente.
- Apariencia base: niño pequeño, cabeza levemente grande, ojos grandes, pelo algo despeinado, ropa cómoda de exploración, mochila pequeña, zapatillas.
- Guía visual actual: polera azul intensa, short azul oscuro, gorro/jockey rojo, mochila amarilla/naranja, zapatillas claras.
- Habilidades base:
  - caminar
  - correr
  - saltar
  - esquivar
  - interactuar
  - tomar/usar objetos del entorno
  - registrar fauna en Diario de Naturaleza
  - recibir medalla final
- Poder temporal futuro: bicicleta de montaña temporal.

### Yuki

- Caniche toy.
- Rol: compañera de exploración, detección y búsqueda de secretos.
- Personalidad: tierna, inteligente, curiosa, delicada pero valiente.
- Apariencia: pequeña, pelaje claro blanco/crema/beige, esponjosa, collar rosado/celeste.
- Habilidades:
  - olfato de secretos
  - rastro brillante
  - alerta natural cuando hay entrada del Diario
  - búsqueda en espacios pequeños
- En prototipo: seguimiento simple y reacción cercana a coleccionables.

### Kira

- Terrier chilena.
- Rol: compañera valiente, energética, protectora, apoyo ante robots y obstáculos.
- Personalidad: valiente, juguetona, protectora, inquieta, leal, impulsiva.
- Apariencia: cuerpo ágil, pelaje corto café/crema o manchas, orejas atentas, pañuelo verde/rojo.
- Habilidades:
  - activar mecanismos bajos
  - aturdir o distraer robots menores con ladrido
  - empujar objetos livianos
  - distracción no violenta ante enemigos
- En prototipo: seguimiento simple y reacción ante robot.

## 5. Mundo 01: Biobío Silvestre

- Región base: Región del Biobío, Chile.
- Tipo: mundo inicial / tutorial ampliado.
- Ruta base:
  `Entrada del bosque → arbustos/troncos → ribera de río → humedal/plataformas → escarabajo robot → medalla`
- Entorno: bosque nativo, riberas de río, humedales y cerros verdes.
- Objetivo narrativo: ayudar a la fauna local y liberar el bosque inicial de la invasión robótica espacial.
- Objetivo jugable: ruta de plataformas, coleccionables, uso de perritas, primer enemigo/robot y medalla.

### Coleccionables del Biobío

Exactamente 4:

1. Chinita.
2. Abejorro.
3. Libélula.
4. Ranita pequeña.

Textos iniciales:

- Chinita: Pequeña visitante del bosque, ayuda a dar vida al entorno.
- Abejorro: Zumbador trabajador que aparece entre flores y arbustos.
- Libélula: Vuela cerca del agua limpia y los humedales.
- Ranita pequeña: Vive en zonas húmedas y se esconde entre hojas.

### Enemigo/jefe Biobío

- Enemigo básico: Escarabajo robot explorador.
- Jefe sugerido: Gran Escarabajo Cósmico del Biobío.
- Concepto: escarabajo robot espacial averiado, no malvado por naturaleza; debe ser desactivado de forma no violenta.
- Medalla: Medalla del Bosque y Río del Biobío.

## 6. Matriz de regiones

Archivo de datos validado: `data/regiones.json`

Validación realizada:

- JSON parsea correctamente.
- Proyecto: Firipu Adventure.
- Motor: Godot 4.
- Progresión: linear.
- Duración objetivo por mundo: 15 minutos.
- Coleccionables por región: 4.
- Cantidad de regiones: 16.
- Todas las regiones tienen 4 coleccionables.

Orden actual de regiones en `data/regiones.json`:

1. Biobío — `Biobío Silvestre`
2. Ñuble — `Montañas de Ñuble`
3. La Araucanía — `Araucarias del Volcán`
4. Los Ríos — `Selva Lluviosa de Los Ríos`
5. Los Lagos — `Lagos, Volcanes e Islas`
6. Aysén — `Viento Patagónico de Aysén`
7. Magallanes y la Antártica Chilena — `Hielo Austral de Magallanes`
8. Maule — `Ríos y Robles del Maule`
9. O'Higgins — `Quebradas de O'Higgins`
10. Metropolitana — `Cerros de la Capital Natural`
11. Valparaíso — revisar en JSON/specs
12. Coquimbo — revisar en JSON/specs
13. Atacama — revisar en JSON/specs
14. Antofagasta — revisar en JSON/specs
15. Tarapacá — revisar en JSON/specs
16. Arica y Parinacota — revisar en JSON/specs

Nota: la progresión del JSON comienza en Biobío y luego avanza por sur/centro/norte; esto respeta la memoria de proyecto: Chile lineal desde Biobío.

## 7. Estructura importante del repositorio

```text
FiripuAdventure/
├── project.godot
├── export_presets.cfg
├── autoload/
│   ├── SaveGame.gd
│   └── AudioManager.gd
├── data/
│   └── regiones.json
├── specs/
│   ├── guia_visual_personajes.md
│   ├── jugabilidad_regiones_chile.md
│   ├── mundo_01_biobio.md
│   ├── personajes_principales.md
│   └── prototipo_0_1.md
├── scenes/
│   ├── collectibles/collectible_base.tscn
│   ├── companions/kira.tscn
│   ├── companions/yuki.tscn
│   ├── enemies/escarabajo_robot.tscn
│   ├── items/piedra.tscn
│   ├── items/rama.tscn
│   ├── levels/level_biobio_prototype.tscn
│   ├── player/firipu.tscn
│   └── ui/hud.tscn
├── scripts/
│   ├── run_tests.sh
│   ├── camera/side_camera_follow.gd
│   ├── collectibles/collectible.gd
│   ├── companions/companion_follow.gd
│   ├── enemies/robot_enemy.gd
│   ├── items/throwable_item.gd
│   ├── levels/level_biobio_prototype.gd
│   ├── player/firipu_controller.gd
│   └── ui/hud.gd
└── tests/
    ├── smoke_prototype.gd
    ├── save_load_test.gd/.tscn
    ├── save_version_mismatch_test.gd/.tscn
    ├── save_collectible_test.gd/.tscn
    ├── save_medal_world_test.gd/.tscn
    ├── pause_menu_test.gd/.tscn
    ├── onboarding_test.gd/.tscn
    ├── ui_save_load_test.gd/.tscn
    └── victory_summary_test.gd/.tscn
```

También existen builds/exportaciones locales:

- `dist/FiripuAdventure_windows_x86_64.zip`
- `builds/windows_x86_64/FiripuAdventure.exe`
- `dist/FiripuAdventure_linux_arm64.tar.gz`
- `builds/linux_arm64/FiripuAdventure.arm64`

## 8. Estado funcional y problemas actuales

Comando ejecutado:

```bash
cd /home/ubuntu/FiripuAdventure && bash scripts/run_tests.sh
```

Resultado: falla en el primer test `save_load_test.tscn` por errores de parseo.

Errores principales reportados:

1. `res://autoload/SaveGame.gd:37`
   - `Parse Error: Expected closing ")" after call arguments.`
   - El autoload SaveGame no carga.

2. `res://autoload/AudioManager.gd:51`
   - `Parse Error: Closing ")" doesn't have an opening counterpart.`
   - El autoload AudioManager no carga.

3. `res://scripts/player/firipu_controller.gd:12`
   - `Parse Error: Unexpected identifier "_footstep_timer" in class body.`

4. `res://scripts/ui/hud.gd`
   - Varias funciones/identificadores no declarados:
     - `_on_victory_continue_button_pressed`
     - `_on_victory_save_button_pressed`
     - `_on_victory_exit_button_pressed`
     - `_on_collected_changed`
     - `_on_object_changed`
     - `_on_medal_state_changed`
     - `_on_movement_state_changed`
     - `_reset_exit_confirmations()`
     - `audio`

5. Consecuencia:
   - `SaveGame autoload not found`.
   - El nivel carga parcialmente, pero los tests fallan.

Primera tarea recomendada para el Hermes de Windows:

1. Abrir el proyecto en Godot o ejecutar tests headless.
2. Corregir primero parse errors, no agregar features nuevas todavía.
3. Ejecutar `scripts/run_tests.sh` hasta que todos los tests pasen.
4. Luego recién continuar con gameplay/pulido.

## 9. Comandos útiles para el Hermes de Windows

Si trabaja desde GitHub:

```bash
git clone https://github.com/kokoro-kun-1/FiripuAdventure.git
cd FiripuAdventure
git status
```

Importante: al momento de esta recopilación, Oracle está `ahead 1` respecto de `origin/master`. Si ese commit no se sube, el notebook no verá los últimos cambios. Pedir al usuario autorización para hacer push o copiar el proyecto completo.

Para probar en Linux/WSL:

```bash
bash scripts/run_tests.sh
```

Para probar manualmente con Godot:

```bash
godot4 --path .
```

Para test individual:

```bash
godot4 --headless --path . res://tests/save_load_test.tscn
```

En Windows, ajustar binario de Godot si no existe `godot4` en PATH. Ejemplo conceptual:

```powershell
$env:GODOT_BIN="C:\ruta\a\Godot_v4.x.exe"
bash scripts/run_tests.sh
```

O ejecutar escenas de test desde el editor.

## 10. Prioridad de continuación

Orden recomendado:

1. Sincronizar código más reciente:
   - Push desde Oracle, o transferir carpeta completa al notebook.
2. Arreglar errores de parseo en:
   - `autoload/SaveGame.gd`
   - `autoload/AudioManager.gd`
   - `scripts/player/firipu_controller.gd`
   - `scripts/ui/hud.gd`
3. Ejecutar tests completos.
4. Corregir nombre del proyecto si corresponde: `Firipu Adventur` → `Firipu Adventure`.
5. Revisar que el guardado/carga sea estable con `SAVE_VERSION := 1`.
6. Validar HUD, pausa, onboarding y resumen de victoria.
7. Pulir prototipo Biobío.
8. Luego avanzar a contenido de regiones o personajes.

## 11. Documentos fuente que debe leer el agente Windows

Leer en este orden:

1. `HANDOFF_HERMES_WINDOWS.md` — este documento.
2. `specs/prototipo_0_1.md` — alcance del prototipo.
3. `specs/personajes_principales.md` — Firipu, Yuki, Kira.
4. `specs/mundo_01_biobio.md` — diseño del primer mundo.
5. `specs/guia_visual_personajes.md` — guía visual.
6. `specs/jugabilidad_regiones_chile.md` — matriz de todas las regiones.
7. `data/regiones.json` — datos estructurados para implementación.

## 12. Reglas para el agente que continúe

- Responder en español formal y directo.
- Trabajar paso a paso, evitando bucles.
- No crear features encima de un proyecto que no compila.
- Priorizar pruebas reales de Godot.
- No tratar fauna real como enemigo.
- Mantener el tono familiar/chileno.
- Usar TDD o pruebas de escena existentes antes de grandes cambios.
- No pedir tokens de GitHub; el usuario maneja autenticación local.
- Si hay cambios locales no subidos, aclarar si son locales-only y pedir/ejecutar autorización de push cuando corresponda.

## 13. Resumen corto para pegar a otro Hermes

Estoy continuando Firipu Adventure, un prototipo Godot 4 de plataformas 3D lineal 2.5D lateral. Protagonista: Firipu, niño chileno de 5–6 años; compañeras: Yuki, caniche toy detectora de secretos/fauna, y Kira, terrier chilena valiente ante mecanismos/robots. Primer mundo: Biobío Silvestre, ruta lateral tipo diorama, 4 coleccionables exactos: Chinita, Abejorro, Libélula, Ranita pequeña. Cada región de Chile es un mundo lineal de máximo 15 minutos, 4 coleccionables, enemigos solo robots espaciales, fauna real se registra/protege. Repo: https://github.com/kokoro-kun-1/FiripuAdventure.git. En Oracle `/home/ubuntu/FiripuAdventure` está `master` ahead 1 con commit `55f02b5`; si no se hizo push, copiar/push antes. Estado actual: tests fallan por parse errors en `autoload/SaveGame.gd`, `autoload/AudioManager.gd`, `scripts/player/firipu_controller.gd` y `scripts/ui/hud.gd`. Primera tarea: arreglar compilación y correr `bash scripts/run_tests.sh` hasta pasar.
