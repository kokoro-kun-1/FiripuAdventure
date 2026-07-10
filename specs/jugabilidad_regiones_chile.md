# Firipu Adventure — Jugabilidad por Regiones de Chile

## 1. Propósito

Este documento define una primera matriz de jugabilidad para todas las regiones de Chile en **Firipu Adventure**.

## Reglas generales de diseño

- Cada región representa un mundo jugable.
- La progresión será lineal.
- Cada mundo será un nivel **3D lineal 2.5D lateral**, con avance principal de izquierda a derecha.
- La cámara será lateral fija/semi fija, con profundidad limitada para esquivar, secretos y objetos.
- El estilo debe sentirse como un diorama colorido por capas, no como mapa abierto.
- Cada mundo usa entorno natural representativo.
- Cada región tiene **4 coleccionables principales**.
- Los coleccionables son fauna local pequeña, insectos, arácnidos, anfibios/reptiles pequeños o registros naturales.
- Si una especie se repite entre regiones, se puede reciclar con variantes de color, comportamiento, clima o hábitat.
- Las especies endémicas o muy identitarias tienen mayor relevancia: misión principal, secreto importante, NPC, jefe robot o medalla regional.
- Los enemigos no son animales reales: son **fauna robot espacial** inspirada en formas animales.
- Cada región tendrá una medalla con identidad propia, inspirada en lo más característico de esa región.
- Si el jugador avanza bien, cada mundo debe durar como máximo **15 minutos**.
- El combate será de esquiva y golpes contextuales con elementos del entorno: palos, piedras, ramas, tierra o agua.

---

## 2. Fuentes base consultadas

Investigación inicial basada en fuentes públicas y catálogos de biodiversidad:

- Inventario Nacional de Especies del Ministerio del Medio Ambiente: `https://especies.mma.gob.cl/`
- Página de especies endémicas del MMA: `https://especies.mma.gob.cl/CNMWeb/Web/WebCiudadana/especies_endemicas.aspx`
- Libro Biodiversidad de Chile, Ministerio del Medio Ambiente: `https://mma.gob.cl/wp-content/uploads/2019/04/Tomo-I-libro-Biodiversidad-Chile-MMA-web.pdf`
- Fauna de Chile, resumen enciclopédico: `https://es.wikipedia.org/wiki/Fauna_de_Chile`
- Diagnósticos regionales de biodiversidad del MMA, ejemplo Maule: `https://biodiversidad.mma.gob.cl/wp-content/uploads/2025/01/Diagnostico-07-Maule.pdf`
- Guía de fauna Región de Los Lagos: `https://loslagos.travel/wp-content/uploads/2024/09/Guia-Fauna-.pdf`
- Catálogos/guías regionales complementarios como Naturalistas Aysén y Museo Territorial Yagan Usi.

> Nota de diseño: esta no es una lista científica definitiva. Es una base de gameplay. Antes de cerrar nombres finales de especies conviene validar cada especie con fuentes oficiales o guías regionales.

---

## 3. Reglas globales de reciclaje

### Coleccionables reciclables en varias regiones

Estos pueden repetirse sin problema:

- Chinita.
- Abejorro.
- Mariposa.
- Libélula.
- Escarabajo.
- Saltamontes.
- Hormiga.
- Araña pequeña.
- Caracol.
- Lagartija pequeña.
- Ranita pequeña.

### Cómo evitar que se sientan repetidos

Cada región debe cambiar:

- Color.
- Tamaño.
- Patrón de movimiento.
- Hábitat donde aparece.
- Sonido ambiental.
- Entrada del Diario de Naturaleza.
- Robot enemigo equivalente.

Ejemplo:

```text
Escarabajo del desierto → rueda sobre arena.
Escarabajo del bosque → se esconde bajo hojas.
Escarabajo austral → camina lento sobre musgo húmedo.
```

---

## 4. Sistema de prioridad

### Prioridad A — Endémica o altamente identitaria

Uso recomendado:

- Misión principal.
- Coleccionable raro.
- Guardián de región.
- Jefe robot inspirado en su silueta.
- Medalla regional.

### Prioridad B — Nativa característica

Uso recomendado:

- Coleccionable común o secundario.
- NPC ambiental.
- Pista del Diario.

### Prioridad C — Reciclable

Uso recomendado:

