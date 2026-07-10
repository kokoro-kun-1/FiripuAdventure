# Firipu Adventure — Prototipo 0.1

## 1. Objetivo del prototipo

El prototipo 0.1 debe demostrar que **Firipu Adventure** funciona como plataformas **3D lineal 2.5D lateral** en **Godot 4**, con el primer mundo de la Región del Biobío, el trío principal y el ciclo básico de juego.

Este prototipo no busca ser el juego completo. Busca validar:

- Movimiento de Firipu.
- Cámara lateral 2.5D fija/semi fija.
- Exploración simple.
- Presencia funcional de Yuki y Kira.
- Registro de 4 coleccionables.
- Combate básico contra robot usando esquiva y elementos del entorno.
- Cierre del nivel con medalla regional.

---

## 2. Alcance cerrado

### Incluido en prototipo 0.1

1. Un nivel simple inspirado en la Región del Biobío.
2. Firipu jugable con controles básicos.
3. Cámara lateral 2.5D funcional.
4. Yuki y Kira siguiendo al jugador.
5. Cuatro coleccionables principales.
6. Un enemigo robot básico.
7. Objetos del entorno para golpear/desactivar robot.
8. Contador de coleccionables.
9. Medalla final del Biobío.
10. Inicio y final de nivel.

### No incluido en prototipo 0.1

- Sistema completo de las 16 regiones.
- Menú principal completo.
- Guardado/carga.
- Cinemáticas.
- Voces.
- Sistema avanzado de combate.
- Jefe completo con varias fases.
- Bicicleta de montaña temporal.
- IA avanzada de Yuki y Kira.
- Modelos finales de personajes.
- Música final.
- Optimización final para Windows/Linux/macOS.

---

## 3. Mundo del prototipo

### Región

```text
Región del Biobío
```

### Nombre del mundo

```text
Biobío Silvestre
```

### Duración objetivo

```text
5 a 15 minutos
```

Si el jugador avanza bien, el nivel no debe superar los **15 minutos**.

### Entorno mínimo

El nivel debe tener una versión simple de:

1. **Sendero de bosque**
   - Inicio del nivel.
   - Zona segura para aprender movimiento.

2. **Zona de salto**
   - Rocas, troncos o plataformas naturales.
   - Debe enseñar salto y carrera.

3. **Ribera de río**
   - Agua baja o charco.
   - Introduce el uso de agua como elemento del entorno.

4. **Humedal pequeño**
   - Lugar donde aparece al menos un coleccionable.
   - Yuki puede reaccionar cerca del coleccionable.

5. **Claro final**
   - Zona donde aparece la medalla.
   - Puede incluir el enemigo robot básico o el último obstáculo.

### Estructura lateral 2.5D

El nivel debe avanzar principalmente de **izquierda a derecha**, como un diorama jugable:

```text
Inicio bosque → arbustos/troncos → río → humedal/plataformas → robot → medalla
```

Reglas de layout:

- Eje principal: horizontal.
- Profundidad: limitada, solo para esquivar, secretos y objetos cercanos.
- Cámara: lateral con fondo decorativo en capas.
- El jugador no debe perderse ni girar libremente la cámara.

---

## 4. Personaje jugable: Firipu

### Requisitos funcionales

Firipu debe poder:

- Caminar.
- Correr.
- Saltar.
- Esquivar.
- Interactuar.
- Tomar un objeto simple del entorno.
- Lanzar o usar ese objeto contra un robot.
- Registrar coleccionables.
- Recibir la medalla final.

### Controles sugeridos iniciales

```text
Teclado WASD / Stick izquierdo Xbox: mover en franja 2.5D
A/D: avanzar o retroceder por el eje horizontal
W/S: moverse levemente en profundidad limitada
Shift / LB / LT / RT: correr
Espacio / Botón A: saltar y aceptar pantalla inicial
Ctrl / Botón B: esquivar
E / Botón X: interactuar
Click izquierdo / RB / R3: usar objeto
```

### Animaciones mínimas

Para prototipo se aceptan animaciones simples o placeholders:

- Idle.
- Caminar.
- Correr.
- Saltar.
- Esquivar.
- Tomar objeto.
- Lanzar/golpear.
- Celebración al recibir medalla.

---

## 5. Cámara lateral 2.5D

### Requisitos

La cámara debe:

- Seguir a Firipu.
- Mantener vista lateral clara para plataformas.
- Avanzar con Firipu de izquierda a derecha.
- Usar proyección ortogonal o perspectiva suave tipo diorama.
- Mostrar capas de fondo sin distraer la ruta jugable.
- Evitar movimientos bruscos.
- No permitir que el jugador pelee contra una cámara libre.

### Criterio de aceptación

El jugador debe entender siempre hacia dónde avanzar y poder moverse, saltar y esquivar sin pelear contra la cámara.

---

## 6. Compañeras: Yuki y Kira

### Yuki — Caniche toy

