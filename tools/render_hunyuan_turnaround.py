import bpy, os, math
from mathutils import Vector

# Cargar el GLB de Hunyuan3D
glb_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03.glb'

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

bpy.ops.import_scene.gltf(filepath=glb_path)
objs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
print(f"Meshes importados: {len(objs)}")
for o in objs:
    print(f"  {o.name}: {len(o.data.vertices)} verts, {len(o.data.polygons)} faces")

# Unir todos en uno
if len(objs) > 1:
    bpy.context.view_layer.objects.active = objs[0]
    for o in objs[1:]:
        o.select_set(True)
    bpy.ops.object.join()
    mesh_obj = bpy.context.active_object
else:
    mesh_obj = objs[0]

print(f"\nMesh unificado: {mesh_obj.name}")
print(f"Verts: {len(mesh_obj.data.vertices)}")
print(f"Faces: {len(mesh_obj.data.polygons)}")
print(f"Bounds: {mesh_obj.dimensions}")

# Escalar a 1.08 m exactos
target_h = 1.08
current_h = mesh_obj.dimensions.z
scale = target_h / current_h
mesh_obj.scale = (scale, scale, scale)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
print(f"Escalado a {target_h} m: factor {scale:.4f}")
print(f"Nuevas dims: {mesh_obj.dimensions}")

# Centrar en origen (pies en Z=0)
bpy.context.view_layer.objects.active = mesh_obj
mesh_obj.select_set(True)
bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
mesh_obj.location.z = mesh_obj.dimensions.z / 2
bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)
print(f"Posición final Z: {mesh_obj.location.z:.4f}")

# Sombreado suave
for poly in mesh_obj.data.polygons:
    poly.use_smooth = True

# Configurar render para vista previa
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.film_transparent = True

# Cámara orbitando - 8 vistas
for angle in [0, 45, 90, 135, 180, 225, 270, 315]:
    rad = math.radians(angle)
    cam = bpy.data.cameras.new(f"Cam_{angle}")
    cam_obj = bpy.data.objects.new(f"Cam_{angle}", cam)
    bpy.context.collection.objects.link(cam_obj)
    cam_obj.location = (2.0 * math.cos(rad), 2.0 * math.sin(rad), 0.55)
    cam_obj.rotation_euler = (math.radians(90), 0, rad + math.radians(90))
    scene.camera = cam_obj
    
    out_path = fr'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\render_{angle:03d}.png'
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Render {angle}° -> {out_path}")

# Guardar blend
blend_path = fr'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03_work.blend'
bpy.ops.wm.save_as_mainfile(filepath=blend_path)
print(f"\nBlend guardado: {blend_path}")