- Coleccionable de apoyo.
- Relleno de exploración.
- Tutorial.

---

# 5. Matriz de mundos por región

## 5.1 Arica y Parinacota

**Entornos:** altiplano, bofedales, quebradas, desierto costero, valles secos.  
**Sensación jugable:** altura, viento, saltos entre rocas, rutas de camanchaca y oasis.

### Fauna/coleccionables prioritarios

- **Picaflor de Arica** — Prioridad A, especie emblemática y muy relevante para misión especial.
- Lagartijas del norte — Prioridad B/A según especie.
- Mariposas y polillas de quebrada — Prioridad B.
- Escarabajos del desierto — Prioridad B.
- Libélulas de bofedal — Prioridad B.
- Vicuña/guanaco — no coleccionable pequeño; usar como NPC de fondo o guardián.

### Enemigos robot sugeridos

- Picaflor dron de alta velocidad.
- Escarabajo solar robot.
- Lagartija metálica de roca.

### Mecánica regional

**Corrientes de viento altiplánico:** Firipu usa ráfagas para saltos largos. Yuki detecta fauna cerca de bofedales; Kira activa compuertas de agua.

---

## 5.2 Tarapacá

**Entornos:** desierto, salares, oasis, quebradas, costa árida.  
**Sensación jugable:** calor, espejismos, caminos secos, fauna escondida bajo piedras.

### Fauna/coleccionables prioritarios

- Lagartijas nortinas — Prioridad B/A según especie.
- Escarabajos de desierto — Prioridad B.
- Arañas pequeñas de zona árida — Prioridad B.
- Mariposas de oasis — Prioridad B.
- Flamencos/parinas — NPC visual de salares, no coleccionable.
- Zorros y roedores nativos — NPC ambiental.

### Enemigos robot sugeridos

- Alacrán robot de arena.
- Lagarto robot camuflado.
- Dron parina de salar.

### Mecánica regional

**Espejismos:** algunas plataformas falsas desaparecen; Yuki puede detectar el camino real con olfato de secretos.

---

## 5.3 Antofagasta

**Entornos:** desierto extremo, costa rocosa, Paposo/camanchaca, salares.  
**Sensación jugable:** supervivencia suave, niebla costera, insectos adaptados al desierto.

### Fauna/coleccionables prioritarios

- Coleópteros desérticos — Prioridad A/B por endemismo local alto en zonas áridas.
- Lagartijas Liolaemus del norte — Prioridad A/B.
- Mariposas de oasis o quebradas — Prioridad B.
- Arañas pequeñas de arena — Prioridad B.
- Chungungo — NPC costero/guardián, no coleccionable menor.
- Parinas/flamencos — NPC de salar.

### Enemigos robot sugeridos

- Escarabajo de cobre espacial.
- Lagartija robot térmica.
- Avispa dron de camanchaca.

### Mecánica regional

**Camanchaca energética:** niebla que revela plataformas ocultas cuando Firipu activa torres naturales.

---

## 5.4 Atacama

**Entornos:** desierto florido, quebradas, dunas, costa, valles secos.  
**Sensación jugable:** mundo árido que se vuelve colorido al encontrar fauna/floración.

### Fauna/coleccionables prioritarios

- **Vaquita del desierto** — Prioridad A como coleccionable estrella.
- Coleópteros del desierto florido — Prioridad A/B.
- Mariposas del desierto florido — Prioridad B.
- Lagartijas de arena — Prioridad B.
- Hormigas y pequeños artrópodos — Prioridad C/B.
- Chinchilla/roedores nativos — NPC o misión, no como enemigo.

### Enemigos robot sugeridos

- Vaquita robot espacial.
- Gusano mecánico de duna.
- Flor metálica que dispara semillas de energía.

### Mecánica regional

**Floración temporal:** al registrar insectos correctos, aparecen flores que crean plataformas por tiempo limitado.

---

## 5.5 Coquimbo

**Entornos:** valles transversales, matorral, costa rocosa, cielos limpios, cordillera semiárida.  
**Sensación jugable:** equilibrio entre desierto y zona central.

### Fauna/coleccionables prioritarios

- Chinchilla chilena — Prioridad A como especie emblemática; usar como NPC protegido.
- Degú — Prioridad A/B, roedor chileno muy identitario.
- Lagartijas de matorral — Prioridad B.
- Escarabajos y mariposas de valle — Prioridad B.
- Chungungo/lobo marino — NPC costero.
- Pequén/aves rapaces pequeñas — NPC.

