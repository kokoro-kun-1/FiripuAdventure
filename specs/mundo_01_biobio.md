# Firipu Adventure — Spec Kit Mundo 01: Región del Biobío

## 1. Resumen

**Nombre del mundo:** Biobío Silvestre  
**Región base:** Región del Biobío, Chile  
**Tipo de nivel:** Mundo inicial / tutorial ampliado  
**Motor:** Godot 4  
**Género:** plataformas 3D lineal 2.5D lateral, aventura y exploración  
**Tono:** colorido, natural, chileno, tierno, aventurero  

El primer mundo presenta al niño protagonista y sus dos perritas en un entorno silvestre inspirado en bosques, riberas, humedales y cerros de la Región del Biobío. El jugador aprende a moverse, saltar, explorar, encontrar fauna pequeña e insectos locales y enfrentar las primeras criaturas de fauna robot espacial.

El nivel se construye como un **diorama lateral 2.5D**, con avance principal de izquierda a derecha y profundidad limitada para esquivar, secretos y objetos del entorno.

Ruta base:

```text
Entrada del bosque → arbustos/troncos → ribera de río → humedal/plataformas → escarabajo robot → medalla
```

---

## 2. Objetivo principal del mundo

El jugador debe explorar el entorno del Biobío, registrar fauna local en su Diario de Naturaleza y desactivar la primera presencia de fauna robot espacial que está alterando el equilibrio del lugar.

**Objetivo narrativo:**  
Ayudar a la fauna local del Biobío y liberar el bosque inicial de la invasión robótica espacial.

**Objetivo jugable:**  
Completar una ruta principal de plataformas, encontrar coleccionables, aprender el uso de las perritas y vencer un jefe inicial.

---

## 3. Personajes activos

### Niño protagonista

**Edad aproximada:** 5 a 6 años  
**Rol:** personaje principal jugable  
**Personalidad:** curioso, alegre, inocente, valiente y explorador  

**Acciones base:**

- Caminar
- Correr
- Saltar
- Doble salto simple o salto impulsado
- Agacharse
- Interactuar
- Registrar fauna/insectos
- Lanzar objeto suave/no letal contra enemigos robóticos

### Perrita 1: Caniche toy

**Rol:** exploración y detección  
**Personalidad:** tierna, curiosa, inteligente  

**Mecánicas:**

- Detecta insectos escondidos.
- Marca lugares con fauna pequeña cercana.
- Encuentra caminos secretos.
- Emite una señal visual cuando hay coleccionables cerca.

### Perrita 2: Terrier chilena

**Rol:** apoyo, valentía y activación de mecanismos  
**Personalidad:** energética, protectora, atrevida  

**Mecánicas:**

- Activa palancas o botones bajos.
- Ahuyenta robots pequeños.
- Rompe cajas ligeras o bloqueos simples.
- Ayuda en combates contra enemigos robóticos menores.

---

## 4. Entorno visual

### Biomas del nivel

1. **Sendero de bosque nativo**
   - Árboles verdes, helechos, musgo, troncos caídos.
   - Zona tutorial de movimiento y cámara.

2. **Ribera de río**
   - Piedras, agua baja, pequeñas cascadas.
   - Plataformas sobre rocas y troncos.

3. **Humedal pequeño**
   - Juncos, charcos, libélulas, ranas pequeñas.
   - Zona de coleccionables y caminos ocultos.

4. **Cerro mirador**
   - Ruta ascendente con plataformas naturales.
   - Vista panorámica del mundo.

5. **Claro del jefe**
   - Zona circular con restos de tecnología espacial.
   - Arena de combate contra el primer jefe robot.

### Paleta de color

- Verde bosque
- Azul río
- Café tierra
- Gris piedra
- Naranjo/cobre para tecnología robótica
- Luz cálida de tarde para tono familiar

---

## 5. Coleccionables del mundo

Los coleccionables no deben sentirse como captura dañina. Se recomienda tratarlos como **registro, rescate o fotografía mágica** para un Diario de Naturaleza.

### Coleccionables principales: fauna pequeña e insectos

Cada región tendrá **4 coleccionables principales**. Para el Mundo 01 Biobío se usará una selección reducida y clara, pensada para no superar 15 minutos de juego si el jugador avanza bien.

### Coleccionables definitivos iniciales del Biobío

1. Chinita.
2. Abejorro.
3. Libélula.
4. Ranita pequeña.

### Banco secundario opcional del Biobío

Estos pueden quedar como decoración, entradas futuras del Diario o variantes reciclables:

- Mariposa local.
- Escarabajo.
- Caracol.
- Lagartija pequeña.
- Saltamontes.
- Hormiga exploradora.

### Objeto de progreso

**Nombre sugerido:** Medalla del Bosque y Río del Biobío  
**Uso:** se obtiene al liberar el mundo y permite desbloquear la siguiente región.

### Sistema de registro

Cada fauna/insecto registrado agrega una entrada al Diario de Naturaleza:

- Nombre común
- Región donde aparece
- Hábitat
- Curiosidad breve
- Ilustración 3D/ícono

---

## 6. Enemigos: fauna robot espacial

Los enemigos son versiones robóticas y espaciales inspiradas en fauna, evitando presentar animales reales como enemigos.

### Enemigos menores

1. **Escarabajo Robot Explorador**
   - Camina en línea recta.
   - Enseña al jugador a saltar sobre enemigos o esquivarlos.

2. **Araña Mecánica Alienígena**
   - Se mueve lateralmente.
   - Patrulla troncos y zonas estrechas.