Rol en prototipo:

- Seguir a Firipu.
- Mantener distancia cercana.
- Reaccionar cuando hay coleccionable oculto o cercano.

Comportamiento mínimo:

- Si está lejos, corre hacia Firipu.
- Si está cerca, camina o espera.
- Si hay coleccionable cercano, mira hacia él o muestra señal visual.

### Kira — Terrier chilena

Rol en prototipo:

- Seguir a Firipu.
- Reaccionar ante robot o mecanismo simple.

Comportamiento mínimo:

- Si está lejos, corre hacia Firipu.
- Si está cerca, espera o se mueve alrededor.
- Si hay robot cercano, ladra o muestra alerta visual.

### Limitación aceptada

En prototipo 0.1, Yuki y Kira pueden usar IA simple de seguimiento. No se requiere navegación perfecta ni comandos complejos.

---

## 7. Coleccionables del Biobío

El prototipo tendrá exactamente **4 coleccionables principales**:

1. Chinita.
2. Abejorro.
3. Libélula.
4. Ranita pequeña.

### Regla de registro

Cada coleccionable debe:

- Estar ubicado en una zona diferente del nivel.
- Poder registrarse con interacción.
- Sumar al contador total.
- Mostrar un texto corto.
- Quedar marcado como registrado.

### Textos iniciales sugeridos

```text
Chinita: Pequeña visitante del bosque, ayuda a dar vida al entorno.
Abejorro: Zumbador trabajador que aparece entre flores y arbustos.
Libélula: Vuela cerca del agua limpia y los humedales.
Ranita pequeña: Vive en zonas húmedas y se esconde entre hojas.
```

### Criterio de aceptación

El jugador debe poder registrar los 4 coleccionables y ver progreso claro:

```text
Fauna registrada: 0/4 → 4/4
```

---

## 8. Enemigo robot básico

### Enemigo del prototipo

```text
Escarabajo robot explorador
```

### Comportamiento mínimo

- Patrulla en una ruta corta.
- Detecta a Firipu si se acerca demasiado.
- Avanza hacia Firipu lentamente.
- Puede empujar o causar retroceso leve.
- Puede ser esquivado.
- Puede ser aturdido con un objeto del entorno.

### Estados mínimos

```text
Patrullando
Alertado
Aturdido
Desactivado
```

### Criterio de aceptación

El jugador debe poder:

1. Ver al robot patrullar.
2. Esquivarlo.
3. Usar piedra/rama/palo/agua/tierra para aturdirlo.
4. Dejarlo desactivado o pasar sin destruirlo brutalmente.

---

## 9. Combate ambiental

### Elementos disponibles en prototipo

Usar al menos **2 elementos del entorno**:

1. Piedra pequeña.
2. Rama o palo.

Opcional si el tiempo alcanza:

3. Tierra.
4. Agua de charco o río.

### Reglas

- Los objetos se usan solo contra robots.
- No se usan contra fauna real.
- El efecto debe ser suave: aturdir, empujar, desviar o desactivar.
- No debe verse violento ni agresivo.

---

## 10. Medalla regional

### Medalla del prototipo

```text
Medalla del Bosque y Río del Biobío
```

### Condición para obtenerla

El jugador debe:

1. Registrar los 4 coleccionables.
2. Llegar al claro final.
3. Superar al Escarabajo robot explorador, esquivándolo o desactivándolo.

### Resultado

Al obtener la medalla:

- Se muestra mensaje de final de nivel.
- Firipu celebra.
- Yuki y Kira celebran.
- Se considera terminado el prototipo 0.1.

Texto sugerido:

```text
¡Medalla del Bosque y Río del Biobío conseguida!
```

---

## 11. HUD mínimo

El prototipo necesita un HUD simple:

```text
Fauna registrada: 0/4
Objeto en mano: Ninguno / Piedra / Rama
Medalla: Pendiente / Conseguida
```

Opcional:

- Indicador de vida o ánimo.
- Señal de alerta cuando robot detecta al jugador.
- Señal visual cuando Yuki encuentra algo.
- Señal visual cuando Kira detecta peligro.

---

## 12. Estructura técnica sugerida en Godot

```text
FiripuAdventure/
├── project.godot
├── scenes/
│   ├── levels/
│   │   └── level_biobio_prototype.tscn
│   ├── player/
│   │   └── firipu.tscn
│   ├── companions/
│   │   ├── yuki.tscn
│   │   └── kira.tscn
│   ├── collectibles/
│   │   ├── collectible_base.tscn
│   │   ├── chinita.tscn
│   │   ├── abejorro.tscn
│   │   ├── libelula.tscn
│   │   └── ranita_pequena.tscn
│   ├── enemies/
│   │   └── escarabajo_robot.tscn
│   ├── items/
│   │   ├── piedra.tscn
│   │   └── rama.tscn
│   └── ui/
│       └── hud.tscn
├── scripts/
│   ├── player/
│   │   └── firipu_controller.gd
│   ├── companions/
│   │   └── companion_follow.gd
│   ├── collectibles/
│   │   └── collectible.gd
│   ├── enemies/
│   │   └── robot_enemy.gd
│   ├── items/
│   │   └── throwable_item.gd
│   └── ui/
│       └── hud.gd
├── data/
│   └── regiones.json
└── specs/
    └── prototipo_0_1.md
```