### Enemigos robot sugeridos

- Chinchilla robot saltarina, sin relación hostil con la real.
- Degú mecánico excavador.
- Cóndor dron lejano.

### Mecánica regional

**Túneles de valle:** Kira abre pequeñas rutas y Yuki detecta entradas ocultas entre matorrales.

---

## 5.6 Valparaíso

**Entornos:** costa, matorral esclerófilo, quebradas, cerros, islas.  
**Sensación jugable:** verticalidad, acantilados, senderos costeros e islas opcionales.

### Fauna/coleccionables prioritarios

- Picaflor de Juan Fernández — Prioridad A si se usa submundo insular.
- Rayadito de Más Afuera — Prioridad A para isla secreta.
- Lagartijas de matorral — Prioridad B.
- Mariposas y chinitas de zona central — Prioridad C/B.
- Chungungo — NPC costero.
- Cururo/degú — Prioridad B en zona continental.

### Enemigos robot sugeridos

- Gaviota dron.
- Picaflor robot insular.
- Cangrejo mecánico de roca.

### Mecánica regional

**Cerros y funiculares naturales:** plataformas móviles verticales hechas de troncos, cuerdas y energía natural.

---

## 5.7 Región Metropolitana

**Entornos:** precordillera, matorral esclerófilo, ríos, cerros isla, quebradas.  
**Sensación jugable:** naturaleza resistiendo cerca de lo urbano, rutas de cerro y quebrada.

### Fauna/coleccionables prioritarios

- Degú — Prioridad A/B.
- Cururo — Prioridad A/B.
- Lagarto gruñidor u otras lagartijas de zona central — Prioridad A/B.
- Rana chilena o anfibios locales — Prioridad B.
- Mariposas, abejas nativas y chinitas — Prioridad C/B.
- Zorro culpeo — NPC de cordillera.

### Enemigos robot sugeridos

- Cururo robot excavador.
- Lagarto robot de piedra.
- Dron urbano-espacial disfrazado de ave.

### Mecánica regional

**Quebradas conectadas:** rutas alternativas entre cerros; la bicicleta temporal permite bajar senderos rápidos.

---

## 5.8 O'Higgins

**Entornos:** bosque esclerófilo, ríos, campos, precordillera, quebradas.  
**Sensación jugable:** transición campo-montaña, rutas con agua y matorral.

### Fauna/coleccionables prioritarios

- Loro tricahue — Prioridad A como misión de protección/observación.
- Cururo — Prioridad B.
- Lagartijas de matorral — Prioridad B.
- Ranitas y sapitos locales — Prioridad B.
- Mariposas y libélulas de río — Prioridad B/C.
- Pequén y aves rapaces — NPC.

### Enemigos robot sugeridos

- Tricahue dron robot.
- Cururo perforador mecánico.
- Avispa robótica de campo.

### Mecánica regional

**Barrancos y nidos:** misiones de observación sin molestar fauna; Yuki ayuda a detectar nidos a distancia segura.

---

## 5.9 Maule

**Entornos:** ríos, bosque esclerófilo, cordillera, roblerías, humedales interiores.  
**Sensación jugable:** mezcla de zona central y sur, con más agua y bosque.

### Fauna/coleccionables prioritarios

- Loro tricahue — Prioridad A/B.
- Degú/cururo — Prioridad B.
- Lagartijas y reptiles de montaña — Prioridad B/A según especie.
- Ranitas de quebrada — Prioridad B.
- Libélulas de humedal — Prioridad B.
- Pudú en zonas boscosas — NPC secreto.

### Enemigos robot sugeridos

- Libélula robot de río.
- Roble-escarabajo mecánico.
- Loro dron de eco.

### Mecánica regional

**Ríos con caudal:** plataformas flotantes, troncos y piedras resbalosas; Kira activa compuertas de ramas.

---

## 5.10 Ñuble

**Entornos:** cordillera, Nevados de Chillán, bosque nativo, ríos, termas naturales.  
**Sensación jugable:** montaña, vapor, nieve parcial y bosque.

### Fauna/coleccionables prioritarios

