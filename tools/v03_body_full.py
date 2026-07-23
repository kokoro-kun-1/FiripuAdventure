import bpy, bmesh, math
from mathutils import Vector

# ============================================================
# v3-3: RETOPOLÓGIA CUERPO COMPLETO (torso, brazos, piernas, botas, manos)
# ============================================================

# 1. CARGAR REFERENCIA HUNYUAN
ref_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03.glb'
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
bpy.ops.import_scene.gltf(filepath=ref_path)
ref_full = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
ref_full.name = 'ref_hunyuan_full'
ref_full.hide_set(True)

# 2. CREAR COLECCIÓN PRINCIPAL
main_coll = bpy.data.collections.new('CHR_Firipu_Body')
bpy.context.scene.collection.children.link(main_coll)

def link_to_main(obj):
    if obj.name not in main_coll.objects:
        main_coll.objects.link(obj)
    # Quitar de colección default
    for c in obj.users_collection:
        if c != main_coll:
            c.objects.unlink(obj)

def make_mat(name, color, rough=0.8):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*color, 1.0)
        bsdf.inputs['Roughness'].default_value = rough
    return mat

# PALETA
M_hoodie = make_mat('M_hoodie', (0.12, 0.35, 0.65))
M_tshirt = make_mat('M_tshirt', (0.95, 0.92, 0.85))
M_pants  = make_mat('M_pants',  (0.35, 0.28, 0.22))
M_knee   = make_mat('M_knee',   (0.15, 0.12, 0.10))
M_socks  = make_mat('M_socks',  (0.95, 0.92, 0.85))
M_stripe = make_mat('M_stripe', (0.70, 0.15, 0.15))
M_boots  = make_mat('M_boots',  (0.28, 0.18, 0.12))
M_sole   = make_mat('M_sole',   (0.12, 0.10, 0.08))
M_skin   = make_mat('M_skin',   (0.96, 0.78, 0.68))

# ============================================================
# FUNCIÓN SHRINKWRAP HELPER
# ============================================================
def shrinkwrap_to_ref(obj, ref, offset=0.001, mode='OUTSIDE'):
    sw = obj.modifiers.new('Shrinkwrap', 'SHRINKWRAP')
    sw.target = ref
    sw.wrap_mode = mode
    sw.offset = offset
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier='Shrinkwrap')

# ============================================================
# 3. TORSO BASE (polerón + camiseta como una malla base, luego separamos)
# ============================================================
# Cilindro torso bajo-polígono: 16 segmentos, 8 anillos
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.11, depth=0.55, location=(0, 0, 0.7))
torso = bpy.context.active_object
torso.name = 'torso_base'
link_to_main(torso)

# Escalar: hombros más anchos, cintura más estrecha
bpy.context.view_layer.objects.active = torso
bpy.ops.object.mode_set(mode='EDIT')
bm = bmesh.from_edit_mesh(torso.data)
# Anillos: 0=cintura, 7=hombros
for v in bm.verts:
    co = torso.matrix_world @ v.co
    h = (co.z - 0.425) / 0.55  # 0..1
    if h > 0.7:  # hombros
        v.co.x *= 1.3
        v.co.y *= 1.15
    elif h < 0.2:  # cintura
        v.co.x *= 0.85
        v.co.y *= 0.9
bmesh.update_edit_mesh(torso.data)
bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.transform_apply(scale=True)

shrinkwrap_to_ref(torso, ref_full, offset=0.003)

# Separar polerón (superior Z > 0.55) y camiseta (inferior)
bpy.context.view_layer.objects.active = torso
bpy.ops.object.mode_set(mode='EDIT')
bm = bmesh.from_edit_mesh(torso.data)
for f in bm.faces:
    cz = sum((torso.matrix_world @ v.co).z for v in f.verts) / len(f.verts)
    f.select = cz > 0.55
bmesh.update_edit_mesh(torso.data)
bpy.ops.mesh.separate(type='SELECTED')
bpy.ops.object.mode_set(mode='OBJECT')

# Asignar materiales
parts = [o for o in bpy.context.scene.objects if o.type == 'MESH' and o.name.startswith('torso')]
for p in parts:
    link_to_main(p)
    if 'torso_base.001' in p.name or p.name.endswith('.001'):  # parte superior = polerón
        p.name = 'hoodie'
        p.data.materials.clear()
        p.data.materials.append(M_hoodie)
    else:
        p.name = 'tshirt'
        p.data.materials.clear()
        p.data.materials.append(M_tshirt)

# ============================================================
# 4. BRAZOS (mangas polerón + camiseta)
# ============================================================
for side, x_mult in [('L', -1), ('R', 1)]:
    # Brazo cilindro 12 seg, desde hombro (z~0.9) hasta muñeca (z~0.45)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.038, depth=0.45, 
        location=(x_mult * 0.15, 0, 0.675), rotation=(0, math.radians(90), 0))
    arm = bpy.context.active_object
    arm.name = f'arm_hoodie_{side}'
    link_to_main(arm)
    bpy.ops.object.transform_apply(rotation=True, scale=True)
    
    # Taper: hombro más ancho, muñeca más estrecho
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(arm.data)
    for v in bm.verts:
        cz = (arm.matrix_world @ v.co).z
        h = (cz - 0.45) / 0.45
        if h > 0.8:
            v.co.x *= 1.3
            v.co.y *= 1.2
        elif h < 0.2:
            v.co.x *= 0.7
            v.co.y *= 0.7
    bmesh.update_edit_mesh(arm.data)
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(scale=True)
    
    shrinkwrap_to_ref(arm, ref_full, offset=0.003)
    arm.data.materials.clear()
    arm.data.materials.append(M_hoodie)

