import bpy, math, os, sys
from mathutils import Vector

# Limpiar escena
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Importar GLB
glb_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03.glb'
bpy.ops.import_scene.gltf(filepath=glb_path)

# Objeto importado
main_obj = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH'][0]
print(f"Objeto: {main_obj.name}, verts={len(main_obj.data.vertices)}, faces={len(main_obj.data.polygons)}")

# Escalar a 1.08 m de altura
bbox_corners = [main_obj.matrix_world @ Vector(c) for c in main_obj.bound_box]
zs = [v.z for v in bbox_corners]
height = max(zs) - min(zs)
scale_factor = 1.08 / height
main_obj.scale = (scale_factor, scale_factor, scale_factor)
bpy.ops.object.transform_apply(scale=True)
print(f"Altura original: {height:.3f} m -> Escalado x{scale_factor:.4f} = 1.08 m")

# Recentrar en origen (pies en Z=0)
bbox_corners = [main_obj.matrix_world @ Vector(c) for c in main_obj.bound_box]
min_z = min(v.z for v in bbox_corners)
main_obj.location.z -= min_z
bpy.ops.object.transform_apply(location=True)
print(f"Recentered: pies en Z=0")

# Nueva bbox tras escalado
bbox_corners = [main_obj.matrix_world @ Vector(c) for c in main_obj.bound_box]
xs = [v.x for v in bbox_corners]
ys = [v.y for v in bbox_corners]
zs = [v.z for v in bbox_corners]
print(f"Bounds final: X={max(xs)-min(xs):.3f} Y={max(ys)-min(ys):.3f} Z={max(zs)-min(zs):.3f}")

# Modo edición: separar por materiales / componentes sueltos (si hay)
bpy.context.view_layer.objects.active = main_obj
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
# Separar por partes sueltas (islas desconectadas)
bpy.ops.mesh.separate(type='LOOSE')
bpy.ops.object.mode_set(mode='OBJECT')

parts = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
print(f"\n=== PARTES TRAS SEPARAR POR LOOSE: {len(parts)} ===")
for i, p in enumerate(parts):
    print(f"  {i}: {p.name} verts={len(p.data.vertices)}")

# Guardar .blend de trabajo
out_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_v03_scaled.blend'
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print(f"\n✅ Guardado: {out_blend}")