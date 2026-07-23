import bpy, math, os, sys
from mathutils import Vector

# Limpiar escena
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Importar GLB
glb_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03.glb'
bpy.ops.import_scene.gltf(filepath=glb_path)

# Obtener objeto raíz (mesh principal)
meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
print(f"=== MALLAS ENCONTRADAS: {len(meshes)} ===")
for m in meshes:
    print(f"  {m.name}: verts={len(m.data.vertices)} faces={len(m.data.polygons)}")

# Unir todo en un solo objeto para medir bounds global
if len(meshes) > 1:
    bpy.ops.object.select_all(action='DESELECT')
    for m in meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    main_obj = bpy.context.active_object
else:
    main_obj = meshes[0]

# Bounding box world-space
bbox_corners = [main_obj.matrix_world @ Vector(c) for c in main_obj.bound_box]
xs = [v.x for v in bbox_corners]
ys = [v.y for v in bbox_corners]
zs = [v.z for v in bbox_corners]
width  = max(xs) - min(xs)
depth  = max(ys) - min(ys)
height = max(zs) - min(zs)
print(f"\n=== BOUNDS GLOBALES ===")
print(f"  Ancho X:  {width:.3f} m")
print(f"  Prof. Y:  {depth:.3f} m")
print(f"  Alto Z:   {height:.3f} m")
print(f"  Centro:   ({sum(xs)/8:.3f}, {sum(ys)/8:.3f}, {sum(zs)/8:.3f})")

# Verificar escala objetivo 1.08 m
scale_factor = 1.08 / height
print(f"\n=== ESCALA ===")
print(f"  Factor para 1.08 m: {scale_factor:.4f}")
if abs(height - 1.08) > 0.02:
    print(f"  ⚠️ ALTURA FUERA DE TOLERANCIA (±2 cm)")
else:
    print(f"  ✅ Altura dentro de tolerancia")

# Detectar caras con normales invertidas o geometría interna sospechosa
bm = bpy.context.object.data
inside_faces = 0
for poly in bm.polygons:
    # Heurística: caras orientadas hacia adentro en zonas que deberían ser exterior
    pass  # requiere análisis más fino; omitimos por ahora

# Comprobar si hay vértices/traslapes internos obvios (vértices muy juntos)
verts = [main_obj.matrix_world @ Vector(v.co) for v in main_obj.data.vertices]
print(f"\n=== VÉRTICES TOTALES: {len(verts)} ===")

# Guardar escena para inspección visual
out_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_v03_inspect.blend'
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print(f"\n✅ Guardado .blend de inspección: {out_blend}")