---

## 13. Datos usados por el prototipo

El prototipo debe leer o estar alineado con:

```text
/home/ubuntu/FiripuAdventure/data/regiones.json
```

Valores relevantes:

```text
id: biobio
world_name: Biobío Silvestre
collectibles_per_region: 4
target_minutes_per_world: 15
medal: Medalla del Bosque y Río del Biobío
```

---

## 14. Criterios de aceptación finales

El prototipo 0.1 se considera completo si:

1. Abre una escena jugable en Godot 4.
2. Firipu puede caminar, correr, saltar y esquivar.
3. La cámara lateral sigue correctamente al jugador.
4. Yuki y Kira siguen a Firipu.
5. Hay 4 coleccionables registrables.
6. El contador llega de 0/4 a 4/4.
7. Existe al menos un Escarabajo robot explorador.
8. El robot puede ser esquivado o aturdido con objeto ambiental.
9. El jugador puede obtener la Medalla del Bosque y Río del Biobío.
10. El recorrido completo se puede terminar en menos de 15 minutos.
11. El tono se mantiene familiar, chileno, natural y no violento contra fauna real.

---

## 15. Orden de implementación recomendado

1. Crear proyecto Godot 4 vacío.
2. Crear escena del nivel Biobío con placeholders.
3. Implementar controlador de Firipu.
4. Implementar cámara lateral 2.5D.
5. Implementar HUD básico.
6. Implementar coleccionables y contador.
7. Implementar Yuki y Kira con seguimiento simple.
8. Implementar Escarabajo robot explorador.
9. Implementar objetos ambientales: piedra y rama.
10. Implementar condición de medalla.
11. Probar recorrido completo.
12. Ajustar duración para que no supere 15 minutos.

---

## 16. Estado implementado actual

Ya existe una primera vertical slice técnica con:

- Control 2.5D lateral con suavizado, salto con tolerancia, esquiva, límite de profundidad y soporte para mando Xbox/XInput.
- Cámara lateral ortogonal con seguimiento suave, zona muerta y límites horizontales.
- HUD con Diario de Naturaleza, objeto equipado, estado de medalla, estado de Firipu, mensajes de ayuda, instrucciones de control y panel de victoria.
- Pantalla inicial con título, objetivo del nivel y comienzo con Enter o botón A del mando Xbox.
- Flujo de mundo iniciado: `FLOW_START Mundo 1 Biobío`.
- Flujo de jugabilidad iniciado: `FLOW_GAMEPLAY_START Mundo 1 Biobío` al presionar Enter.
- Flujo de victoria: `FLOW_VICTORY Mundo 1 Biobío` al obtener la medalla.
- Pantalla de victoria con resumen de fauna registrada, objeto final y medalla obtenida.
- Smoke test automatizado para validar pantalla inicial, cámara, profundidad 2.5D, 4 coleccionables, objeto, robot, medalla y panel de victoria.

Presentación visual actualizada: Firipu ya tiene silueta infantil con cabeza grande, gorro, mochila, brazos, piernas y zapatillas; Yuki se lee como perrita pequeña/esponjosa con hocico, nariz, pompón y collar; Kira se lee como terrier más alerta con hocico, orejas levantadas, patas y pañuelo; el robot tiene forma de escarabajo mecánico; los coleccionables tienen halo/alas; el Biobío incluye más árboles, flores, juncos, espuma de río, rocas y nubes como arte inicial.

Guía visual creada en `specs/guia_visual_personajes.md` para mantener consistencia antes de pasar a modelos 3D definitivos.

Animaciones placeholder agregadas: Firipu mueve brazos/piernas/cabeza/mochila en idle, caminar/correr, salto, caída y esquiva; Yuki tiene bob, cola y olfateo; Kira tiene bob, cola, orejas y alerta frente al sector del robot; el robot escarabajo anima patrulla, alerta, aturdido y desactivado.

Siguiente foco: exportar una build Windows actualizada para que Manuel pruebe la pantalla inicial, las instrucciones y el cierre de victoria en su PC; cuando envíe referencias visuales de Firipu, Yuki y Kira, adaptar la guía visual y los modelos a esos diseños.

---

## 17. Decisiones pendientes para prototipo 0.2

- Bicicleta de montaña temporal.
- Jefe completo con fases.
- Diario de Naturaleza visual.
- Modelos 3D originales.
- Animaciones más pulidas.
- Música y ambiente sonoro.
- Exportación Windows/Linux/macOS.
- Segunda región: Ñuble.