# Manga camiseta (corta, llega a mitad del brazo) - duplicar y acortar
for side in ['L', 'R']:
    src = bpy.data.objects[f'arm_hoodie_{side}']
    bpy.context.view_layer.objects.active = src
    bpy.ops.object.duplicate()
    sleeve = bpy.context.active_object
    sleeve.name = f'sleeve_tshirt_{side}'
    link_to_main(sleeve)
    
    # Acortar a 0.25 m (mitad brazo)
    bpy.context.view_layer.objects.active = sleeve
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(sleeve.data)
    for v in bm.verts:
        cz = (sleeve.matrix_world @ v.co).z
        if cz < 0.575:  # cortar en mitad
            v.co = Vector(v.co)
    # Borrar caras inferiores
    for f in list(bm.faces):
        cz = sum((sleeve.matrix_world @ v.co).z for v in f.verts) / len(f.verts)
        if cz < 0.575:
            bm.faces.remove(f)
    bmesh.update_edit_mesh(sleeve.data)
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Cap inferior
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.extrude_region_move(TRANSFORM_OT_translate={"value": (0, 0, -0.001)})
    bpy.ops.mesh.merge(type='CENTER')
    bpy.ops.object.mode_set(mode='OBJECT')
    
    sleeve.data.materials.clear()
    sleeve.data.materials.append(M_tshirt)

# ============================================================
# 5. MANOS (5 dedos × 3 falanges = 15 huesos por mano)
# ============================================================
for side, x_mult in [('L', -1), ('R', 1)]:
    # Palma: cubo achatado
    bpy.ops.mesh.primitive_cube_add(size=0.06, location=(x_mult * 0.11, 0, 0.45))
    palm = bpy.context.active_object
    palm.name = f'hand_palm_{side}'
    link_to_main(palm)
    bpy.ops.object.transform_apply(scale=True)
    
    # Escalar: palma más ancha que profunda
    palm.scale = (1.2, 0.6, 0.35)
    bpy.ops.object.transform_apply(scale=True)
    
    shrinkwrap_to_ref(palm, ref_full, offset=0.002)
    palm.data.materials.clear()
    palm.data.materials.append(M_skin)
    
    # Dedos: 5 cilindros cónicos
    finger_data = [
        ('index',   x_mult * 0.13,  0.015,  0.44, 0.055),
        ('middle',  x_mult * 0.14,  0.000,  0.44, 0.060),
        ('ring',    x_mult * 0.13, -0.015,  0.44, 0.055),
        ('pinky',   x_mult * 0.11, -0.028,  0.44, 0.045),
        ('thumb',   x_mult * 0.06,  0.030,  0.46, 0.050),
    ]
    
    for fname, fx, fy, fz, flen in finger_data:
        for phal, (z_off, rad) in enumerate([(0, 0.011), (0.022, 0.009), (0.038, 0.007)]):
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=rad, depth=0.022,
                location=(fx, fy, fz + z_off), rotation=(math.radians(-10), 0, 0))
            finger = bpy.context.active_object
            finger.name = f'hand_{fname}_{phal+1}_{side}'
            link_to_main(finger)
            bpy.ops.object.transform_apply(rotation=True, scale=True)
            shrinkwrap_to_ref(finger, ref_full, offset=0.001)
            finger.data.materials.clear()
            finger.data.materials.append(M_skin)

# ============================================================
# 6. PIERNAS / PANTALÓN + RODILLERAS
# ============================================================
for side, x_mult in [('L', -1), ('R', 1)]:
    # Pierna cilindro 12 seg: cadera z~0.45 hasta tobillo z~0.07
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.045, depth=0.38,
        location=(x_mult * 0.055, 0, 0.26), rotation=(math.radians(90), 0, 0))
    leg = bpy.context.active_object
    leg.name = f'pants_{side}'
    link_to_main(leg)
    bpy.ops.object.transform_apply(rotation=True, scale=True)
    
    # Taper: muslo ancho, tobillo estrecho
    bpy.context.view_layer.objects.active = leg
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(leg.data)
    for v in bm.verts:
        cz = (leg.matrix_world @ v.co).z
        h = (cz - 0.07) / 0.38
        if h > 0.7:      # muslo
            v.co.x *= 1.2
            v.co.y *= 1.1
        elif h < 0.2:    # tobillo
            v.co.x *= 0.65
            v.co.y *= 0.65
    bmesh.update_edit_mesh(leg.data)
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(scale=True)
    
    shrinkwrap_to_ref(leg, ref_full, offset=0.003)
    leg.data.materials.clear()
    leg.data.materials.append(M_pants)
    
    # Rodillera (disco en Z ~0.26-0.22)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.055, depth=0.02,
        location=(x_mult * 0.055, 0.05, 0.24), rotation=(0, 0, 0))
    knee = bpy.context.active_object
    knee.name = f'knee_patch_{side}'
    link_to_main(knee)
    bpy.ops.object.transform_apply(rotation=True, scale=True)
    shrinkwrap_to_ref(knee, ref_full, offset=0.004)
    knee.data.materials.clear()
    knee.data.materials.append(M_knee)

