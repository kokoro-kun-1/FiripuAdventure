import bpy, bmesh, math
from mathutils import Vector

# ============================================================
# v3-3: RETOPOLÓGIA CABEZA + CABELLO + ROSTRO (referencia Hunyuan)
# ============================================================

# 1. CARGAR REFERENCIA HUNYUAN (guía shrinkwrap)
ref_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03.glb'
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
bpy.ops.import_scene.gltf(filepath=ref_path)
ref_obj = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
ref_obj.name = 'ref_hunyuan_head'
# Aislar solo la cabeza (Z > 0.85 aprox)
bpy.context.view_layer.objects.active = ref_obj
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='DESELECT')
bm = bmesh.from_edit_mesh(ref_obj.data)
for f in bm.faces:
    cz = sum((ref_obj.matrix_world @ v.co).z for v in f.verts) / len(f.verts)
    if cz > 0.85:
        f.select = True
bmesh.update_edit_mesh(ref_obj.data)
bpy.ops.mesh.separate(type='SELECTED')
bpy.ops.object.mode_set(mode='OBJECT')

# Objeto cabeza referencia
head_ref = [o for o in bpy.context.scene.objects if o.type == 'MESH' and o != ref_obj][0]
head_ref.name = 'ref_head_guide'
head_ref.hide_set(True)  # oculta, solo para shrinkwrap

# 2. CREAR BASE CABEZA (esfera baja, quad-sphere ~ 1.5k verts)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=0.11, location=(0, 0, 0.95))
head = bpy.context.active_object
head.name = 'head_base'
# Escalar a proporciones: cráneo 16.5-17.5 cm, total con pelo 22-23 cm
head.scale = (0.92, 0.95, 1.05)  # ovalado leve
bpy.ops.object.transform_apply(scale=True)

# 3. SHRINKWRAP A GUÍA HUNYUAN
sw = head.modifiers.new('Shrinkwrap', 'SHRINKWRAP')
sw.target = head_ref
sw.wrap_mode = 'OUTSIDE'
sw.offset = 0.002  # 2 mm fuera para cabello
bpy.context.view_layer.objects.active = head
bpy.ops.object.modifier_apply(modifier='Shrinkwrap')

# 4. TOPOLOGÍA FACIAL — edge loops ojos, boca, mandíbula
bpy.context.view_layer.objects.active = head
bpy.ops.object.mode_set(mode='EDIT')
bm = bmesh.from_edit_mesh(head.data)
bm.faces.ensure_lookup_table()

# Seleccionar zona frontal (cara) para subdividir
for f in bm.faces:
    cen = head.matrix_world @ f.calc_center_median()
    if cen.z > 0.88 and abs(cen.x) < 0.08 and cen.y > -0.05:
        f.select = True

bmesh.update_edit_mesh(head.data)
bpy.ops.mesh.subdivide(number_cuts=2)  # densificar cara
bpy.ops.object.mode_set(mode='OBJECT')

# 5. CREAR OJOS (esferas separadas, 16 segmentos)
eye_r = 0.012  # 12 mm radio
for side, x_off in [('L', -0.028), ('R', 0.028)]:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=eye_r, location=(x_off, 0.055, 0.98))
    eye = bpy.context.active_object
    eye.name = f'eye_{side}'
    # Rotar para mirar al frente
    eye.rotation_euler = (math.radians(90), 0, 0)
    bpy.ops.object.transform_apply(rotation=True)

# 6. CABELLO — mechones sólidos (curves → mesh)
# Usar 12-15 mechones principales siguiendo silueta referencia
hair_clumps = []
clump_roots = [
    # (x, y, z, rot_x, rot_y, scale_z)  raíz en cuero cabelludo
    (-0.04, -0.02, 1.04,  20, -10, 1.0),  # flequillo izq
    ( 0.00, -0.03, 1.05,  15,   0, 1.1),  # flequillo centro
    ( 0.04, -0.02, 1.04,  20,  10, 1.0),  # flequillo der
    (-0.07,  0.00, 1.03,  30, -20, 0.9),  # lado izq
    ( 0.07,  0.00, 1.03,  30,  20, 0.9),  # lado der
    ( 0.00,  0.04, 1.06,  10,   0, 1.0),  # coronilla
    (-0.05,  0.03, 1.04,  25, -15, 0.8),  # trasero izq
    ( 0.05,  0.03, 1.04,  25,  15, 0.8),  # trasero der
]

for i, (x, y, z, rx, ry, sz) in enumerate(clump_roots):
    # Curva tipo bezier
    curve_data = bpy.data.curves.new(f'hair_clump_{i:02d}', 'CURVE')
    curve_data.dimensions = '3D'
    curve_data.resolution_u = 4
    curve_data.bevel_depth = 0.012  # grosor mechón ~1.2 cm
    curve_data.bevel_resolution = 3
    curve_data.fill_mode = 'FULL'
    
    spline = curve_data.splines.new('BEZIER')
    spline.bezier_points.add(3)  # 4 puntos = 3 segmentos
    
    # Raíz en cuero cabelludo
    spline.bezier_points[0].co = (x, y, z)
    spline.bezier_points[0].handle_left_type = 'AUTO'
    spline.bezier_points[0].handle_right_type = 'AUTO'
    # Control 1
    spline.bezier_points[1].co = (x*1.3, y*1.2, z - 0.02)
    # Control 2
    spline.bezier_points[2].co = (x*1.5, y*1.3, z - 0.05)
    # Punta
    spline.bezier_points[3].co = (x*1.6, y*1.4, z - 0.08)
    
    hair_obj = bpy.data.objects.new(f'hair_clump_{i:02d}', curve_data)
    bpy.context.collection.objects.link(hair_obj)
    hair_clumps.append(hair_obj)