3. **Avispa Metálica**
   - Enemigo volador simple.
   - Baja y sube en patrón vertical.

4. **Rana Robot Saltarina**
   - Salta en intervalos.
   - Enseña timing de esquiva.

5. **Dron Zorro Vigía**
   - Pequeño robot terrestre con luz de búsqueda.
   - Si detecta al jugador, llama a robots menores.

---

## 7. Jefe del mundo

### Nombre sugerido

**Gran Escarabajo Cósmico del Biobío**

### Concepto

Un escarabajo robot espacial grande que cayó en el bosque y empezó a contaminar el entorno con energía metálica. No es malvado por naturaleza; está averiado y fuera de control.

### Arena

Claro circular del bosque con:

- Troncos caídos como cobertura.
- Rocas para saltar.
- Tres núcleos de energía robótica.
- Zonas seguras marcadas por luz natural.

### Fases del jefe

**Fase 1:**
- Camina y embiste lentamente.
- El jugador debe esquivar y hacerlo chocar contra rocas.

**Fase 2:**
- Lanza pequeñas chispas robóticas.
- La terrier chilena puede distraerlo brevemente.

**Fase 3:**
- El jefe se cansa y expone su núcleo.
- La caniche toy detecta el punto débil.
- El niño desactiva el núcleo con una interacción no violenta.

### Resultado

El jefe queda desactivado, se libera la energía natural del bosque y aparece la Insignia Silvestre del Biobío.

---

## 8. Mecánicas que debe enseñar este mundo

1. Movimiento básico del niño.
2. Cámara de plataformas 3D.
3. Salto y carrera.
4. Recolección/registro de fauna.
5. Uso de Yuki para detectar secretos.
6. Uso de Kira para activar mecanismos.
7. Esquiva de enemigos robóticos.
8. Combate simple basado en esquivar y usar elementos del entorno.
9. Entrada al Diario de Naturaleza.
10. Obtención de medalla regional.

### Combate del mundo

El combate no se basa en violencia directa permanente. Firipu debe esquivar y usar objetos naturales del lugar contra fauna robot espacial:

- Palos.
- Piedras pequeñas.
- Ramas.
- Tierra.
- Agua del río o charcos.

Estos elementos sirven para aturdir, empujar, desviar o desactivar robots.

### Duración objetivo

Si el jugador avanza bien, el Mundo 01 Biobío no debe superar los **15 minutos**.

---

## 9. Estructura del nivel

### Ruta principal

1. Inicio en sendero familiar.
2. Tutorial de movimiento.
3. Encuentro con primer insecto registrable.
4. Primer enemigo robot menor.
5. Ribera con plataformas.
6. Humedal con secretos.
7. Cerro mirador.
8. Entrada al claro del jefe.
9. Combate contra Gran Escarabajo Cósmico.
10. Liberación del Biobío.

### Zonas opcionales

- Cueva pequeña detrás de cascada.
- Tronco hueco con coleccionable raro.
- Mirador con vista y entrada del diario.
- Mini ruta para la caniche toy.
- Botón oculto para la terrier chilena.

---

## 10. Estilo de interfaz

### HUD mínimo

- Ícono del niño.
- Íconos pequeños de las dos perritas.
- Contador de fauna registrada.
- Indicador de energía/ánimo.
- Botón de Diario de Naturaleza.

### Diario de Naturaleza

Debe verse como cuaderno infantil-aventurero:

- Dibujos tipo stickers.
- Texto corto.
- Mapa de Chile por regiones.
- Página especial para Biobío.

---

## 11. Música y sonido

### Música

- Guitarra suave o charango ligero.
- Percusión natural muy sutil.
- Ambiente de bosque chileno.
- Melodía alegre y familiar.

### Sonidos ambientales

- Río.
- Viento suave.
- Hojas.
- Pájaros lejanos.
- Zumbidos suaves de insectos.
- Sonidos robóticos contrastantes para enemigos.

---

## 12. Reglas de diseño

- No copiar personajes, marcas, música, mapas ni assets protegidos.
- Inspiración chilena, pero diseño propio.
- Fauna real se presenta como amiga, registro o rescate, no como enemigo.
- Los enemigos son robóticos/espaciales.
- Mantener tono apto para familia.
- Evitar violencia explícita.
- Priorizar exploración, curiosidad y naturaleza.

---

## 13. Primer prototipo jugable recomendado

### Alcance del prototipo 0.1

- Escena 3D simple del Biobío.
- Niño controlable con movimiento y salto.
- Cámara tercera persona.
- Dos perritas siguiendo al jugador.
- 3 coleccionables registrables.
- 2 enemigos robóticos básicos.
- Una puerta/ruta activada por la terrier chilena.
- Un secreto detectado por la caniche toy.
- Final del nivel con insignia temporal.

### Criterio de éxito

El prototipo es exitoso si el jugador puede:

1. Moverse cómodamente.
2. Saltar plataformas simples.
3. Sentir que las perritas acompañan y ayudan.
4. Registrar fauna local.
5. Evitar o desactivar robots.
6. Terminar el recorrido inicial.

---

## 14. Próximo documento sugerido

Crear el archivo:

```text
specs/personajes_principales.md
```

Contenido:

- Nombre del niño.
- Apariencia del niño.
- Personalidad.
- Nombre de la caniche toy.
- Nombre de la terrier chilena.
- Habilidades de cada una.
- Reglas de animación.
- Referencias visuales originales.