- Huemul — Prioridad A como guardián regional/NPC protegido.
- Pudú — Prioridad A/B.
- Lagartijas de cordillera — Prioridad B/A.
- Ranitas de bosque — Prioridad B.
- Escarabajos de tronco/musgo — Prioridad B.
- Carpintero negro — NPC de bosque.

### Enemigos robot sugeridos

- Huemul robot guardián averiado.
- Escarabajo geotérmico.
- Dron cóndor de nieve.

### Mecánica regional

**Vapor termal:** chorros de vapor funcionan como elevadores temporales.

---

## 5.11 Biobío

**Entornos:** bosque nativo, humedales, riberas, cerros, costa y cordillera.  
**Sensación jugable:** primer mundo tutorial natural, equilibrado y colorido.

### Fauna/coleccionables prioritarios

- Pudú — Prioridad A/B como NPC secreto.
- Monito del monte — Prioridad A/B si se usa bosque húmedo.
- Ranita de Darwin u otros anfibios australes — Prioridad A/B según validación de distribución.
- Chinitas, abejorros, mariposas, libélulas — Prioridad C/B.
- Lagartijas pequeñas — Prioridad B.
- Caracoles y escarabajos de bosque — Prioridad B.

### Enemigos robot sugeridos

- Gran Escarabajo Cósmico del Biobío.
- Rana robot saltarina.
- Avispa metálica.
- Zorro dron vigía.

### Mecánica regional

**Tutorial de trío:** Firipu salta y corre; Yuki detecta secretos; Kira activa mecanismos y distrae robots.

---

## 5.12 La Araucanía

**Entornos:** araucarias, volcanes, lagos, bosques templados, nieve alta.  
**Sensación jugable:** mundo ancestral, vertical, con árboles gigantes y volcanes.

### Fauna/coleccionables prioritarios

- Monito del monte — Prioridad A.
- Ranita de Darwin — Prioridad A.
- Pudú — Prioridad A/B.
- Güiña — NPC sigiloso, Prioridad A/B.
- Escarabajos de bosque húmedo — Prioridad B.
- Mariposas y polillas de bosque — Prioridad B.

### Enemigos robot sugeridos

- Monito mecánico saltador.
- Araucaria-dron de semillas metálicas.
- Rana robot camuflada.

### Mecánica regional

**Araucarias gigantes:** plataformas espirales en troncos altos y piñones luminosos como guía.

---

## 5.13 Los Ríos

**Entornos:** selva valdiviana, ríos, humedales, lluvia, troncos, helechos grandes.  
**Sensación jugable:** exploración húmeda, sonidos de lluvia, secretos bajo hojas.

### Fauna/coleccionables prioritarios

- Monito del monte — Prioridad A.
- Ranita de Darwin — Prioridad A.
- Pudú — Prioridad A/B.
- Güiña — NPC secreto.
- Caracoles, libélulas, escarabajos de humedad — Prioridad B.
- Chucao y aves de sotobosque — NPC sonoro.

### Enemigos robot sugeridos

- Caracol robot blindado.
- Libélula eléctrica.
- Güiña robot sigilosa.

### Mecánica regional

**Lluvia y musgo:** superficies resbalosas; Yuki detecta huellas y Kira empuja troncos para crear puentes.

---

## 5.14 Los Lagos

**Entornos:** lagos, volcanes, bosques templados, costa, islas, fiordos iniciales.  
**Sensación jugable:** agua, islas pequeñas, puentes naturales, bosque profundo.

### Fauna/coleccionables prioritarios

- Monito del monte — Prioridad A.
- Pudú — Prioridad A/B.
- Huillín — Prioridad A como NPC acuático protegido.
- Chungungo — Prioridad B/A costero.
- Ranita de Darwin — Prioridad A/B.
- Escarabajos, caracoles y libélulas de bosque húmedo — Prioridad B.

### Enemigos robot sugeridos

- Nutria robot acuática.
- Cangrejo mecánico de costa.
- Dron volcánico.

### Mecánica regional

**Cruce de islas:** plataformas flotantes y rutas de agua; bicicleta temporal solo funciona en senderos de tierra, no en agua.

---

## 5.15 Aysén

**Entornos:** Patagonia, fiordos, bosques fríos, glaciares, lagos, montañas.  
**Sensación jugable:** mundo amplio, frío, ventoso y majestuoso.

### Fauna/coleccionables prioritarios