# Convertir curvas a malla y unir
for hc in hair_clumps:
    bpy.context.view_layer.objects.active = hc
    bpy.ops.object.convert(target='MESH')

hair_meshes = [o for o in bpy.context.scene.objects if o.name.startswith('hair_clump')]
bpy.context.view_layer.objects.active = hair_meshes[0]
for hm in hair_meshes[1:]:
    hm.select_set(True)
bpy.ops.object.join()
hair = bpy.context.active_object
hair.name = 'hair_blockout'

# 7. BOCA / DIENTES / LENGUA (mallas simples)
# Mandíbula inferior (rotará desde articulación)
bpy.ops.mesh.primitive_cube_add(size=0.04, location=(0, 0.035, 0.91))
jaw = bpy.context.active_object
jaw.name = 'jaw_base'
jaw.scale = (1.2, 0.6, 0.4)
bpy.ops.object.transform_apply(scale=True)

# Dientes superiores (curva simple)
bpy.ops.mesh.primitive_cube_add(size=0.035, location=(0, 0.04, 0.925))
teeth_up = bpy.context.active_object
teeth_up.name = 'teeth_upper'
teeth_up.scale = (1.4, 0.3, 0.25)
bpy.ops.object.transform_apply(scale=True)

# Dientes inferiores
bpy.ops.mesh.primitive_cube_add(size=0.03, location=(0, 0.032, 0.90))
teeth_low = bpy.context.active_object
teeth_low.name = 'teeth_lower'
teeth_low.scale = (1.2, 0.25, 0.2)
bpy.ops.object.transform_apply(scale=True)

# Lengua
bpy.ops.mesh.primitive_cone_add(radius1=0.015, radius2=0.008, depth=0.035, location=(0, 0.042, 0.905))
tongue = bpy.context.active_object
tongue.name = 'tongue'
tongue.rotation_euler = (math.radians(-90), 0, 0)
bpy.ops.object.transform_apply(rotation=True)

# 8. ASIGNAR MATERIALES BASE (paleta canónica)
def mat(name, col, rough=0.7):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*col, 1.0)
        bsdf.inputs['Roughness'].default_value = rough
    return m

mats = {
    'skin':  mat('M_skin',  (0.96, 0.78, 0.68)),
    'hair':  mat('M_hair',  (0.18, 0.12, 0.08), 0.4),
    'eye':   mat('M_eye',   (0.25, 0.18, 0.12), 0.1),
    'teeth': mat('M_teeth', (0.95, 0.93, 0.88), 0.2),
    'tongue':mat('M_tongue',(0.85, 0.45, 0.40), 0.6),
}

for obj, mkey in [(head, 'skin'), (hair, 'hair'), (jaw, 'skin'),
                  (teeth_up, 'teeth'), (teeth_low, 'teeth'), (tongue, 'tongue')]:
    obj.data.materials.append(mats[mkey])

for eye in [o for o in bpy.context.scene.objects if o.name.startswith('eye_')]:
    eye.data.materials.append(mats['eye'])

# 9. ORGANIZAR COLECCIÓN
coll = bpy.data.collections.new('CHR_Firipu_Head')
bpy.context.scene.collection.children.link(coll)
for obj in [head, hair, jaw, teeth_up, teeth_low, tongue] + \
           [o for o in bpy.context.scene.objects if o.name.startswith('eye_')]:
    for c in obj.users_collection:
        c.objects.unlink(obj)
    coll.objects.link(obj)

# 10. GUARDAR .blend v03_head
out_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_head.blend'
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print(f'✅ Guardado: {out_blend}')

# 11. RENDER TURNAROUND CABEZA (para validación)
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.film_transparent = True

# Luces
for ld in bpy.data.lights:
    bpy.data.lights.remove(ld)
key = bpy.data.lights.new('Key', 'SUN'); key.energy = 3.0
key_obj = bpy.data.objects.new('Key', key); bpy.context.collection.objects.link(key_obj)
key_obj.rotation_euler = (math.radians(-45), math.radians(30), 0)
fill = bpy.data.lights.new('Fill', 'SUN'); fill.energy = 1.0
fill_obj = bpy.data.objects.new('Fill', fill); bpy.context.collection.objects.link(fill_obj)
fill_obj.rotation_euler = (math.radians(-30), math.radians(-60), 0)

for angle in [0, 45, 90, 135, 180, 225, 270, 315]:
    rad = math.radians(angle)
    cam = bpy.data.cameras.new(f'Cam_{angle}')
    cam_obj = bpy.data.objects.new(f'Cam_{angle}', cam)
    bpy.context.collection.objects.link(cam_obj)
    cam_obj.location = (0.4*math.cos(rad), 0.4*math.sin(rad), 0.98)
    cam_obj.rotation_euler = (math.radians(90), 0, rad + math.radians(90))
    scene.camera = cam_obj
    scene.render.filepath = fr'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\head_v03_{angle:03d}.png'
    bpy.ops.render.render(write_still=True)
    print(f'  Render {angle}° OK')

print('🎉 v3-3 HEAD COMPLETO — revisa los 8 renders head_v03_*.png')