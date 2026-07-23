# Firipu v03 — autoridades visuales y meta

## Estado

- `v01`: aprobado únicamente como prueba de escala/pipeline.
- `v02`: **rechazado visualmente**. No usar como autoridad de forma.
- `v03`: reconstrucción orgánica orientada a máxima fidelidad con las láminas entregadas.

## Identidad congelada

Firipu es un niño aventurero chileno de 5–6 años, curioso, valiente y amable. Altura total: **1,08 m**. Estilo 3D cinematográfico infantil, formas redondeadas, materiales cálidos y silueta legible.

## Autoridades por dimensión

- Alturas y anchos: `firipu_apose_frente_sin_accesorios_2048.png` y `firipu_apose_espalda_sin_accesorios_2048.png`.
- Profundidad: perfiles izquierdo y derecho; normalizar diferencias usando el perfil derecho para el eje corporal y el izquierdo para volumen facial.
- Vista superior: autoridad complementaria de silueta, no de escala.
- Cabeza: `firipu_cabeza_neutral_detalle_2048.png`.
- Expresiones: `firipu_expresiones_faciales_2048.png`.
- Manos: `firipu_manos_detalle_2048.png`.
- Botas: `firipu_botas_detalle_2048.png`.
- Vestuario: `firipu_vestuario_detalle_2048.png`, normalizado con el turnaround (mangas remangadas, camiseta crema, rodilleras oscuras, botamangas enrolladas).
- Accesorios: `firipu_accesorios_detalle_2048.png` (se incorporan después de aprobar cuerpo/ropa v03).

## Proporciones objetivo

- Altura: 1,08 m.
- Cabeza con cabello: aproximadamente 24–26 % de la altura.
- Hombros estrechos, torso corto, caderas infantiles.
- Brazos hasta mitad de muslo; manos pequeñas pero legibles, cinco dedos.
- Piernas cortas-medias, sin aspecto bebé ni adulto.
- Botas grandes de forma estilizada, pero no dominantes.

## Rasgos irrenunciables

- Cabeza y mejillas como superficie continua; no esferas pegadas visibles.
- Ojos café grandes integrados con párpados, no globos saltones sin órbita.
- Nariz pequeña y redondeada; boca y mentón infantiles.
- Cabello castaño oscuro con mechones grandes fluidos y silueta de las láminas.
- Polerón azul orgánico con capucha, bolsillo canguro y cordones.
- Camiseta crema visible en cuello y mangas remangadas.
- Pantalón cargo café con rodilleras oscuras y botamangas enrolladas.
- Calcetines crema con franja roja.
- Botas café redondeadas con lengüeta, ojales/cordones y suela dentada simplificada.

## Criterio de aprobación v03

1. A primera vista debe reconocerse como el mismo Firipu de las referencias.
2. La silueta frontal, lateral y posterior debe coincidir razonablemente con las láminas.
3. No deben leerse primitivas ensambladas en rostro, torso o extremidades.
4. Manos, ropa y botas deben tener continuidad volumétrica.
5. Se entrega turnaround renderizado (frente, 3/4, perfil y espalda), `.blend` y `.glb`.
6. La escala del GLB debe medir exactamente 1,08 m y Godot 4.2.2 debe importarlo.
