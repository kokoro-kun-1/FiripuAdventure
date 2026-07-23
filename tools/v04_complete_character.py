import bpy, math
from mathutils import Vector

# ============================================================
# v3-4: UNIR HEAD + BODY → PERSONAJE COMPLETO + TURNAROUND
# ============================================================

# 1. CARGAR HEAD
head_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_head.blend'
bpy.ops.wm.open_mainfile(filepath=head_blend)

# Objetos de la cabeza (colección CHR_Firipu_Head)
head_coll = bpy.data.collections['CHR_Firipu_Head']
head_objects = list(head_coll.objects)

# 2. CARGAR BODY (append para traer colección)
body_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_body.blend'

with bpy.data.libraries.load(body_blend, link=False) as (data_from, data_to):
    data_to.objects = [name for name in data_from.objects]
    data_to.collections = [name for name in data_from.collections]

# Linkear objetos body a escena
body_coll = bpy.data.collections['CHR_Firipu_Body']
bpy.context.scene.collection.children.link(body_coll)
for obj in body_coll.objects:
    if obj.name not in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.link(obj)

# 3. POSICIONAR CABEZA SOBRE CUERPO
# Cuerpo total altura ~1.08m, cuello en z~0.92, cabeza centrada en z~1.0
for obj in head_objects:
    if obj.type in ('MESH', 'CURVE'):
        # Mover cabeza arriba (cuello en z=0.92, cabeza base en z=0.95)
        obj.location.z += 0.95  # head_base estaba en z=0.95 local, mover a 0.95 global
        # La cabeza ya estaba modelada alrededor de z=0.95, solo confirmar posición

print("Objetos cabeza:")
for o in head_objects:
    print(f"  {o.name}: loc={o.location}")

print("\nObjetos cuerpo (muestra):")
for o in list(body_coll.objects)[:10]:
    print(f"  {o.name}: loc={o.location}")

# 4. CREAR COLECCIÓN MASTER
master_coll = bpy.data.collections.new('CHR_Firipu_Complete')
bpy.context.scene.collection.children.link(master_coll)

# Mover todo a master
for coll in [head_coll, body_coll]:
    for obj in coll.objects:
        for c in obj.users_collection:
            c.objects.unlink(obj)
        master_coll.objects.link(obj)

# 5. MATERIALES - asegurar consistencia (paleta canónica ya asignada)

# 6. CONFIGURAR RENDER
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.film_transparent = True

# Luces
for ld in bpy.data.lights:
    bpy.data.lights.remove(ld)

key = bpy.data.lights.new('Key', 'SUN'); key.energy = 3.5
key_obj = bpy.data.objects.new('Key', key); bpy.context.collection.objects.link(key_obj)
key_obj.rotation_euler = (math.radians(-45), math.radians(30), 0)

fill = bpy.data.lights.new('Fill', 'SUN'); fill.energy = 1.2
fill_obj = bpy.data.objects.new('Fill', fill); bpy.context.collection.objects.link(fill_obj)
fill_obj.rotation_euler = (math.radians(-30), math.radians(-60), 0)

rim = bpy.data.lights.new('Rim', 'SUN'); rim.energy = 0.8
rim_obj = bpy.data.objects.new('Rim', rim); bpy.context.collection.objects.link(rim_obj)
rim_obj.rotation_euler = (math.radians(10), math.radians(180), 0)

# 7. CÁMARA ORBITAL 8 VISTAS + RENDER
output_dir = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03'

for angle in [0, 45, 90, 135, 180, 225, 270, 315]:
    rad = math.radians(angle)
    # Cámara a 2m del centro, altura 0.55 (centro cuerpo)
    cam_data = bpy.data.cameras.new(f'Cam_{angle}')
    cam_obj = bpy.data.objects.new(f'Cam_{angle}', cam_data)
    bpy.context.collection.objects.link(cam_obj)
    cam_obj.location = (2.0 * math.cos(rad), 2.0 * math.sin(rad), 0.55)
    cam_obj.rotation_euler = (math.radians(90), 0, rad + math.radians(90))
    scene.camera = cam_obj
    
    out_path = fr_out = fr'{output_dir}\complete_v03_{angle:03d}.png'
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Render {angle}° -> {out_path}")

# 8. GUARDAR BLEND COMPLETO
out_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_complete.blend'
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print(f"\n✅ Blend completo guardado: {out_blend}")

# Stats
total_verts = sum(len(o.data.vertices) for o in master_coll.objects if o.type == 'MESH' and o.data)
total_faces = sum(len(o.data.polygons) for o in master_coll.objects if o.type == 'MESH' and o.data)
print(f"Total vértices: {total_verts:,}")
print(f"Total caras: {total_faces:,}")
print(f"Total objetos: {len(master_coll.objects)}")

print("\n🎉 v3-4 COMPLETO - Revisa 8 renders complete_v03_*.png")