# ============================================================
# 7. CALCETINES (crema + franja roja) + BOTAS
# ============================================================
for side, x_mult in [('L', -1), ('R', 1)]:
    # Calcetín: tobillo z=0.07 a z=0.13
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.038, depth=0.06,
        location=(x_mult * 0.055, 0, 0.10), rotation=(math.radians(90), 0, 0))
    sock = bpy.context.active_object
    sock.name = f'sock_{side}'
    link_to_main(sock)
    bpy.ops.object.transform_apply(rotation=True, scale=True)
    shrinkwrap_to_ref(sock, ref_full, offset=0.002)
    sock.data.materials.clear()
    sock.data.materials.append(M_socks)
    
    # Franja roja (anillo en Z=0.12)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.04, depth=0.008,
        location=(x_mult * 0.055, 0, 0.12), rotation=(math.radians(90), 0, 0))
    stripe = bpy.context.active_object
    stripe.name = f'sock_stripe_{side}'
    link_to_main(stripe)
    bpy.ops.object.transform_apply(rotation=True, scale=True)
    shrinkwrap_to_ref(stripe, ref_full, offset=0.0025)
    stripe.data.materials.clear()
    stripe.data.materials.append(M_stripe)
    
    # BOTA: cuerpo (z=0.07 a 0.00) + suela
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(x_mult * 0.055, 0.02, 0.035))
    boot = bpy.context.active_object
    boot.name = f'boot_{side}'
    link_to_main(boot)
    
    # Forma bota: puntera redondeada, talón elevado
    bpy.context.view_layer.objects.active = boot
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(boot.data)
    for v in bm.verts:
        co = boot.matrix_world @ v.co
        # Puntera (Y positivo) -> redondear
        if co.y > 0.05:
            v.co.y *= 0.7
            v.co.z *= 1.1
        # Talón (Y negativo) -> elevar
        if co.y < -0.02:
            v.co.z += 0.015
        # Lados: estrechar
        v.co.x *= 0.9
    bmesh.update_edit_mesh(boot.data)
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(scale=True)
    
    shrinkwrap_to_ref(boot, ref_full, offset=0.004)
    boot.data.materials.clear()
    boot.data.materials.append(M_boots)
    
    # Suela (inferior)
    bpy.ops.mesh.primitive_cube_add(size=0.105, location=(x_mult * 0.055, 0.02, -0.012))
    sole = bpy.context.active_object
    sole.name = f'boot_sole_{side}'
    link_to_main(sole)
    sole.scale = (1.0, 1.0, 0.15)
    bpy.ops.object.transform_apply(scale=True)
    shrinkwrap_to_ref(sole, ref_full, offset=0.001, mode='ABOVE_SURFACE')
    sole.data.materials.clear()
    sole.data.materials.append(M_sole)

# ============================================================
# 8. LIMPIEZA Y GUARDADO
# ============================================================
# Eliminar referencia
bpy.data.objects.remove(ref_full, do_unlink=True)

# Suavizado
for obj in main_coll.objects:
    if obj.type == 'MESH':
        for poly in obj.data.polygons:
            poly.use_smooth = True

# Guardar
out_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_body.blend'
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print(f"\n✅ Guardado: {out_blend}")

# Render turnaround
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.film_transparent = True

# Luz
for ld in bpy.data.lights: bpy.data.lights.remove(ld)
ld1 = bpy.data.lights.new('Key', 'SUN'); ld1.energy = 3.0
lo1 = bpy.data.objects.new('Key', ld1); bpy.context.collection.objects.link(lo1)
lo1.rotation_euler = (math.radians(-45), math.radians(30), 0)
ld2 = bpy.data.lights.new('Fill', 'SUN'); ld2.energy = 1.0
lo2 = bpy.data.objects.new('Fill', ld2); bpy.context.collection.objects.link(lo2)
lo2.rotation_euler = (math.radians(-30), math.radians(-60), 0)

for angle in [0, 45, 90, 135, 180, 225, 270, 315]:
    rad = math.radians(angle)
    cam = bpy.data.cameras.new(f'Cam_{angle}')
    cobj = bpy.data.objects.new(f'Cam_{angle}', cam)
    bpy.context.collection.objects.link(cobj)
    cobj.location = (2.0 * math.cos(rad), 2.0 * math.sin(rad), 0.55)
    cobj.rotation_euler = (math.radians(90), 0, rad + math.radians(90))
    scene.camera = cobj
    out_path = fr'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\body_v03_{angle:03d}.png'
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Render {angle}° -> {out_path}")

print("\n✅ Body v03 completo + renders")