- Huemul — Prioridad A como guardián regional.
- Pudú — Prioridad B en bosque.
- Güiña — Prioridad B/A.
- Huillín — Prioridad A/B en ríos.
- Carpintero negro — NPC.
- Escarabajos y mariposas australes — Prioridad B.

### Enemigos robot sugeridos

- Huemul robot glacial.
- Cóndor dron patagónico.
- Escarabajo de hielo.

### Mecánica regional

**Viento patagónico:** empuja a Firipu y modifica saltos; la bicicleta temporal da velocidad pero exige control.

---

## 5.16 Magallanes y la Antártica Chilena

**Entornos:** estepa patagónica, turberas, fiordos, canales, bosques subantárticos, hielo.  
**Sensación jugable:** final austral, clima extremo, grandes espacios y rutas heladas.

### Fauna/coleccionables prioritarios

- Pingüino de Magallanes — Prioridad A como NPC/misión.
- Guanaco — NPC de estepa.
- Huemul — Prioridad A/B en zonas boscosas australes.
- Zorro culpeo/zorro chilla — NPC.
- Caiquén, caranca, quetro — aves australes como NPC/registro visual.
- Insectos australes, escarabajos, polillas y pequeños invertebrados de turbera — Prioridad B.

### Enemigos robot sugeridos

- Pingüino robot deslizante.
- Guanaco mecánico de estepa.
- Cóndor orbital final.

### Mecánica regional

**Hielo, viento y turberas:** alterna superficies resbalosas, zonas blandas y ráfagas. Puede funcionar como mundo avanzado/final.

---

# 6. Orden recomendado de progresión

Aunque el juego parte en Biobío, el orden puede seguir una ruta narrativa por Chile:

1. Biobío — tutorial principal.
2. Ñuble — montaña/termas.
3. La Araucanía — araucarias/volcán.
4. Los Ríos — selva lluviosa.
5. Los Lagos — lagos/islas.
6. Aysén — viento patagónico.
7. Magallanes — hielo y final austral.
8. Maule — ríos y bosque central.
9. O'Higgins — quebradas/nidos.
10. Metropolitana — cerros y precordillera.
11. Valparaíso — costa/islas.
12. Coquimbo — valles semiáridos.
13. Atacama — desierto florido.
14. Antofagasta — camanchaca/salares.
15. Tarapacá — espejismos/oasis.
16. Arica y Parinacota — altiplano final norte.

Alternativa: usar mapa libre de Chile y dejar que el jugador viaje por regiones desbloqueadas.

---

# 7. Plantilla de jugabilidad por región

Cada región debe tener:

- 1 zona principal.
- 1 zona secreta.
- 4 coleccionables principales de fauna/insectos.
- 1 especie prioritaria/endémica.
- 3 enemigos robot menores.
- 1 jefe robot regional.
- 1 poder temporal o variante ambiental.
- 1 medalla regional con identidad propia.
- 1 entrada educativa especial en el Diario de Naturaleza.
- Duración objetivo: máximo 15 minutos en una partida fluida.

---

# 8. Propuesta de poderes temporales por región

- Biobío: bicicleta de montaña tutorial.
- Ñuble: vapor termal para saltos altos.
- Araucanía: piñón luminoso para trepar araucarias.
- Los Ríos: hoja paraguas para planear bajo lluvia.
- Los Lagos: balsa natural temporal.
- Aysén: impulso de viento patagónico.
- Magallanes: botas de hielo antideslizantes.
- Maule: tronco flotante temporal.
- O'Higgins: eco de tricahue para revelar rutas.
- Metropolitana: impulso de cerro para descensos.
- Valparaíso: cometa costera para planear.
- Coquimbo: túnel de degú para atajos.
- Atacama: floración temporal de plataformas.
- Antofagasta: camanchaca reveladora.
- Tarapacá: cristal anti-espejismo.
- Arica y Parinacota: salto de viento altiplánico.

---

# 9. Próximos pasos

1. Validar científicamente especies prioritarias por región.
2. Elegir 4 coleccionables definitivos por región.
3. Diseñar un jefe robot por región.
4. Crear el mapa de Chile con regiones desbloqueables.
5. Definir medalla regional con identidad propia para cada región.
6. Crear prototipo en Godot 4 con Biobío y sistema reutilizable de región.
